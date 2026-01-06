import { formatError } from './utils/errorFormatter';
import { getSequelize } from './utils/state';

import { handleReady } from './handlers/ready';
import { handleConnect } from './handlers/connect';
import { handleDefineModel } from './handlers/defineModel';
import { handleAssociateModel } from './handlers/associateModel';
import { handleFindAll } from './handlers/findAll';
import { handleFindOne } from './handlers/findOne';
import { handleCreate } from './handlers/create';
import { handleClose } from './handlers/close';
import { handleCount } from './handlers/count';
import { handleMax } from './handlers/max';
import { handleMin } from './handlers/min';
import { handleSum } from './handlers/sum';
import { handleIncrement } from './handlers/increment';
import { handleDecrement } from './handlers/decrement';

type JsonRpcRequest = {
  id: unknown;
  method: string;
  params?: any;
};

type JsonRpcResponse = {
  id: unknown;
  result?: any;
  error?: any;
};

async function handleRequest(request: JsonRpcRequest): Promise<void> {
  const { id, method, params } = request;

  try {
    let result: any;

    switch (method) {
      case 'ready':
        result = await handleReady();
        break;

      case 'connect':
        result = await handleConnect(params);
        break;

      case 'defineModel':
        result = await handleDefineModel(params);
        break;

      case 'associateModel':
        result = await handleAssociateModel(params);
        break;

      case 'findAll':
        result = await handleFindAll(params);
        break;

      case 'findOne':
        result = await handleFindOne(params);
        break;

      case 'create':
        result = await handleCreate(params);
        break;

      case 'count':
        result = await handleCount(params);
        break;

      case 'max':
        result = await handleMax(params);
        break;

      case 'min':
        result = await handleMin(params);
        break;

      case 'sum':
        result = await handleSum(params);
        break;

      case 'increment':
        result = await handleIncrement(params);
        break;

      case 'decrement':
        result = await handleDecrement(params);
        break;

      case 'close':
        result = await handleClose();
        break;

      default:
        throw new Error(`Unknown method: ${method}`);
    }

    const response: JsonRpcResponse = {
      id,
      result,
    };
    process.stdout.write(JSON.stringify(response) + '\n');
  } catch (error: any) {
    const response: JsonRpcResponse = {
      id,
      error: formatError(error),
    };
    process.stdout.write(JSON.stringify(response) + '\n');
  }
}

process.stdout.write(JSON.stringify({ id: 0, result: { ready: true } }) + '\n');

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
        handleRequest(request).catch((error: any) => {
          const errorResponse: JsonRpcResponse = {
            id: (request as any).id || null,
            error: formatError(error),
          };
          process.stdout.write(JSON.stringify(errorResponse) + '\n');
        });
      } catch (error: any) {
        const errorResponse: JsonRpcResponse = {
          id: null,
          error: {
            message: `Parse error: ${error.message}`,
            code: -32700,
          },
        };
        process.stdout.write(JSON.stringify(errorResponse) + '\n');
      }
    }
  }
});

async function cleanupAndExit(): Promise<void> {
  const sequelize = getSequelize();
  if (sequelize) {
    await sequelize.close();
  }
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
