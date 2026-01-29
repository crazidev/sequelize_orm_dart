import * as vscode from 'vscode';

export function isModelDartFileUri(uri: vscode.Uri): boolean {
  return uri.fsPath.endsWith('.model.dart');
}

export function getExpectedGeneratedBasenameFromPartDirective(
  text: string,
): string | undefined {
  // Example: part 'users.model.g.dart';
  const m = /part\s+['"]([^'"]+\.model\.g\.dart)['"]\s*;/.exec(text);
  return m?.[1];
}

export function getExpectedGeneratedBasenameFallback(
  modelFileName: string,
  generatedExtension: string,
): string {
  // modelFileName is basename (e.g. users.model.dart)
  if (modelFileName.endsWith('.model.dart')) {
    return modelFileName.replace(/\.model\.dart$/, generatedExtension);
  }
  return `${modelFileName}${generatedExtension}`;
}

export function findFirstTableClassNameRange(
  document: vscode.TextDocument,
): { className: string; range: vscode.Range } | undefined {
  const text = document.getText();

  // Find @Table ... class Foo (or abstract class Foo). We keep it heuristic (fast + robust).
  const re = /@Table[\s\S]*?\b(?:abstract\s+)?class\s+([A-Za-z_]\w*)/m;
  const m = re.exec(text);
  if (!m || m.index == null) return undefined;

  const className = m[1]!;
  const classNameOffset = m.index + m[0].lastIndexOf(className);
  const start = document.positionAt(classNameOffset);
  const end = document.positionAt(classNameOffset + className.length);
  return { className, range: new vscode.Range(start, end) };
}

