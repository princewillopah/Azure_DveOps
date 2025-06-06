
# Sample YAML Pipeline for a Self-Hosted Agent

Below is a sample `azure-pipelines.yml` for a Node.js project running on your self-hosted agent pool. It builds and tests a Node.js application using `npm`.

```YAML
trigger:
  branches:
    include:
      - main
      - feature/*
  paths:
    include:
      - src/*
      - package.json

pool:
  name: My_Self_Hosted_Agent_Pool
  demands:
    - npm

steps:
  - task: NodeTool@0
    inputs:
      versionSpec: '16.x'
    displayName: 'Install Node.js'

  - script: |
      npm install
    displayName: 'Install dependencies'

  - script: |
      npm run build
    displayName: 'Build project'

  - script: |
      npm test
    displayName: 'Run tests'

  - task: PublishTestResults@2
    inputs:
      testResultsFiles: '**/*.xml'
      testRunTitle: 'Node.js Tests'
    condition: succeededOrFailed()
    displayName: 'Publish test results'

  - script: |
      echo "Pipeline completed successfully!"
    displayName: 'Print completion message'
```
<!-- -------------------------------------------------------------- -->
### 1. Line-by-Line Explanation
Let’s break down each section and line of the YAML pipeline:
```
trigger:
  branches:
    include:
      - main
      - feature/*
  paths:
    include:
      - src/*
      - package.json
```
- `trigger`: Defines when the pipeline runs automatically.
- `branches`: Specifies which branches trigger the pipeline.
    - `include`: Lists branches to include.
    - `- main`: Triggers on commits to the main branch.
    - `- feature/*`: Triggers on commits to any branch starting with feature/.
- `paths`: Limits triggers to specific file changes.
    - `- include`: Lists files or directories to monitor.
    - `- src/*`: Triggers if files in the src/ directory change.
    - `package.json`: Triggers if package.json changes.
- Purpose: Ensures the pipeline runs only for relevant changes, reducing unnecessary runs on your self-hosted agent

**NOTE**: `trigger` could take the value of `none` if ou dont want the pipeline to trigger when there are changes to the repository

_Example below_
```
trigger: none
```

Or 

```
trigger: 
    none
```
<!-- -------------------------------------------------------------- -->
### 2. Pool Section:

```bash
pool:
  name: My_Self_Hosted_Agent_Pool
  demands:
    - npm
```

- `pool`: Specifies the agent pool to use.
- `name`: My_Self_Hosted_Agent_Pool: Targets your self-hosted agent pool, ensuring the pipeline runs on your agent (e.g., test-ground-linux-vm).
- `demands`: Lists requirements the agent must meet.
- `- npm`: Requires the agent to have npm installed (your agent has version 9.2.0, so this is satisfied).
- Purpose: Ensures the pipeline runs on an agent in My_Self_Hosted_Agent_Pool with npm available. Since your agent version is 4.255.0, you don’t need the Agent.Version demand unless the pipeline explicitly requires it.

<!-- -------------------------------------------------------------- -->
### 3. Steps Section:

```
steps:
```
* `steps`: Defines the sequence of tasks or scripts to execute on the agent.
* **Purpose**: Contains the actual build, test, or deployment logic.

<!-- -------------------------------------------------------------- -->
### 4. Step 1: Install Node.js

```
- task: NodeTool@0
  inputs:
    versionSpec: '16.x'
  displayName: 'Install Node.js'
```

- `task`: NodeTool@0: Uses the built-in `NodeTool` task to install a specific Node.js version.
- `inputs`: Configuration for the task.
- `versionSpec: '16.x'`: Installs the latest Node.js version in the 16.x series (includes `npm`).
- `displayName: 'Install Node.js'`: Labels the step in the pipeline logs.
- **Purpose**: Ensures the agent has the correct Node.js version. Since your agent already has `npm` 9.2.0, this step is optional but ensures consistency. Adjust `versionSpec` to match your project’s Node.js version (e.g., `18.x` if needed).

<!-- -------------------------------------------------------------- -->

### 5. Step 2: Install Dependencies:

```
- script: |
    npm install
  displayName: 'Install dependencies'
```
- `script`: Runs a shell script on the agent.
- `npm install`: Executes npm install to download dependencies from `package.json`.
- `|`: Allows a multi-line script (though only one line is used here).
- `displayName: 'Install dependencies'`: Labels the step in logs.
- **Purpose**: Installs project dependencies using `npm`, leveraging the agent’s pre-installed `npm`.

<!-- -------------------------------------------------------------- -->
### 6. Step 3: Build Project:
```
- script: |
    npm run build
  displayName: 'Build project'
```
- `- script`: Runs another shell script.

