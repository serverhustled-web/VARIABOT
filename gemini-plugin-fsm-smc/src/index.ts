import { Plugin, PluginContext } from '@google/gemini-cli';
import { fsmSmcTaskCommand } from './commands/fsm-smc-task';
import { SmcProcessor } from './utils/smc';

export default class FsmSmcPlugin implements Plugin {
  name = 'fsm-smc-task';
  version = '1.0.0';

  private smc = new SmcProcessor();

  async initialize(context: PluginContext): Promise<void> {
    context.logger.info('Initializing FSM-SMC Task Manager Plugin...');

    context.registerCommand('fsm-smc-task', fsmSmcTaskCommand);
    context.registerHook('pre-generate', this.preGenerateHook);
    context.registerHook('post-analyze', this.postAnalyzeHook);
  }

  private async preGenerateHook(context: PluginContext, args: any): Promise<void> {
    context.logger.debug('Pre-generate hook: Processing SMC workflow');
    const taskId = args.taskId;
    if (taskId) await this.smc.ensureState(taskId);
  }

  private async postAnalyzeHook(context: PluginContext, result: any): Promise<void> {
    context.logger.debug('Post-analyze hook: Updating SMC state');
    const taskId = result.taskId;
    if (taskId) await this.smc.transitionState(taskId, 'Review', result.text);
  }
}