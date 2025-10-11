import { CommandHandler, CommandArgs, PluginContext, CommandResult } from 'types/index';
import { SmcProcessor } from '../utils/smc';
import * as fs from 'fs';
import * as path from 'path';

const smc = new SmcProcessor();

export const fsmSmcTaskCommand: CommandHandler = async (
  args: CommandArgs,
  context: PluginContext
): Promise<CommandResult> => {
  try {
    const subcommand = args._[0];

    switch (subcommand) {
      case 'create': {
        const { task, workflow, assign } = args;
        if (!task || !workflow) throw new Error('Task and workflow image required');

        const taskId = smc.createTask(task, assign, workflow);
        const prompt = smc.generatePrompt(taskId);

        const aiResponse = await context.gemini.generate({
          prompt,
          model: 'gemini-pro',
          temperature: 0.7
        });

        smc.updateTask(taskId, 'Generated', aiResponse.text);

        return {
          success: true,
          data: { taskId, initialOutput: aiResponse.text },
          output: `Task ${taskId} created for ${assign}. Initial AI output: ${aiResponse.text}`
        };
      }

      case 'transition': {
        const { taskId, to, code } = args;
        if (!taskId || !to) throw new Error('Task ID and target state required');

        if (code) {
          const codeContent = fs.readFileSync(path.resolve(code), 'utf8');
          const reviewPrompt = smc.buildReviewPrompt(taskId, codeContent);

          const review = await context.gemini.generate({
            prompt: reviewPrompt,
            model: 'gemini-pro',
            temperature: 0.3
          });

          smc.transitionState(taskId, to, review.text);

          return {
            success: true,
            data: { state: to, review: review.text },
            output: `Task ${taskId} transitioned to ${to}. Review: ${review.text}`
          };
        } else {
          smc.transitionState(taskId, to);
          return {
            success: true,
            output: `Task ${taskId} transitioned to ${to}`
          };
        }
      }

      default:
        throw new Error(`Unknown subcommand: ${subcommand}`);
    }
  } catch (e: unknown) {
    const error = e as Error;
    return {
      success: false,
      error: error.message
    };
  }
};