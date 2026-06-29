/*
 * src/middleware/requestLogger.js
 * Express middleware to log incoming requests and responses using Winston.
 * - Adds a unique request id to req.id and response header X-Request-Id
 * - Logs method, url, status, response time, client IP and user-agent
 * - Skips /api/health
 * - Structured JSON logs in production (logger handles format)
 * - Colored logs in development
 * - Handles logging errors gracefully
 */

const { randomUUID } = require('crypto');
const logger = require('../utils/logger');

function getClientIp(req) {
  // Prefer X-Forwarded-For for proxies, fallback to connection remote address
  const xff = req.headers['x-forwarded-for'];
  if (xff && typeof xff === 'string') {
    // X-Forwarded-For may contain a list: client, proxy1, proxy2
    return xff.split(',')[0].trim();
  }

  if (req.ip) return req.ip;
  if (req.connection && req.connection.remoteAddress) return req.connection.remoteAddress;
  if (req.socket && req.socket.remoteAddress) return req.socket.remoteAddress;
  if (req.connection && req.connection.socket && req.connection.socket.remoteAddress)
    return req.connection.socket.remoteAddress;
  return undefined;
}

module.exports = function requestLogger(req, res, next) {
  try {
    // Skip health checks to reduce noise
    if (req.path === '/api/health') return next();

    // Assign or reuse request id
    const incomingId = req.headers['x-request-id'];
    const reqId = incomingId || randomUUID();
    req.id = reqId;

    // Expose request id to clients
    try {
      res.setHeader('X-Request-Id', reqId);
    } catch (err) {
      // ignore header set errors
    }

    const start = process.hrtime.bigint();

    // When response finishes, log details
    res.on('finish', () => {
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

        // Choose log level based on status
        const level = res.statusCode >= 500 ? 'error' : res.statusCode >= 400 ? 'warn' : 'info';

        // Log with structured meta; logger configuration handles JSON vs colored output
        logger.log(level, 'HTTP request completed', meta);
      } catch (err) {
        // Ensure logging errors don't break the response lifecycle
        try {
          logger.error('Failed to log request', { requestId: reqId, error: err.message });
        } catch (e) {
          // swallow
        }
      }
    });

    // Also capture unexpected errors on the response socket
    res.on('error', (err) => {
      try {
        logger.error('Response error', { requestId: reqId, error: err && err.message });
      } catch (e) {
        // swallow
      }
    });

    // proceed
    next();
  } catch (err) {
    // Log and continue
    try {
      logger.error('requestLogger middleware initialization error', { error: err.message });
    } catch (e) {
      // swallow
    }
    next();
  }
};
