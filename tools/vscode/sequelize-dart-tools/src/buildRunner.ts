import * as path from 'node:path';
import { spawn } from 'node:child_process';
import * as readline from 'node:readline';
import * as vscode from 'vscode';
import { exists, findNearestPubspecDir, relPosix } from './fsUtil';
import { loadConfigForPackage } from './config';

const OUTPUT_CHANNEL_NAME = 'Sequelize Dart Tools';

const runningByPackageRoot = new Map<string, Promise<number>>();

let outputChannelSingleton: vscode.OutputChannel | undefined;

function getOutputChannel(): vscode.OutputChannel {
  outputChannelSingleton ??= vscode.window.createOutputChannel(OUTPUT_CHANNEL_NAME);
  return outputChannelSingleton;
}

function nowStamp(): string {
  const d = new Date();
  const pad2 = (n: number) => String(n).padStart(2, '0');
  const pad3 = (n: number) => String(n).padStart(3, '0');
  return `${pad2(d.getHours())}:${pad2(d.getMinutes())}:${pad2(d.getSeconds())}.${pad3(d.getMilliseconds())}`;
}

function log(channel: vscode.OutputChannel, message: string): void {
  channel.appendLine(`[${nowStamp()}] ${message}`);
}

function logSection(channel: vscode.OutputChannel, title: string): void {
  channel.appendLine('');
  log(channel, `=== ${title} ===`);
}

type AnalyzerServerConfig = {
  command: string;
  args: string[];
  extraArgs: string[];
};

type AnalyzerServerProcess = {
  proc: ReturnType<typeof spawn>;
  pending: Array<{ resolve: (msg: any) => void; cancelled?: boolean }>;
};

const analyzerServerByPackageRoot = new Map<string, AnalyzerServerProcess>();

type RunUiMode = 'notification' | 'none';

type RunOptions = {
  ui?: RunUiMode;
  title?: string;
  token?: vscode.CancellationToken;
  progress?: vscode.Progress<{ message?: string; increment?: number }>;
};

function mergeToken(
  a: vscode.CancellationToken | undefined,
  b: vscode.CancellationToken | undefined,
): vscode.CancellationToken | undefined {
  if (!a) return b;
  if (!b) return a;
  // Both provided: create a derived token that cancels when either cancels.
  const src = new vscode.CancellationTokenSource();
  a.onCancellationRequested(() => src.cancel());
  b.onCancellationRequested(() => src.cancel());
  return src.token;
}

async function withOptionalProgress<T>(
  options: RunOptions | undefined,
  fallbackTitle: string,
  fn: (ctx: { token?: vscode.CancellationToken; progress?: vscode.Progress<{ message?: string }> }) => Promise<T>,
): Promise<T> {
  const ui = options?.ui ?? 'notification';
  if (ui === 'none') {
    return fn({ token: options?.token, progress: options?.progress });
  }

  const title = options?.title ?? fallbackTitle;
  return vscode.window.withProgress(
    { location: vscode.ProgressLocation.Notification, title, cancellable: true },
    async (progress, token) => {
      const merged = mergeToken(options?.token, token);
      return fn({ token: merged, progress });
    },
  );
}

export async function runBuildRunnerForFile(
  modelFileUri: vscode.Uri,
  options?: RunOptions,
): Promise<number> {
  return withOptionalProgress(options, 'Sequelize Dart: Generating model', async ({ token, progress }) => {
    progress?.report({ message: 'Preparing…' });

    const packageRoot = await findNearestPubspecDir(modelFileUri);
  if (!packageRoot) {
    vscode.window.showErrorMessage(
      'No pubspec.yaml found for this file. Run from a Dart package directory.',
    );
    return 1;
  }

  const { config } = await loadConfigForPackage(packageRoot);

  if (config.generator.mode === 'analyzerServer') {
      progress?.report({ message: 'Warming up analyzer server…' });
    const inputRel = relPosix(packageRoot.fsPath, modelFileUri.fsPath);
    if (!inputRel || inputRel.startsWith('..')) {
      vscode.window.showErrorMessage('Model file is outside package root.');
      return 1;
    }
    return runAnalyzerServer(packageRoot, config.analyzerServer, {
      cmd: 'generate',
      input: inputRel,
      }, { token, progress });
  }

  const modelDir = path.dirname(modelFileUri.fsPath);
  const basename = path.basename(modelFileUri.fsPath);
  const generatedBasename = basename.replace(/\.model\.dart$/, config.model.generatedExtension);
  const generatedPath = path.join(modelDir, generatedBasename);
  const filterRel = relPosix(packageRoot.fsPath, generatedPath);
  if (!filterRel) {
    vscode.window.showErrorMessage('Model file is outside package root.');
    return 1;
  }

    progress?.report({ message: 'Running build_runner…' });
    return runBuildRunner(packageRoot, config, [filterRel], { token, progress });
  });
}

