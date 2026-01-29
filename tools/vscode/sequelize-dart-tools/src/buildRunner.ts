import * as path from 'node:path';
import { spawn } from 'node:child_process';
import * as vscode from 'vscode';
import { findNearestPubspecDir, relPosix } from './fsUtil';
import { loadConfigForPackage } from './config';

const OUTPUT_CHANNEL_NAME = 'Sequelize Dart Tools';

const runningByPackageRoot = new Map<string, Promise<number>>();

function getOutputChannel(): vscode.OutputChannel {
  return vscode.window.createOutputChannel(OUTPUT_CHANNEL_NAME);
}

export async function runBuildRunnerForFile(
  modelFileUri: vscode.Uri,
): Promise<number> {
  const packageRoot = await findNearestPubspecDir(modelFileUri);
  if (!packageRoot) {
    vscode.window.showErrorMessage(
      'No pubspec.yaml found for this file. Run from a Dart package directory.',
    );
    return 1;
  }

  const { config } = await loadConfigForPackage(packageRoot);
  const modelDir = path.dirname(modelFileUri.fsPath);
  const basename = path.basename(modelFileUri.fsPath);
  const generatedBasename = basename.replace(/\.model\.dart$/, config.model.generatedExtension);
  const generatedPath = path.join(modelDir, generatedBasename);
  const filterRel = relPosix(packageRoot.fsPath, generatedPath);
  if (!filterRel) {
    vscode.window.showErrorMessage('Model file is outside package root.');
    return 1;
  }

  return runBuildRunner(packageRoot, config, [filterRel]);
}

export async function runBuildRunnerForFolder(
  folderUri: vscode.Uri,
): Promise<number> {
  const packageRoot = await findNearestPubspecDir(folderUri);
  if (!packageRoot) {
    vscode.window.showErrorMessage(
      'No pubspec.yaml found for this folder. Run from a Dart package directory.',
    );
    return 1;
  }

  const { config } = await loadConfigForPackage(packageRoot);
  const folderRel = relPosix(packageRoot.fsPath, folderUri.fsPath);
  if (folderRel === '' || folderRel.startsWith('..')) {
    vscode.window.showErrorMessage('Folder is outside package root.');
    return 1;
  }

  const filter = `${folderRel}/**/*${config.model.generatedExtension}`;
  return runBuildRunner(packageRoot, config, [filter]);
}

async function runBuildRunner(
  packageRoot: vscode.Uri,
  config: { buildRunner: { command: string; args: string[]; extraArgs: string[] } },
  buildFilters: string[],
): Promise<number> {
  const key = packageRoot.fsPath;
  const existing = runningByPackageRoot.get(key);
  if (existing) {
    await existing;
  }

  const run = (): Promise<number> =>
    new Promise((resolve) => {
      const args = [
        ...config.buildRunner.args,
        ...config.buildRunner.extraArgs,
        ...buildFilters.flatMap((f) => ['--build-filter', f]),
      ];

      const channel = getOutputChannel();
      channel.appendLine(`[Sequelize Dart] Running: ${config.buildRunner.command} ${args.join(' ')}`);
      channel.appendLine(`  cwd: ${packageRoot.fsPath}`);
      channel.show(true);

      const proc = spawn(config.buildRunner.command, args, {
        cwd: packageRoot.fsPath,
        shell: true,
      });

      proc.stdout?.on('data', (data: Buffer) => {
        channel.append(data.toString());
      });
      proc.stderr?.on('data', (data: Buffer) => {
        channel.append(data.toString());
      });

      proc.on('close', (code, signal) => {
        runningByPackageRoot.delete(key);
        channel.appendLine(`\n[Sequelize Dart] Exit: ${code ?? signal}`);
        resolve(code ?? 1);
      });

      proc.on('error', (err) => {
        runningByPackageRoot.delete(key);
        channel.appendLine(`[Sequelize Dart] Error: ${err.message}`);
        resolve(1);
      });
    });

  const promise = run();
  runningByPackageRoot.set(key, promise);
  return promise;
}
