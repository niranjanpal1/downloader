// src/middleware/security.js
// NOTE: ES Module syntax as requested (import/export). This file configures security-related middleware for Express.

import helmet from 'helmet';
import cors from 'cors';
import rateLimit from 'express-rate-limit';

/**
 * Configure and apply production-ready security middleware to an Express app.
 * This is a factory that takes the express `app` and optional options (via environment variables)
 * and wires Helmet, CORS, rate limiting, request content-type validation, body size checks,
 * suspicious user-agent blocking and additional secure headers.
 *
 * Environment variables supported (recommended to set via .env or platform env):
 * - CORS_ORIGINS: comma-separated list of allowed origins (default: same-origin)
 * - CORS_METHODS: comma-separated list of allowed HTTP methods (default: GET,HEAD,PUT,PATCH,POST,DELETE)
 * - RATE_LIMIT_WINDOW_MS: window size in milliseconds (default: 60000)
 * - RATE_LIMIT_MAX: max requests per window (default: 100)
 * - BODY_LIMIT_BYTES: maximum allowed content-length in bytes for incoming requests (default: 10MB)
 * - BLOCKED_USER_AGENTS: comma-separated substrings to block in the user-agent header (default common scanners)
 *
 * Notes: This module uses ES module exports. When integrating into a CommonJS project ensure you import with dynamic import
 * or use an interop wrapper when required. Keep the middleware mounted early in the middleware chain.
 *
 * @param {import('express').Express} app - Express application instance
 */
