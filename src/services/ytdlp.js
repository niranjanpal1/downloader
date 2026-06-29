// src/services/ytdlp.js
// ES module service wrapping yt-dlp via child_process.spawn

import { spawn } from 'child_process';
import { createInterface } from 'readline';
import fs from 'fs';
import path from 'path';
import { createRequire } from 'module';

const require = createRequire(import.meta.url);
const logger = require('../utils/logger'); // logger is CommonJS

/**
 * Custom Error for download-related failures
 */
export class DownloadError extends Error {
  constructor(message, { code = 'DOWNLOAD_ERROR', statusCode = 502, cause } = {}) {
    super(message);
    this.name = 'DownloadError';
    this.code = code;
    this.statusCode = statusCode;
    if (cause) this.cause = cause;
  }
}

/**
 * Validate a URL string to ensure it's an http(s) resource.
 * @param {string} url
 */
function validateUrl(url) {
  try {
    const u = new URL(url);
    if (!['http:', 'https:'].includes(u.protocol)) {
      throw new DownloadError('URL must use http or https protocol', { code: 'INVALID_URL', statusCode: 400 });
    }
    return u.toString();
  } catch (err) {
    if (err instanceof DownloadError) throw err;
    throw new DownloadError('Invalid URL', { code: 'INVALID_URL', statusCode: 400, cause: err });
  }
}

/**
 * Build common yt-dlp args from options and environment
 * @param {object} opts
 * @returns {string[]}
 */
function buildCommonArgs(opts = {}) {
  const args = ['--newline', '--no-warnings'];

  const ytdlpBin = process.env.YTDLP_BIN || 'yt-dlp';

  const cookies = opts.cookies || process.env.COOKIE_JAR;
  if (cookies) {
    if (fs.existsSync(cookies)) args.push('--cookies', cookies);
    else logger.warn('Cookies file not found, skipping --cookies', { path: cookies });
  }

  const proxy = opts.proxy || process.env.PROXY;
  if (proxy) args.push('--proxy', proxy);

  const ua = opts.userAgent || process.env.USER_AGENT;
  if (ua) args.push('--user-agent', ua);

  const archive = opts.archiveFile || process.env.ARCHIVE_FILE;
  if (archive) args.push('--download-archive', archive);

  return { args, ytdlpBin };
}

/**
 * Parse yt-dlp progress lines and emit structured events
 * @param {string} line
 * @returns {object|null}
 */
function parseProgressLine(line) {
  // Example progress line: [download]   3.2% of 10.00MiB at 123.45KiB/s ETA 01:23
  if (!line) return null;
  const trimmed = line.trim();

  // Destination: example
  if (trimmed.startsWith('[download] Destination:')) {
    const dest = trimmed.replace('[download] Destination:', '').trim();
    return { type: 'destination', destination: dest };
  }

  // Finished
  if (trimmed.startsWith('[download]') && /100%/.test(trimmed) && /has already been downloaded|has already been recorded/i.test(trimmed) === false) {
    return { type: 'done', raw: trimmed };
  }

  // Already downloaded
  if (/has already been downloaded|already been recorded|already downloaded/i.test(trimmed)) {
    return { type: 'skipped', raw: trimmed };
  }

  // Generic download progress
  if (trimmed.startsWith('[download]')) {
    // Try to extract percent, downloaded, total, speed, eta
    const re = /\[download\]\s+([0-9.]+)% of\s+([^\s]+)\s+at\s+([^\s]+)\s+ETA\s+([^\s]+)/i;
    const m = trimmed.match(re);
    if (m) {
      const percent = parseFloat(m[1]);
      return {
        type: 'progress',
        percent,
        downloaded: m[2],
        speed: m[3],
        eta: m[4],
        raw: trimmed,
      };
    }

    // Fallback: try to find percentage only
    const re2 = /([0-9.]+)%/;
    const m2 = trimmed.match(re2);
    if (m2) {
      return { type: 'progress', percent: parseFloat(m2[1]), raw: trimmed };
    }
  }

  // JSON metadata output or other informational lines
  if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
    try {
      const json = JSON.parse(trimmed);
      return { type: 'json', json };
    } catch (e) {
      // not JSON
    }
  }

  return { type: 'info', raw: trimmed };
}

/**
 * Run yt-dlp with given args and provide progress via onProgress callback.
 * @param {string[]} args
 * @param {object} [opts]
 * @param {(event:object)=>void} [opts.onProgress]
 * @param {number} [opts.timeoutMs]
 * @param {AbortSignal} [opts.signal]
 * @returns {Promise<{stdout:string, stderr:string, code:number, destinations:string[]}>}
 */
