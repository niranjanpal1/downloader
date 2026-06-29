/*
 * src/utils/logger.js
 * Production-ready logger using Winston
 * - Console logging (colored in development)
 * - Optional file logging when LOG_DIR is set
 * - JSON output in production for structured logging
 * - Log level controlled by LOG_LEVEL env var
 * - Exposes a stream.write for integration with other loggers/middleware
 */

const fs = require('fs');
const path = require('path');
const { createLogger, format, transports } = require('winston');

const NODE_ENV = process.env.NODE_ENV || 'production';
const LOG_LEVEL = process.env.LOG_LEVEL || 'info';
const LOG_DIR = process.env.LOG_DIR || '';

// Ensure log directory exists when configured (best-effort)
if (LOG_DIR) {
  try {
    fs.mkdirSync(LOG_DIR, { recursive: true });
  } catch (err) {
    // If directory creation fails, continue but file transport will fail later
    // Avoid throwing here so application startup is not blocked by logging config
  }
}

const { combine, timestamp, printf, colorize, json, splat } = format;

// Human-friendly format for development
const devFormat = combine(
  colorize({ all: true }),
  timestamp({ format: 'YYYY-MM-DD HH:mm:ss' }),
  splat(),
  printf(({ timestamp, level, message, ...meta }) => {
    const metaKeys = Object.keys(meta || {});
    const metaStr = metaKeys.length ? ` ${JSON.stringify(meta)}` : '';
    return `${timestamp} [${level}]: ${message}${metaStr}`;
  })
);

// Structured JSON format for production
const prodFormat = combine(
  timestamp(),
  splat(),
  json()
);

const logger = createLogger({
  level: LOG_LEVEL,
  format: NODE_ENV === 'production' ? prodFormat : devFormat,
  transports: [
    new transports.Console({ handleExceptions: true }),
  ],
  exitOnError: false,
});

// Add file transport only if LOG_DIR is provided
if (LOG_DIR) {
  const fileTransport = new transports.File({
    filename: path.join(LOG_DIR, 'downloader.log'),
    level: LOG_LEVEL,
    handleExceptions: true,
    maxsize: 5 * 1024 * 1024, // 5MB
    maxFiles: 5,
    tailable: true,
  });

  logger.add(fileTransport);
}

// Stream interface for morgan or other middleware that expects stream.write
logger.stream = {
  write: (message) => {
    // Remove trailing newline added by some loggers
    logger.info(message.trim());
  },
};

module.exports = logger;
