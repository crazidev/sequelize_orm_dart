import { getSequelize } from '../utils/state';

type SyncParams = {
    force?: boolean;
    alter?: boolean;
};

export async function handleSync(params: SyncParams): Promise<{ synced: true }> {
    const sequelize = getSequelize();
    if (!sequelize) {
        throw new Error('Not connected. Call connect first.');
    }

    await sequelize.sync({
        force: params.force === true,
        alter: params.alter === true,
    });

    return { synced: true };
}
