/**
 * Worker Thread version of the Sequelize bridge server.
 * This runs in a Node.js Worker Thread and communicates via postMessage.
 * Used by dart2js compiled code.
 */
import { parentPort } from 'worker_threads';
import {
  processRequest,
  cleanup,
  JsonRpcRequest,
  JsonRpcResponse,
} from './request_handler';
import { setNotificationCallback } from './utils/state';

if (!parentPort) {
  throw new Error('This module must be run as a Worker Thread');
}

const port = parentPort;

// Set up notification callback for SQL logging (uses postMessage)
setNotificationCallback((notification) => {
  port.postMessage(notification);
});

// Send ready signal
port.postMessage({ id: 0, result: { ready: true } });

// Handle incoming messages
port.on('message', async (request: JsonRpcRequest) => {
  await processRequest(request, (response: JsonRpcResponse) => {
    port.postMessage(response);
  });
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
