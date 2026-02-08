/**
 * Unified Sequelize bridge server.
 * Works in two modes:
 * 1. stdio mode: Runs as a child process, communicates via stdin/stdout (Dart VM)
 * 2. worker mode: Runs in a Worker Thread, communicates via postMessage (dart2js)
 */
import { parentPort } from 'worker_threads';
import {
  processRequest,
  cleanup,
  JsonRpcRequest,
  JsonRpcResponse,
} from './request_handler';
import { setNotificationCallback } from './utils/state';

const isWorkerThread = parentPort !== null;

// Override console methods to send logs as notifications
import { format } from 'util';

const originalLog = console.log;
const originalInfo = console.info;
const originalWarn = console.warn;

function sendLog(level: string, args: any[]) {
  const message = format(...args);
  const notification = { notification: 'log', level, message };

  if (isWorkerThread) {
    parentPort!.postMessage(notification);
  } else {
    process.stdout.write(JSON.stringify(notification) + '\n');
  }
}

console.log = (...args: any[]) => sendLog('log', args);
console.info = (...args: any[]) => sendLog('info', args);
console.warn = (...args: any[]) => sendLog('warn', args);

type SendFunction = (response: JsonRpcResponse) => void;

let sendResponse: SendFunction;

if (isWorkerThread) {
  // Worker Thread mode (dart2js)
  const port = parentPort!;

  sendResponse = (response: JsonRpcResponse) => {
    port.postMessage(response);
  };

  // Set up notification callback for SQL logging (uses postMessage)
  setNotificationCallback((notification) => {
    port.postMessage(notification);
  });

  // Send ready signal
  port.postMessage({ id: 0, result: { ready: true } });

  // Handle incoming messages
  port.on('message', async (request: JsonRpcRequest) => {
    await processRequest(request, sendResponse);
  });

  // Cleanup on exit
  port.on('close', async () => {
    await cleanup();
  });

  // Handle errors
  process.on('uncaughtException', (error: Error) => {
    port.postMessage({
      id: null,
      error: {
        message: `Uncaught exception: ${error.message}`,
        stack: error.stack,
      },
    });
  });

  process.on('unhandledRejection', (reason: any) => {
    port.postMessage({
      id: null,
      error: {
        message: `Unhandled rejection: ${reason?.message || reason}`,
        stack: reason?.stack,
      },
    });
  });
} else {
  // stdio mode (Dart VM)
  sendResponse = (response: JsonRpcResponse) => {
    process.stdout.write(JSON.stringify(response) + '\n');
  };

  // Set up notification callback for SQL logging (uses same stdout channel)
  setNotificationCallback((notification) => {
    process.stdout.write(JSON.stringify(notification) + '\n');
  });

  // Send ready signal
  sendResponse({ id: 0, result: { ready: true } });

  let buffer = '';
  process.stdin.setEncoding('utf8');

  process.stdin.on('data', (chunk: string) => {
    buffer += chunk;
    const lines = buffer.split('\n');
    buffer = lines.pop() || '';

    for (const line of lines) {
      if (line.trim()) {
        try {
          const request = JSON.parse(line) as JsonRpcRequest;
          processRequest(request, sendResponse).catch((error: any) => {
            sendResponse({
              id: (request as any).id || null,
              error: {
                message: `Handler error: ${error.message}`,
                stack: error.stack,
              },
            });
          });
        } catch (error: any) {
          sendResponse({
            id: null,
            error: {
              message: `Parse error: ${error.message}`,
              code: -32700,
            },
          });
        }
      }
    }
  });

  async function cleanupAndExit(): Promise<void> {
    await cleanup();
    process.exit(0);
  }

  process.stdin.on('end', () => {
    cleanupAndExit().catch(() => process.exit(0));
  });

  process.on('SIGTERM', () => {
    cleanupAndExit().catch(() => process.exit(0));
  });

  process.on('SIGINT', () => {
    cleanupAndExit().catch(() => process.exit(0));
  });
}
