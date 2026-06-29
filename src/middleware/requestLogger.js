/**
 * src/middleware/requestLogger.js
 *
 * Express middleware to log incoming requests and responses using Winston.
 * Production-ready:
 *  - Adds a unique request id to req.id and response header X-Request-Id
 *  - Logs method, url, status, response time, client IP and user-agent
 *  - Skips /api/health to reduce noise
 *  - Uses structured JSON output in production (driven by logger)
 *  - Uses colored, human-friendly output in development
 *  - Handles logging errors gracefully
 *
 * Exports a single middleware function: (req, res, next) => void
 */

const { randomUUID } = require('crypto');
const logger = require('../utils/logger');

/**
 * Extract the client's IP from the request, honoring X-Forwarded-For if present.
 * @param {import('express').Request} req
 * @returns {string|undefined}
 */
function getClientIp(req) {
  const xff = req.headers['x-forwarded-for'];
  if (xff && typeof xff === 'string') {
    return xff.split(',')[0].trim();
  }

  if (req.ip) return req.ip;
  if (req.connection && req.connection.remoteAddress) return req.connection.remoteAddress;
  if (req.socket && req.socket.remoteAddress) return req.socket.remoteAddress;
  if (req.connection && req.connection.socket && req.connection.socket.remoteAddress)
    return req.connection.socket.remoteAddress;
  return undefined;
}

/**
 * Express request logger middleware factory.
 * This middleware assigns a request id, attaches it to req.id, sets X-Request-Id
 * response header, and logs request/response lifecycle data when the response finishes.
 *
 * @example
 * const express = require('express');
 * const requestLogger = require('./middleware/requestLogger');
 * app.use(requestLogger);
 *
 * @param {import('express').Request} req
 * @param {import('express').Response} res
 * @param {import('express').NextFunction} next
 */
module.exports = function requestLogger(req, res, next) {
  try {
    // Skip health checks to reduce log noise in production
    if (req.path === '/api/health') return next();

    // Respect incoming X-Request-Id if provided by upstream systems
    const incomingId = req.headers['x-request-id'];
    const reqId = incomingId || randomUUID();

    // Attach to request for downstream handlers and include in logs
    req.id = reqId;

    // Try to expose request id to clients; don't fail startup if headers cannot be set
    try {
      res.setHeader('X-Request-Id', reqId);
    } catch (err) {
      // no-op: setting headers may fail in some edge cases (already sent)
    }

    const start = process.hrtime.bigint();

    /**
     * onFinish handler: collect timing and metadata and write a structured log entry.
     */
    const onFinish = () => {
      try {
        const diffNs = Number(process.hrtime.bigint() - start);
        const durationMs = Math.round((diffNs / 1e6) * 100) / 100; // two decimals

        const meta = {
          requestId: reqId,
          method: req.method,
          url: req.originalUrl || req.url,
          status: res.statusCode,
          durationMs,
          clientIp: getClientIp(req),
          userAgent: req.get('user-agent') || '',
        };

        const level = res.statusCode >= 500 ? 'error' : res.statusCode >= 400 ? 'warn' : 'info';

        // logger will format meta appropriately (JSON in prod, colored in dev)
        logger.log(level, 'HTTP request completed', meta);
      } catch (err) {
        // Ensure logging errors don't break the response lifecycle
        try {
          logger.error('Failed to log request', { requestId: reqId, error: err.message });
        } catch (e) {
          // swallow secondary logging errors
        }
      }
    };

    // Capture finish and close events
    res.on('finish', onFinish);
    res.on('close', onFinish);

    // Capture response errors separately
    res.on('error', (err) => {
      try {
        logger.error('Response error', { requestId: reqId, error: err && err.message });
      } catch (e) {
        // swallow
      }
    });

    next();
  } catch (err) {
    // If middleware initialization fails, log but don't stop request processing
    try {
      logger.error('requestLogger middleware initialization error', { error: err && err.message });
    } catch (e) {
      // swallow
    }
    next();
  }
};