export async function runBuildRunnerForFolder(
  folderUri: vscode.Uri,
  options?: RunOptions,
): Promise<number> {
  return withOptionalProgress(options, 'Sequelize Dart: Generating models', async ({ token, progress }) => {
    progress?.report({ message: 'Preparing…' });

    const packageRoot = await findNearestPubspecDir(folderUri);
    if (!packageRoot) {
      vscode.window.showErrorMessage(
        'No pubspec.yaml found for this folder. Run from a Dart package directory.',
      );
      return 1;
    }

    const { config } = await loadConfigForPackage(packageRoot);

    if (config.generator.mode === 'analyzerServer') {
      progress?.report({ message: 'Warming up analyzer server…' });
      const folderRel = relPosix(packageRoot.fsPath, folderUri.fsPath);
      if (folderRel === '' || folderRel.startsWith('..')) {
        vscode.window.showErrorMessage('Folder is outside package root.');
        return 1;
      }
      return runAnalyzerServer(packageRoot, config.analyzerServer, {
        cmd: 'generate',
        folder: folderRel,
      }, { token, progress });
    }

    const folderRel = relPosix(packageRoot.fsPath, folderUri.fsPath);
    if (folderRel === '' || folderRel.startsWith('..')) {
      vscode.window.showErrorMessage('Folder is outside package root.');
      return 1;
    }

    const filter = `${folderRel}/**/*${config.model.generatedExtension}`;
    progress?.report({ message: 'Running build_runner…' });
    return runBuildRunner(packageRoot, config, [filter], { token, progress });
  });
}

export async function runRegistryBuildForPackage(
  packageRoot: vscode.Uri,
  options?: RunOptions,
): Promise<number> {
  return withOptionalProgress(options, 'Sequelize Dart: Generating registry', async ({ token, progress }) => {
    progress?.report({ message: 'Scanning for *.registry.dart…' });
    const { config } = await loadConfigForPackage(packageRoot);

    if (config.generator.mode === 'analyzerServer') {
      progress?.report({ message: 'Warming up analyzer server…' });
      return runAnalyzerServer(
        packageRoot,
        config.analyzerServer,
        { cmd: 'registry' },
        { token, progress },
      );
    }

    const registryUris = await vscode.workspace.findFiles(
      new vscode.RelativePattern(packageRoot, '**/*.registry.dart'),
    );

    if (registryUris.length === 0) {
      const channel = getOutputChannel();
      logSection(channel, 'Registry');
      log(channel, `[Sequelize Dart] No *.registry.dart files found under: ${packageRoot.fsPath}`);
      return 0;
    }

    const outputFilters: string[] = [];
    for (const reg of registryUris) {
      const outFs = reg.fsPath.replace(/\.registry\.dart$/, '.dart');
      const rel = relPosix(packageRoot.fsPath, outFs);
      if (rel && !rel.startsWith('..')) {
        outputFilters.push(rel);
      }
    }

    if (outputFilters.length === 0) {
      const channel = getOutputChannel();
      logSection(channel, 'Registry');
      log(channel, `[Sequelize Dart] Registry files were outside package root. Skipping.`);
      return 0;
    }

    progress?.report({ message: 'Running build_runner for registry…' });

    // Always use build_runner for registry generation since it is a Builder.
    const code = await runBuildRunner(packageRoot, config, outputFilters, { token, progress, ui: 'none' });

    // If the expected `*.dart` outputs did not appear (but inputs exist), retry once.
    // This makes registry generation more reliable across intermittent build_runner hiccups/caching.
    if (code === 0) {
      const missing: string[] = [];
      for (const rel of outputFilters) {
        const outUri = vscode.Uri.joinPath(packageRoot, ...rel.split('/'));
        if (!(await exists(outUri))) missing.push(rel);
      }
      if (missing.length) {
        const channel = getOutputChannel();
        log(channel, `[Sequelize Dart] Registry outputs missing (${missing.length}); retrying once…`);
        return runBuildRunner(packageRoot, config, outputFilters, { token, progress, ui: 'none' });
      }
    }

    return code;
  });
}

async function runAnalyzerServer(
  packageRoot: vscode.Uri,
  serverConfig: AnalyzerServerConfig,
  request: Record<string, unknown>,
  options?: RunOptions,
): Promise<number> {
  const key = packageRoot.fsPath;
  const existing = runningByPackageRoot.get(key);
  if (existing) {
    await existing;
  }

  const run = async (): Promise<number> => {
    const channel = getOutputChannel();
    logSection(channel, 'Generate (analyzer server)');
    log(channel, `[Sequelize Dart] Using analyzer server`);

    options?.progress?.report({ message: 'Warming up analyzer server…' });
    const server = await getOrStartAnalyzerServer(packageRoot, serverConfig, channel);
    options?.progress?.report({ message: 'Analyzing & generating…' });
    const result = await sendAnalyzerRequest(server, request, options?.token);
    const ok = Boolean(result && typeof result === 'object' && (result as any).event === 'result' && (result as any).ok === true);
    if (!ok) {
      log(channel, `[Sequelize Dart] Analyzer server failed: ${JSON.stringify(result)}`);
    }
    return ok ? 0 : 1;
  };

  const promise = run().finally(() => {
    runningByPackageRoot.delete(key);
  });
  runningByPackageRoot.set(key, promise);
  return promise;
}

