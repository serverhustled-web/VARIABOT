export interface CommandArgs {
  [key: string]: any;
  _: string[];
}

// Simplified local type definitions to match the expected structure
// This avoids issues with missing exports from the actual @google/gemini-cli package
export interface GeminiCLI {
  generate: (options: any) => Promise<{ text: string }>;
}

export interface Logger {
  info: (msg: string) => void;
  debug: (msg: string) => void;
  warn: (msg: string) => void;
  error: (msg: string) => void;
}

export interface Plugin {
    name: string;
    version: string;
    initialize(context: PluginContext): Promise<void>;
}

export interface PluginContext {
  gemini: GeminiCLI;
  logger: Logger;
  registerCommand: (name: string, handler: CommandHandler) => void;
  registerHook: (name: string, handler: Function) => void;
}

export type CommandHandler = (args: CommandArgs, context: PluginContext) => Promise<CommandResult>;

export interface CommandResult {
  success: boolean;
  data?: any;
  output?: string;
  error?: string;
}