/**
 * stdio version of the Sequelize bridge server.
 * This runs as a child process and communicates via stdin/stdout.
 * Used by Dart VM.
 */
import {
  processRequest,
  cleanup,
  JsonRpcRequest,
  JsonRpcResponse,
} from './request_handler';
import { setNotificationCallback } from './utils/state';

function sendResponse(response: JsonRpcResponse): void {
  process.stdout.write(JSON.stringify(response) + '\n');
}

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
