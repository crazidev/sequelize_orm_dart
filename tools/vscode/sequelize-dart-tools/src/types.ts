export type SequelizeDartToolsConfig = {
  generator?: {
    mode?: 'buildRunner' | 'analyzerServer';
  };
  buildRunner?: {
    command?: string;
    args?: string[];
    extraArgs?: string[];
  };
  analyzerServer?: {
    command?: string;
    args?: string[];
    extraArgs?: string[];
  };
  model?: {
    includeGlobs?: string[];
    generatedExtension?: string;
    partDirectiveRequired?: boolean;
    configFileNames?: string[];
  };
};

export type ResolvedConfig = {
  generator: {
    mode: 'buildRunner' | 'analyzerServer';
  };
  buildRunner: {
    command: string;
    args: string[];
    extraArgs: string[];
  };
  analyzerServer: {
    command: string;
    args: string[];
    extraArgs: string[];
  };
  model: {
    includeGlobs: string[];
    generatedExtension: string;
    partDirectiveRequired: boolean;
    configFileNames: string[];
  };
};