export default function configureSecurity(app) {
  // Basic Helmet defaults with sensible protections enabled
  // Helmet will set X-DNS-Prefetch-Control, Expect-CT, X-Frame-Options, Strict-Transport-Security,
  // X-Download-Options, X-Content-Type-Options, and X-Permitted-Cross-Domain-Policies among others.
  app.use(
    helmet({
      contentSecurityPolicy: false, // CSP can be highly specific per deployment; leave disabled by default and recommend operator to enable
      crossOriginEmbedderPolicy: false, // some environments may break with COEP; allow operators to enable if desired
    })
  );

  // Remove X-Powered-By for security through obscurity
  try {
    app.disable && app.disable('x-powered-by');
  } catch (e) {
    // ignore if not available
  }

  // Configure CORS from environment variables
  const originsEnv = process.env.CORS_ORIGINS || '';
  const allowedOrigins = originsEnv ? originsEnv.split(',').map((o) => o.trim()) : undefined;

  const corsOptions = {
    origin: allowedOrigins && allowedOrigins.length > 0 ? allowedOrigins : false, // false means no CORS by default; set to true for wildcard
    methods: (process.env.CORS_METHODS || 'GET,HEAD,PUT,PATCH,POST,DELETE').split(',').map((m) => m.trim()),
    allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With', 'X-Request-Id'],
    exposedHeaders: ['X-Request-Id'],
    credentials: false,
    maxAge: 600,
  };

  // On Render or dynamic hosts you may want to allow origin based on BASE_URL env var
  if (!allowedOrigins || allowedOrigins.length === 0) {
    const base = process.env.BASE_URL;
    if (base) corsOptions.origin = [base];
  }

  // If corsOptions.origin is false, CORS will be disabled. Operators can explicitly set CORS_ORIGINS='*' if they want wildcard.
  app.use(cors(corsOptions));

  // Rate limiting (basic in-memory). For horizontal scaling use a shared store (Redis) via rate-limit-redis.
  const rlWindow = parseInt(process.env.RATE_LIMIT_WINDOW_MS || '60000', 10); // default 1 minute
  const rlMax = parseInt(process.env.RATE_LIMIT_MAX || '100', 10); // default 100 requests per window

  const limiter = rateLimit({
    windowMs: Number.isNaN(rlWindow) ? 60000 : rlWindow,
    max: Number.isNaN(rlMax) ? 100 : rlMax,
    standardHeaders: true, // Return rate limit info in the `RateLimit-*` headers
    legacyHeaders: false, // Disable the `X-RateLimit-*` headers
    handler: (req, res) => {
      res.status(429).json({
        status: 'error',
        code: 'RATE_LIMIT_EXCEEDED',
        message: 'Too many requests, please try again later.',
        requestId: req && req.id,
        timestamp: new Date().toISOString(),
      });
    },
  });

  // Apply rate limiter to API paths only
  app.use('/api/', limiter);

  // Request body size limits: check Content-Length header early and reject
  const bodyLimitBytes = parseInt(process.env.BODY_LIMIT_BYTES || String(10 * 1024 * 1024), 10); // default 10MB

  app.use((req, res, next) => {
    try {
      const contentLength = req.headers['content-length'];
      if (contentLength && !Number.isNaN(Number(contentLength))) {
        if (Number(contentLength) > bodyLimitBytes) {
          res.status(413).json({
            status: 'error',
            code: 'PAYLOAD_TOO_LARGE',
            message: 'Request payload is too large',
            requestId: req && req.id,
            timestamp: new Date().toISOString(),
          });
          return;
        }
      }
    } catch (err) {
      // swallow header parse errors
    }
    next();
  });

  // Validate JSON content-type for API endpoints that expect JSON (POST/PUT/PATCH)
  app.use('/api/', (req, res, next) => {
    try {
      const method = (req.method || '').toUpperCase();
      if (['POST', 'PUT', 'PATCH'].includes(method)) {
        const ct = req.headers['content-type'] || '';
        if (!ct.includes('application/json') && !ct.includes('multipart/form-data') && !ct.includes('application/x-www-form-urlencoded')) {
          res.status(415).json({
            status: 'error',
            code: 'UNSUPPORTED_MEDIA_TYPE',
            message: 'Content-Type must be application/json, form-data or x-www-form-urlencoded',
            requestId: req && req.id,
            timestamp: new Date().toISOString(),
          });
          return;
        }
      }
    } catch (err) {
      // If validation fails unexpectedly, allow request to proceed to let deeper validation handle it
    }
    next();
  });

  // Block suspicious user agents if configured or use sensible defaults
  const blockedUAEnv = process.env.BLOCKED_USER_AGENTS || 'curl,libwww-perl,python-requests,nikto,Mozilla/5.0 (Windows NT 6';
  const blockedSubstrings = blockedUAEnv.split(',').map((s) => s.trim()).filter(Boolean);

  app.use((req, res, next) => {
    try {
      const ua = (req.headers['user-agent'] || '').toLowerCase();
      if (!ua) {
        // Block empty user agents (often bots)
        res.status(400).json({ status: 'error', code: 'BAD_USER_AGENT', message: 'Invalid user agent', requestId: req && req.id, timestamp: new Date().toISOString() });
        return;
      }

      for (const sub of blockedSubstrings) {
        if (!sub) continue;
        if (ua.includes(sub.toLowerCase())) {
          res.status(403).json({ status: 'error', code: 'BLOCKED_USER_AGENT', message: 'User agent blocked', requestId: req && req.id, timestamp: new Date().toISOString() });
          return;
        }
      }
    } catch (err) {
      // swallow
    }
    next();
  });

  // Additional secure headers and MIME sniffing prevention
  app.use((req, res, next) => {
    try {
      // Prevent MIME sniffing
      res.setHeader('X-Content-Type-Options', 'nosniff');
      // Prevent clickjacking
      res.setHeader('X-Frame-Options', 'DENY');
      // Referrer policy
      res.setHeader('Referrer-Policy', 'no-referrer');
      // Permissions policy (opt-in, minimal)
      res.setHeader('Permissions-Policy', "geolocation=()\",");
    } catch (err) {
      // ignore header errors
    }
    next();
  });

  // All security middleware applied
}
