import * as path from 'node:path';
import * as vscode from 'vscode';
import { runBuildRunnerForFile, runBuildRunnerForFolder } from './buildRunner';
import { loadConfigForPackage } from './config';
import { exists } from './fsUtil';
import {
  isModelDartFileUri,
  getExpectedGeneratedBasenameFromPartDirective,
  getExpectedGeneratedBasenameFallback,
  findFirstTableClassNameRange,
} from './modelParser';

const DIAGNOSTIC_SOURCE = 'sequelize-dart';
const DIAGNOSTIC_CODE_MISSING = 'sequelize-dart/missing-generated';

let diagnosticCollection: vscode.DiagnosticCollection;

export function activate(context: vscode.ExtensionContext): void {
  diagnosticCollection = vscode.languages.createDiagnosticCollection(DIAGNOSTIC_SOURCE);
  context.subscriptions.push(diagnosticCollection);

  context.subscriptions.push(
    vscode.commands.registerCommand('sequelizeDart.generateModelForFile', async (uri?: vscode.Uri) => {
      const target = uri ?? vscode.window.activeTextEditor?.document?.uri;
      if (!target?.fsPath.endsWith('.model.dart')) {
        vscode.window.showErrorMessage('Please run this command on a *.model.dart file.');
        return;
      }
      const code = await runBuildRunnerForFile(target);
      if (code === 0) {
        vscode.window.showInformationMessage('Model generated successfully.');
        await refreshDiagnosticsForUri(target);
      } else {
        vscode.window.showErrorMessage('Model generation failed. Check the output channel.');
      }
    }),
  );

  context.subscriptions.push(
    vscode.commands.registerCommand('sequelizeDart.generateModelsForFolder', async (uri?: vscode.Uri) => {
      let folderUri = uri;
      if (folderUri?.fsPath.endsWith('.model.dart')) {
        folderUri = vscode.Uri.file(path.dirname(folderUri.fsPath));
      } else if (!folderUri) {
        const editor = vscode.window.activeTextEditor;
        if (editor?.document.uri.fsPath.endsWith('.model.dart')) {
          folderUri = vscode.Uri.file(path.dirname(editor.document.uri.fsPath));
        } else {
          vscode.window.showErrorMessage('Please right-click a folder or a *.model.dart file.');
          return;
        }
      }
      if (!folderUri) {
        vscode.window.showErrorMessage('Please right-click a folder or a *.model.dart file.');
        return;
      }
      const code = await runBuildRunnerForFolder(folderUri);
      if (code === 0) {
        vscode.window.showInformationMessage('Models generated successfully.');
        await refreshAllDiagnostics();
      } else {
        vscode.window.showErrorMessage('Model generation failed. Check the output channel.');
      }
    }),
  );

  context.subscriptions.push(
    vscode.languages.registerCodeActionsProvider(
      { language: 'dart', pattern: '**/*.model.dart' },
      new SequelizeDartCodeActionProvider(),
      { providedCodeActionKinds: [vscode.CodeActionKind.QuickFix] },
    ),
  );

  const safeRefresh = (fn: () => Promise<void>) => () => fn().catch(() => {});
  context.subscriptions.push(
    vscode.workspace.onDidOpenTextDocument((doc) => {
      if (isModelDartFileUri(doc.uri)) safeRefresh(() => refreshDiagnosticsForUri(doc.uri))();
    }),
  );
  context.subscriptions.push(
    vscode.workspace.onDidSaveTextDocument((doc) => {
      if (isModelDartFileUri(doc.uri)) safeRefresh(() => refreshDiagnosticsForUri(doc.uri))();
    }),
  );
  context.subscriptions.push(
    vscode.workspace.onDidChangeTextDocument((e) => {
      if (isModelDartFileUri(e.document.uri)) safeRefresh(() => refreshDiagnosticsForUri(e.document.uri))();
    }),
  );

  const watcher = vscode.workspace.createFileSystemWatcher('**/*.model.g.dart');
  watcher.onDidCreate(safeRefresh(refreshAllDiagnostics));
  watcher.onDidDelete(safeRefresh(refreshAllDiagnostics));
  watcher.onDidChange(safeRefresh(refreshAllDiagnostics));
  context.subscriptions.push(watcher);

  if (vscode.workspace.workspaceFolders?.length) {
    refreshAllDiagnostics();
  }
}