function runYtdlpProcess(args, opts = {}) {
  const { onProgress, timeoutMs, signal } = opts;
  const { args: builtArgs, ytdlpBin } = buildCommonArgs();
  const finalArgs = [...builtArgs, ...args];

  logger.info('Starting yt-dlp', { cmd: ytdlpBin, args: finalArgs });

  return new Promise((resolve, reject) => {
    let stdout = '';
    let stderr = '';
    const destinations = [];

    let killed = false;
    const child = spawn(ytdlpBin, finalArgs, { stdio: ['ignore', 'pipe', 'pipe'] });

    const rlOut = createInterface({ input: child.stdout });
    const rlErr = createInterface({ input: child.stderr });

    const onLine = (line) => {
      stdout += line + '\n';
      const ev = parseProgressLine(line);
      if (ev) {
        if (ev.type === 'destination' && ev.destination) destinations.push(ev.destination);
        try {
          if (onProgress && typeof onProgress === 'function') onProgress(ev);
        } catch (cbErr) {
          logger.warn('onProgress handler threw', { error: cbErr && cbErr.message });
        }
      }
    };

    rlOut.on('line', onLine);
    rlErr.on('line', (line) => {
      stderr += line + '\n';
      // Parse stderr lines similarly
      const ev = parseProgressLine(line);
      if (ev) {
        if (ev.type === 'destination' && ev.destination) destinations.push(ev.destination);
        try {
          if (onProgress && typeof onProgress === 'function') onProgress(ev);
        } catch (cbErr) {
          logger.warn('onProgress handler threw', { error: cbErr && cbErr.message });
        }
      }
    });

    let timeoutHandle = null;
    if (timeoutMs && timeoutMs > 0) {
      timeoutHandle = setTimeout(() => {
        killed = true;
        child.kill('SIGTERM');
        const err = new DownloadError('yt-dlp process timed out', { code: 'TIMEOUT', statusCode: 504 });
        logger.error('yt-dlp timed out', { timeoutMs });
        reject(err);
      }, timeoutMs);
    }

    const cleanup = () => {
      try {
        rlOut.close();
      } catch (e) {}
      try {
        rlErr.close();
      } catch (e) {}
      if (timeoutHandle) clearTimeout(timeoutHandle);
    };

    if (signal) {
      if (signal.aborted) {
        killed = true;
        child.kill('SIGTERM');
        cleanup();
        return reject(new DownloadError('Download aborted', { code: 'ABORTED', statusCode: 499 }));
      }
      const onAbort = () => {
        killed = true;
        child.kill('SIGTERM');
        cleanup();
        reject(new DownloadError('Download aborted by signal', { code: 'ABORTED', statusCode: 499 }));
      };
      signal.addEventListener('abort', onAbort, { once: true });
    }

    child.on('error', (err) => {
      cleanup();
      logger.error('yt-dlp child process error', { error: err && err.message });
      reject(new DownloadError('Failed to spawn yt-dlp process', { cause: err }));
    });

    child.on('close', (code, signal) => {
      cleanup();
      logger.info('yt-dlp finished', { code, signal });
      if (killed) return; // already rejected on timeout/abort
      if (code === 0) {
        resolve({ stdout, stderr, code, destinations });
      } else {
        const message = `yt-dlp exited with code ${code}`;
        logger.error(message, { stderr });
        reject(new DownloadError(message, { code: 'YTDLP_FAILED', statusCode: 502, cause: new Error(stderr || stdout) }));
      }
    });
  });
}

/**
 * Download a video using yt-dlp
 * @param {string} url
 * @param {object} [opts]
 * @param {string} [opts.outputDir]
 * @param {(event:object)=>void} [opts.onProgress]
 * @param {number} [opts.timeoutMs]
 * @param {AbortSignal} [opts.signal]
 * @returns {Promise<{destinations:string[]}>}
 */
export async function downloadVideo(url, opts = {}) {
  const safeUrl = validateUrl(url);
  const outputDir = opts.outputDir || process.env.DOWNLOAD_DIR || '.';
  // Ensure output dir exists
  try {
    fs.mkdirSync(outputDir, { recursive: true });
  } catch (e) {
    logger.warn('Could not create output dir', { path: outputDir, err: e && e.message });
  }

  const outTemplate = path.join(outputDir, '%(title)s-%(id)s.%(ext)s');
  const args = ['-o', outTemplate, safeUrl];

  // By default we want to download the best
  args.unshift('-f', opts.format || process.env.DEFAULT_FORMAT || 'best');

  try {
    const res = await runYtdlpProcess(args, { onProgress: opts.onProgress, timeoutMs: opts.timeoutMs, signal: opts.signal });
    return { destinations: res.destinations };
  } catch (err) {
    logger.error('downloadVideo failed', { url, error: err && err.message });
    throw err instanceof DownloadError ? err : new DownloadError('Video download failed', { cause: err });
  }
}

