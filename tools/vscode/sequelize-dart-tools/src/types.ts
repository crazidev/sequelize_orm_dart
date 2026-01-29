export type SequelizeDartToolsConfig = {
  buildRunner?: {
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
  buildRunner: {
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

