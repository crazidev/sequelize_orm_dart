import { sendNotification } from './state';

export function printLogs(sql: any) {
  sendNotification({
    notification: 'sql_log',
    sql: JSON.stringify(sql),
  });
}
