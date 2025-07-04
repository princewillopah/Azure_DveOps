Best 

---
<br>

#### FOR LOGGING/DEBUGGING 


``` yaml
- task: Bash@3
  inputs:
    targetType: 'inline'
    script: |
      ls -la $(Build.SourcesDirectory)
      cat $(Build.SourcesDirectory)/Dockerfile
  displayName: 'Debug: List source directory and Dockerfile'
  ```
**Purpose:**
- **Lists directory contents:** The `ls -la $(Build.SourcesDirectory)` command lists all files and directories (including hidden ones) in the `$(Build.SourcesDirectory)` path, which is the directory on the build agent where your repository is checked out (e.g., `/home/princewillopah/my_Azure_DevOps/_work/1/s` for a **self-hosted agent**).
- **Displays Dockerfile content:** The cat `$(Build.SourcesDirectory)/Dockerfile` command outputs the contents of the Dockerfile to the pipeline logs, confirming its presence and contents.
- This helps debug issues like missing files, incorrect paths, or a misconfigured Dockerfile before the `Docker@2` or `AzureCLI@2` tasks run.

<br>

**Why it’s used:**
- Ensures the `Dockerfile` exists in the expected location (`$(Build.SourcesDirectory)/Dockerfile`) before the `Docker@2` task tries to build the image.
- Verifies that the repository was checked out correctly (via `checkout: self`).
- Helps troubleshoot pipeline failures by showing the file structure and `Dockerfile` content in the logs.

<br>

---

   