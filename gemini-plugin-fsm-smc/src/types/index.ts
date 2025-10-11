export interface CommandArgs {
  [key: string]: any;
  _: string[];
}

export interface PluginContext {
  gemini: { generate: (options: any) => Promise<{ text: string }> };
  logger: { info: (msg: string) => void; debug: (msg: string) => void; warn: (msg: string) => void; error: (msg: string) => void };
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