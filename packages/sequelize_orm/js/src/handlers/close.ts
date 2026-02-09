import { clearState, getSequelize } from '../utils/state';

export async function handleClose(): Promise<{ closed: true }> {
  const sequelize = getSequelize();
  if (sequelize) {
    await sequelize.close();
    clearState();
  }
  return { closed: true };
}