/**
 * Download audio-only (extract audio)
 * @param {string} url
 * @param {object} [opts]
 * @param {string} [opts.outputDir]
 * @param {string} [opts.audioFormat]
 * @param {(event:object)=>void} [opts.onProgress]
 * @param {number} [opts.timeoutMs]
 * @param {AbortSignal} [opts.signal]
 */
export async function downloadAudio(url, opts = {}) {
  const safeUrl = validateUrl(url);
  const outputDir = opts.outputDir || process.env.DOWNLOAD_DIR || '.';
  try {
    fs.mkdirSync(outputDir, { recursive: true });
  } catch (e) {
    logger.warn('Could not create output dir', { path: outputDir, err: e && e.message });
  }

  const outTemplate = path.join(outputDir, '%(title)s-%(id)s.%(ext)s');
  const audioFormat = opts.audioFormat || process.env.AUDIO_FORMAT || 'mp3';

  const args = ['-o', outTemplate, '--extract-audio', '--audio-format', audioFormat, '--embed-metadata', safeUrl];
  // prefer best audio
  args.unshift('-f', opts.format || process.env.DEFAULT_FORMAT || 'bestaudio');

  try {
    const res = await runYtdlpProcess(args, { onProgress: opts.onProgress, timeoutMs: opts.timeoutMs, signal: opts.signal });
    return { destinations: res.destinations };
  } catch (err) {
    logger.error('downloadAudio failed', { url, error: err && err.message });
    throw err instanceof DownloadError ? err : new DownloadError('Audio download failed', { cause: err });
  }
}

/**
 * Download a playlist (yt-dlp will detect if URL is a playlist). This function explicitly enables playlist behavior.
 * @param {string} url
 * @param {object} [opts]
 * @param {(event:object)=>void} [opts.onProgress]
 * @param {string} [opts.outputDir]
 * @param {number} [opts.timeoutMs]
 * @param {AbortSignal} [opts.signal]
 */
export async function downloadPlaylist(url, opts = {}) {
  const safeUrl = validateUrl(url);
  const outputDir = opts.outputDir || process.env.DOWNLOAD_DIR || '.';
  try {
    fs.mkdirSync(outputDir, { recursive: true });
  } catch (e) {
    logger.warn('Could not create output dir', { path: outputDir, err: e && e.message });
  }

  const outTemplate = path.join(outputDir, '%(playlist_index)s-%(title)s-%(id)s.%(ext)s');
  const args = ['--yes-playlist', '-o', outTemplate, safeUrl];
  args.unshift('-f', opts.format || process.env.DEFAULT_FORMAT || 'best');

  try {
    const res = await runYtdlpProcess(args, { onProgress: opts.onProgress, timeoutMs: opts.timeoutMs, signal: opts.signal });
    return { destinations: res.destinations };
  } catch (err) {
    logger.error('downloadPlaylist failed', { url, error: err && err.message });
    throw err instanceof DownloadError ? err : new DownloadError('Playlist download failed', { cause: err });
  }
}

/**
 * Extract metadata (JSON) for a given URL without downloading
 * @param {string} url
 * @param {object} [opts]
 * @param {AbortSignal} [opts.signal]
 * @param {number} [opts.timeoutMs]
 * @returns {Promise<object[]>} array of metadata objects (one per entry)
 */
export async function extractMetadata(url, opts = {}) {
  const safeUrl = validateUrl(url);
  const args = ['--dump-json', '--skip-download', safeUrl];
  try {
    const res = await runYtdlpProcess(args, { timeoutMs: opts.timeoutMs, signal: opts.signal });
    // parse JSON lines from stdout
    const lines = res.stdout.split(/\r?\n/).map((l) => l.trim()).filter(Boolean);
    const parsed = lines.map((l) => {
      try { return JSON.parse(l); } catch (e) { return { raw: l }; }
    });
    return parsed;
  } catch (err) {
    logger.error('extractMetadata failed', { url, error: err && err.message });
    throw err instanceof DownloadError ? err : new DownloadError('Metadata extraction failed', { cause: err });
  }
}

/**
 * List available formats for a given URL
 * @param {string} url
 * @param {object} [opts]
 * @param {AbortSignal} [opts.signal]
 * @param {number} [opts.timeoutMs]
 * @returns {Promise<string[]>} array of format lines
 */
export async function listFormats(url, opts = {}) {
  const safeUrl = validateUrl(url);
  const args = ['--list-formats', safeUrl];
  try {
    const res = await runYtdlpProcess(args, { timeoutMs: opts.timeoutMs, signal: opts.signal });
    const lines = res.stdout.split(/\r?\n/).map((l) => l.trim()).filter(Boolean);
    return lines;
  } catch (err) {
    logger.error('listFormats failed', { url, error: err && err.message });
    throw err instanceof DownloadError ? err : new DownloadError('Format listing failed', { cause: err });
  }
}

export default {
  downloadVideo,
  downloadAudio,
  downloadPlaylist,
  extractMetadata,
  listFormats,
  DownloadError,
};
