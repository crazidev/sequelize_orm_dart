import * as vscode from 'vscode';
import { parse as parseYaml } from 'yaml';
import { exists } from './fsUtil';
import type { ResolvedConfig, SequelizeDartToolsConfig } from './types';

const DEFAULT_CONFIG: ResolvedConfig = {
  buildRunner: {
    command: 'dart',
    args: ['run', 'build_runner', 'build', '--delete-conflicting-outputs'],
    extraArgs: [],
  },
  model: {
    includeGlobs: ['**/*.model.dart'],
    generatedExtension: '.model.g.dart',
    partDirectiveRequired: true,
    configFileNames: ['sequelize_dart.yaml', 'sequelize_dart_tools.yaml'],
  },
};

function isStringArray(value: unknown): value is string[] {
  return Array.isArray(value) && value.every((v) => typeof v === 'string');
}

function mergeConfig(user: SequelizeDartToolsConfig | undefined): ResolvedConfig {
  const cfg: ResolvedConfig = JSON.parse(JSON.stringify(DEFAULT_CONFIG));
  if (!user) return cfg;

  if (user.buildRunner?.command && typeof user.buildRunner.command === 'string') {
    cfg.buildRunner.command = user.buildRunner.command;
  }
  if (isStringArray(user.buildRunner?.args)) {
    cfg.buildRunner.args = user.buildRunner!.args!;
  }
  if (isStringArray(user.buildRunner?.extraArgs)) {
    cfg.buildRunner.extraArgs = user.buildRunner!.extraArgs!;
  }

  if (isStringArray(user.model?.includeGlobs)) {
    cfg.model.includeGlobs = user.model!.includeGlobs!;
  }
  if (user.model?.generatedExtension && typeof user.model.generatedExtension === 'string') {
    cfg.model.generatedExtension = user.model.generatedExtension;
  }
  if (typeof user.model?.partDirectiveRequired === 'boolean') {
    cfg.model.partDirectiveRequired = user.model.partDirectiveRequired;
  }
  if (isStringArray(user.model?.configFileNames)) {
    cfg.model.configFileNames = user.model!.configFileNames!;
  }

  return cfg;
}

export async function loadConfigForPackage(
  packageRoot: vscode.Uri,
): Promise<{ config: ResolvedConfig; configPath?: vscode.Uri }> {
  // Per plan: look for config adjacent to nearest pubspec; fallback to workspace root.
  for (const name of DEFAULT_CONFIG.model.configFileNames) {
    const candidate = vscode.Uri.joinPath(packageRoot, name);
    if (await exists(candidate)) {
      const raw = await vscode.workspace.fs.readFile(candidate);
      const parsed = parseYaml(Buffer.from(raw).toString('utf8')) as unknown;
      return { config: mergeConfig(parsed as SequelizeDartToolsConfig), configPath: candidate };
    }
  }

  const wsFolder = vscode.workspace.getWorkspaceFolder(packageRoot);
  if (wsFolder) {
    for (const name of DEFAULT_CONFIG.model.configFileNames) {
      const candidate = vscode.Uri.joinPath(wsFolder.uri, name);
      if (await exists(candidate)) {
        const raw = await vscode.workspace.fs.readFile(candidate);
        const parsed = parseYaml(Buffer.from(raw).toString('utf8')) as unknown;
        return { config: mergeConfig(parsed as SequelizeDartToolsConfig), configPath: candidate };
      }
    }
  }

  return { config: mergeConfig(undefined) };
}

