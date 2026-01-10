import { formatError } from './utils/errorFormatter';
import { getSequelize, getOptions } from './utils/state';

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

export type JsonRpcRequest = {
  id: unknown;
  method: string;
  params?: any;
};

export type JsonRpcResponse = {
  id: unknown;
  result?: any;
  error?: any;
  notification?: string;
  sql?: string;
};

export type ResponseCallback = (response: JsonRpcResponse) => void;

/**
 * Process a JSON-RPC request and return the response via callback.
 * This is shared between stdio bridge and worker thread bridge.
 */
export async function processRequest(
  request: JsonRpcRequest,
  sendResponse: ResponseCallback,
): Promise<void> {
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

    sendResponse({ id, result });
  } catch (error: any) {
    sendResponse({ id, error: formatError(error) });
  }
}

/**
 * Cleanup sequelize connection
 */
export async function cleanup(): Promise<void> {
  const sequelize = getSequelize();
  if (sequelize) {
    await sequelize.close();
  }
}