export function deactivate(): void {
  diagnosticCollection?.dispose();
}

async function refreshAllDiagnostics(): Promise<void> {
  if (!vscode.workspace.workspaceFolders?.length) return;
  diagnosticCollection.clear();
  const files = await vscode.workspace.findFiles('**/*.model.dart');
  for (const uri of files) {
    await refreshDiagnosticsForUri(uri);
  }
}

async function refreshDiagnosticsForUri(modelUri: vscode.Uri): Promise<void> {
  if (!isModelDartFileUri(modelUri)) return;

  const packageRoot = await import('./fsUtil').then((m) => m.findNearestPubspecDir(modelUri));
  if (!packageRoot) return;

  const { config } = await loadConfigForPackage(packageRoot);
  const doc = vscode.workspace.textDocuments.find((d) => d.uri.toString() === modelUri.toString());
  const text = doc ? doc.getText() : (await vscode.workspace.fs.readFile(modelUri)).toString();

  const partBasename = getExpectedGeneratedBasenameFromPartDirective(text);
  const basename = path.basename(modelUri.fsPath);
  const expectedBasename = partBasename ?? getExpectedGeneratedBasenameFallback(basename, config.model.generatedExtension);
  const generatedUri = vscode.Uri.joinPath(vscode.Uri.file(path.dirname(modelUri.fsPath)), expectedBasename);

  const generatedExists = await exists(generatedUri);
  let outdated = false;
  if (generatedExists) {
    try {
      const [modelStat, genStat] = await Promise.all([
        vscode.workspace.fs.stat(modelUri),
        vscode.workspace.fs.stat(generatedUri),
      ]);
      outdated = (modelStat.mtime ?? 0) > (genStat.mtime ?? 0);
    } catch {
      outdated = false;
    }
  }

  if (!generatedExists || outdated) {
    const range = findFirstTableClassNameRange(
      doc ?? (await vscode.workspace.openTextDocument(modelUri)),
    );
    if (range) {
      const msg = generatedExists
        ? `Generated file is outdated. Run 'Generate model' to regenerate.`
        : `Generated file '${expectedBasename}' is missing. Run 'Generate model' to create it.`;
      const diag = new vscode.Diagnostic(range.range, msg, vscode.DiagnosticSeverity.Information);
      diag.code = DIAGNOSTIC_CODE_MISSING;
      diagnosticCollection.set(modelUri, [diag]);
    } else {
      diagnosticCollection.delete(modelUri);
    }
  } else {
    diagnosticCollection.delete(modelUri);
  }
}

class SequelizeDartCodeActionProvider implements vscode.CodeActionProvider {
  provideCodeActions(
    document: vscode.TextDocument,
    range: vscode.Range | vscode.Selection,
    context: vscode.CodeActionContext,
  ): vscode.CodeAction[] {
    const diagnostics = context.diagnostics.filter((d) => {
      const c = d.code;
      return c === DIAGNOSTIC_CODE_MISSING || (typeof c === 'object' && c?.value === DIAGNOSTIC_CODE_MISSING);
    });
    if (diagnostics.length === 0) return [];

    const action = new vscode.CodeAction('Generate model', vscode.CodeActionKind.QuickFix);
    action.diagnostics = diagnostics;
    action.command = {
      command: 'sequelizeDart.generateModelForFile',
      title: 'Generate model',
      arguments: [document.uri],
    };
    return [action];
  }
}
