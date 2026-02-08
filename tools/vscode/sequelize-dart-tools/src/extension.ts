import * as path from 'node:path';
import * as vscode from 'vscode';
import { runBuildRunnerForFile, runBuildRunnerForFolder, runRegistryBuildForPackage } from './buildRunner';
import { loadConfigForPackage } from './config';
import { exists, findNearestPubspecDir } from './fsUtil';
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

      const packageRoot = await findNearestPubspecDir(target);
      if (!packageRoot) {
        vscode.window.showErrorMessage('No pubspec.yaml found for this file.');
        return;
      }
      const { config } = await loadConfigForPackage(packageRoot);
      await ensureModelHasExpectedPartDirective(target, config.model.generatedExtension);

      const code = await runBuildRunnerForFile(target, { ui: 'notification' });
      if (code === 0) {
        // Keep registry in sync when generating a single file too.
        await runRegistryBuildForPackage(packageRoot, {
          ui: 'notification',
          title: 'Sequelize Dart: Generating registry',
        });
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

      // Ensure part directives exist before invoking generators.
      const packageRoot = await findNearestPubspecDir(folderUri);
      if (!packageRoot) {
        vscode.window.showErrorMessage('No pubspec.yaml found for this folder.');
        return;
      }
      const { config } = await loadConfigForPackage(packageRoot);
      const modelUris = await vscode.workspace.findFiles(new vscode.RelativePattern(folderUri, '**/*.model.dart'));
      for (const modelUri of modelUris) {
        await ensureModelHasExpectedPartDirective(modelUri, config.model.generatedExtension);
      }

      const code = await runBuildRunnerForFolder(folderUri, { ui: 'notification' });
      if (code === 0) {
        await runRegistryBuildForPackage(packageRoot, {
          ui: 'notification',
          title: 'Sequelize Dart: Generating registry',
        });
        vscode.window.showInformationMessage('Models generated successfully.');
        await refreshAllDiagnostics();
      } else {
        vscode.window.showErrorMessage('Model generation failed. Check the output channel.');
      }
    }),
  );

  context.subscriptions.push(
    vscode.commands.registerCommand('sequelizeDart.generateRegistry', async (uri?: vscode.Uri) => {
      const target = uri ?? vscode.window.activeTextEditor?.document?.uri;
      if (!target) {
        vscode.window.showErrorMessage('Please run this command on a folder or a Dart file.');
        return;
      }
      const packageRoot = await import('./fsUtil').then((m) => m.findNearestPubspecDir(target));
      if (!packageRoot) {
        vscode.window.showErrorMessage('No pubspec.yaml found for this file/folder.');
        return;
      }
      const code = await runRegistryBuildForPackage(packageRoot, { ui: 'notification' });
      if (code === 0) {
        vscode.window.showInformationMessage('Registry generated successfully.');
      } else {
        vscode.window.showErrorMessage('Registry generation failed. Check the output channel.');
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

async function ensureModelHasExpectedPartDirective(
  modelUri: vscode.Uri,
  generatedExtension: string,
): Promise<void> {
  const doc = await vscode.workspace.openTextDocument(modelUri);
  const text = doc.getText();

  const expectedBasename = getExpectedGeneratedBasenameFallback(
    path.basename(modelUri.fsPath),
    generatedExtension,
  );
  const expectedDirective = `part '${expectedBasename}';`;

  const edit = new vscode.WorkspaceEdit();

  // If there is already a matching part directive, do nothing.
  // If there is a `*.g.dart` part directive but with a different basename, replace it.
  const partRe = /^\s*part\s+['"]([^'"]+)['"]\s*;\s*$/gm;
  let replaceMatch: { index: number; full: string; basename: string } | undefined;
  for (let m = partRe.exec(text); m; m = partRe.exec(text)) {
    const basename = m[1] ?? '';
    if (basename === expectedBasename) return;
    if (
      !replaceMatch &&
      (basename.endsWith(generatedExtension) || basename.endsWith('.g.dart'))
    ) {
      replaceMatch = { index: m.index, full: m[0] ?? '', basename };
    }
  }

  if (replaceMatch) {
    const start = doc.positionAt(replaceMatch.index);
    const end = doc.positionAt(replaceMatch.index + replaceMatch.full.length);
    edit.replace(modelUri, new vscode.Range(start, end), expectedDirective);
    await vscode.workspace.applyEdit(edit);
    return;
  }

  // Otherwise, insert it after imports/exports/library/part-of (or after leading header comments).
  const insertOffset = findPartDirectiveInsertOffset(text);
  const insertPos = doc.positionAt(insertOffset);
  const after = text.slice(insertOffset);
  const snippet = after.length === 0 || after.startsWith('\n') || after.startsWith('\r\n')
    ? `${expectedDirective}\n`
    : `${expectedDirective}\n\n`;
  edit.insert(modelUri, insertPos, snippet);
  await vscode.workspace.applyEdit(edit);
}

function findPartDirectiveInsertOffset(text: string): number {
  const directiveRe = /^\s*(?:library|import|export|part of)\b.*$/gm;
  let last: RegExpExecArray | null = null;
  for (let m = directiveRe.exec(text); m; m = directiveRe.exec(text)) {
    last = m;
  }

  if (last?.index != null) {
    const lineEnd = text.indexOf('\n', last.index + last[0].length);
    return lineEnd === -1 ? text.length : lineEnd + 1;
  }

  // No directives: put it after a leading header comment (/* ... */) and/or //-comments/blank lines.
  let i = 0;
  if (text.startsWith('/*')) {
    const end = text.indexOf('*/');
    if (end !== -1) {
      i = end + 2;
      // If the block comment ends mid-line, jump to the next line.
      const nl = text.indexOf('\n', i);
      i = nl === -1 ? text.length : nl + 1;
    }
  }

  while (i < text.length) {
    const lineEnd = text.indexOf('\n', i);
    const end = lineEnd === -1 ? text.length : lineEnd;
    const line = text.slice(i, end);
    const t = line.trim();
    if (t === '' || t.startsWith('//')) {
      i = lineEnd === -1 ? text.length : lineEnd + 1;
      continue;
    }
    break;
  }

  return i;
}
