import * as path from 'node:path';
import * as vscode from 'vscode';

export async function exists(uri: vscode.Uri): Promise<boolean> {
  try {
    await vscode.workspace.fs.stat(uri);
    return true;
  } catch {
    return false;
  }
}

export async function findNearestPubspecDir(
  start: vscode.Uri,
): Promise<vscode.Uri | undefined> {
  // If start is a file, start from its directory.
  let current = start;
  try {
    const stat = await vscode.workspace.fs.stat(current);
    if (stat.type & vscode.FileType.File) {
      current = vscode.Uri.joinPath(current, '..');
    }
  } catch {
    // ignore
  }

  // Walk up to the filesystem root.
  while (true) {
    const pubspec = vscode.Uri.joinPath(current, 'pubspec.yaml');
    if (await exists(pubspec)) {
      return current;
    }

    const parentFsPath = path.dirname(current.fsPath);
    if (parentFsPath === current.fsPath) return undefined;
    current = vscode.Uri.file(parentFsPath);
  }
}

export function relPosix(fromFsPath: string, toFsPath: string): string {
  const rel = path.relative(fromFsPath, toFsPath);
  if (!rel) return '';
  return rel.split(path.sep).join('/');
}

