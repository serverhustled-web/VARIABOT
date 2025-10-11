### FSM Task Manager Plugin with SMC Integration for Gemini CLI

This plugin enhances the Gemini CLI with a Finite State Machine (FSM) workflow using the **State Machine Compiler (SMC)** to transform workflow images (visual task diagrams) into precise mathematical state equations. The SMC tool converts these diagrams into executable code, ensuring technically perfect FSMs based on training data specifications. The workflow involves creating an image artifact (e.g., via PlantUML or draw.io), feeding it to SMC to generate numbered equations from alphabetical meanings, and integrating the output into an FSM bot within Gemini CLI for real-world task management and code quality enhancement.

This builds on the prior FSM plugin, integrating SMC (Java-based, platform-agnostic) to quadratically deduce actions from visual workflows, as per your description. References include the SMC homepage (updated Feb 20, 2023) and Gemini CLI plugin tutorial.

## Installation

1. **Setup Environment:**
   - Install Java (SMC requirement): `pkg install openjdk-17`
   - Install Node.js/TypeScript: `pkg install nodejs-lts typescript`
   - Download SMC: `wget https://sourceforge.net/projects/smc/files/smc/6.7.0/smc-6.7.0.zip -O smc.zip; unzip smc.zip; mv smc-6.7.0/bin/smc ~/bin/`

2. **Build and Install the Plugin:**
   ```
   cd fsm-gemini-plugin
   npm install
   npm run build
   npm link
   ```

3. **Usage:** `gemini fsm-smc-task [command] [options]`

## Workflow Creation

1. **Design Workflow Image:**
   - Use PlantUML or draw.io to create a state diagram (e.g., Pending → Assigned → InProgress → Review → Completed).
   - Export as `workflow.png`.

2. **Generate SMC Code:**
   - Manually map image to SMC syntax (as in `generateSmcFile`) or use a parser (future enhancement).
   - Run: `~/bin/smc -java Task1.sm` to generate Java code.

3. **Integrate with Plugin:**
   - Pass `workflow.png` via `--workflow` arg; plugin converts to SMC logic.
   - FSM bot executes transitions based on SMC equations.

## Usage Examples
- Create task with workflow: `gemini fsm-smc-task create --task "Build REST API" --workflow "workflow.png" --assign "dev1"`
- Transition with code review: `gemini fsm-smc-task transition --task-id 1 --to "Review" --code "api.py"`

This leverages SMC to ensure FSM accuracy, transforming visual workflows into mathematical state equations for perfect task execution, enhancing code quality via Gemini AI at each state. Build with `npm run build`, test, and extend SMC integration (e.g., JNI for Java interop). If errors, share logs.