async function getOrStartAnalyzerServer(
  packageRoot: vscode.Uri,
  serverConfig: AnalyzerServerConfig,
  channel: vscode.OutputChannel,
): Promise<AnalyzerServerProcess> {
  const key = packageRoot.fsPath;
  const existing = analyzerServerByPackageRoot.get(key);
  if (existing) return existing;

  const args = [...serverConfig.args, ...serverConfig.extraArgs];
  logSection(channel, 'Warmup (analyzer server)');
  log(channel, `[Sequelize Dart] Starting analyzer server: ${serverConfig.command} ${args.join(' ')}`);
  log(channel, `  cwd: ${packageRoot.fsPath}`);

  const proc = spawn(serverConfig.command, args, {
    cwd: packageRoot.fsPath,
    shell: true,
    stdio: ['pipe', 'pipe', 'pipe'],
  });

  const server: AnalyzerServerProcess = { proc, pending: [] };
  analyzerServerByPackageRoot.set(key, server);

  proc.stderr?.on('data', (data: Buffer) => {
    channel.append(data.toString());
  });

  proc.on('close', (code, signal) => {
    analyzerServerByPackageRoot.delete(key);
    log(channel, `[Sequelize Dart] Analyzer server exited: ${code ?? signal}`);
    // Fail any pending requests.
    while (server.pending.length) {
      const entry = server.pending.shift()!;
      if (!entry.cancelled) {
        entry.resolve({ event: 'error', message: 'server exited' });
      }
    }
  });

  const rl = readline.createInterface({ input: proc.stdout! });
  const ready = new Promise<void>((resolve) => {
    rl.on('line', (line) => {
      const trimmed = line.trim();
      if (!trimmed) return;
      let msg: any;
      try {
        msg = JSON.parse(trimmed);
      } catch {
        log(channel, `[Sequelize Dart] [server] ${trimmed}`);
        return;
      }
      if (msg?.event === 'ready') {
        resolve();
        return;
      }
      if (msg?.event === 'result' || msg?.event === 'error') {
        const entry = server.pending.shift();
        if (entry && !entry.cancelled) entry.resolve(msg);
        return;
      }
      log(channel, `[Sequelize Dart] [server] ${trimmed}`);
    });
  });

  // Wait for ready or early exit.
  await Promise.race([
    ready,
    new Promise<void>((resolve) => proc.once('exit', () => resolve())),
  ]);

  return server;
}

function sendAnalyzerRequest(
  server: AnalyzerServerProcess,
  request: Record<string, unknown>,
  token?: vscode.CancellationToken,
): Promise<any> {
  return new Promise((resolve) => {
    const entry = { resolve, cancelled: false as boolean };
    server.pending.push(entry);
    token?.onCancellationRequested(() => {
      entry.cancelled = true;
      resolve({ event: 'error', message: 'cancelled' });
    });
    const line = JSON.stringify(request);
    server.proc.stdin?.write(line + '\n');
  });
}

async function runBuildRunner(
  packageRoot: vscode.Uri,
  config: { buildRunner: { command: string; args: string[]; extraArgs: string[] } },
  buildFilters: string[],
  options?: RunOptions,
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
      logSection(channel, 'Generate (build_runner)');
      log(channel, `[Sequelize Dart] Running: ${config.buildRunner.command} ${args.join(' ')}`);
      log(channel, `  cwd: ${packageRoot.fsPath}`);

      const proc = spawn(config.buildRunner.command, args, {
        cwd: packageRoot.fsPath,
        shell: true,
      });

      const cancelSub = options?.token?.onCancellationRequested(() => {
        log(channel, `[Sequelize Dart] Cancel requested, stopping build…`);
        try {
          proc.kill();
        } catch {}
      });

      proc.stdout?.on('data', (data: Buffer) => {
        channel.append(data.toString());
      });
      proc.stderr?.on('data', (data: Buffer) => {
        channel.append(data.toString());
      });

      proc.on('close', (code, signal) => {
        runningByPackageRoot.delete(key);
        cancelSub?.dispose();
        log(channel, `[Sequelize Dart] Exit: ${code ?? signal}`);
        resolve(code ?? 1);
      });

      proc.on('error', (err) => {
        runningByPackageRoot.delete(key);
        cancelSub?.dispose();
        log(channel, `[Sequelize Dart] Error: ${err.message}`);
        resolve(1);
      });
    });

  const promise = run();
  runningByPackageRoot.set(key, promise);
  return promise;
}