- `npm run build`: Executes the build script defined in `package.json` (assumes your project has a build step).
- `displayName: 'Build project'`: Labels the step.
- **Purpose**: Compiles or builds the project. Replace npm run build with your project’s actual build command if different (e.g., npm run compile).
<!-- -------------------------------------------------------------- -->
### 7. Step 4: Run Tests:
```
- script: |
    npm test
  displayName: 'Run tests'
```
- `- script`: Runs a test script.
- `npm test`: Executes the test script from package.json (assumes tests are configured).
- `displayName`: 'Run tests': Labels the step.
- **Purpose**: Runs automated tests. Adjust the command based on your test framework (e.g., npm run test:unit).
<!-- -------------------------------------------------------------- -->
### 8. Step 5: Publish Test Results:
```
- task: PublishTestResults@2
  inputs:
    testResultsFiles: '**/*.xml'
    testRunTitle: 'Node.js Tests'
  condition: succeededOrFailed()
  displayName: 'Publish test results'
```
- `- task: PublishTestResults@2`: Publishes test results to Azure DevOps for reporting.
- `inputs`: Task configuration.
    - `testResultsFiles: '**/*.xml'`: Looks for test result files in XML format (common for test frameworks like Jest or Mocha with reporters).
    - `testRunTitle: 'Node.js Tests'`: Names the test run in Azure DevOps.
- `condition: succeededOrFailed()`: Runs even if previous steps fail, ensuring test results are published.
- `displayName: 'Publish test results'`: Labels the step.
- **Purpose**: Displays test results in the Azure DevOps UI. Ensure your test framework outputs results in a compatible format (e.g., JUnit XML). If not needed, skip this step.

<!-- -------------------------------------------------------------- -->
### 9. Step 6: Completion Message:
```
- script: |
    echo "Pipeline completed successfully!"
  displayName: 'Print completion message'
```
- `- script`: Runs a simple script.
echo "Pipeline completed successfully!": Prints a message to the logs.
- `displayName: 'Print completion message'`: Labels the step.
- **Purpose**: Adds a diagnostic message to confirm pipeline completion. Useful for debugging.

<!-- -------------------------------------------------------------- -->
### How to Use This Pipeline
#### 1. Create the YAML File:
- Create a file named azure-pipelines.yml in the root of your repository.
- Copy the sample YAML above and adjust:
    - Update trigger branches/paths to match your repository structure.
    - Ensure pool: name matches My_Self_Hosted_Agent_Pool.
    - Adjust versionSpec in the NodeTool task to your project’s Node.js version.
    - Modify npm commands (npm run build, npm test) to match your package.json scripts.

#### 2. Commit and Push:
- Commit azure-pipelines.yml to your repository (e.g., main or feature/* branch).
- Push to Azure DevOps to trigger the pipeline.

#### 3. Set Up the Pipeline in Azure DevOps:
- Go to Azure DevOps > Pipelines > New Pipeline.
- Select your repository and choose “Existing Azure Pipelines YAML file.”
- Point to azure-pipelines.yml and save/run.

#### 4. Ensure Agent Readiness:
- Verify your self-hosted agent is online in My_Self_Hosted_Agent_Pool (green dot in Organization Settings > Agent Pools).
- Confirm npm is installed (npm --version returns 9.2.0).
- Consider running the agent as a service for reliability:
```
`cd` ~/my_Azure_DevOps
sudo ./svc.sh install
sudo ./svc.sh start
```
<!-- -------------------------------------------------------------- -->
#### Additional Tips
**Debugging**: Enable debug logs by adding `variables: system.debug: true` to the YAML to get detailed logs if the pipeline fails.
**Templates**: For complex projects, use YAML templates to reuse steps across pipelines (see https://learn.microsoft.com/en-us/azure/devops/pipelines/yaml-schema/templates).
**Agent Maintenance**: Regularly update your agent to the latest version (currently 4.255.0 is fine) and ensure tools like npm are up-to-date.
**Fallback**: If the pipeline still fails to pick up the agent, remove demands `(demands: - npm)` temporarily to test if the agent is selected.

#### Why This Is the Best Approach
- **YAML over Classic Editor**: YAML is version-controlled, auditable, and easier to modify than the UI-based Classic Editor.
- **Self-Hosted over Microsoft-Hosted**: Your self-hosted agent avoids provisioning delays, supports custom tools, and is cost-effective for frequent builds.
- **Minimal Demands**: Specifying only `npm` ensures compatibility with your agent while avoiding issues like the previous version mismatch.
- **Structured** Steps: The pipeline is simple, modular, and extensible for additional tasks (e.g., deployment).


For more details, refer to the Azure Pipelines YAML schema: (https://learn.microsoft.com/en-us/azure/devops/pipelines/yaml-schema/). If you have a specific project type (e.g., `Python`, `Java`) or additional requirements, share them, and I can tailor the YAML further! Let me know if you need help setting this up or troubleshooting.