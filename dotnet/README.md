# Overview

Azure DevOps Pipelines YAML template used to build, test, pack, and publish .NET libraries or applications.

## Parameters

 **Parameter**   | **Type** | **Required** | **Default value** | **Description**
-----------------|----------|--------------|-------------------|-------------------------------------------
 sources         | object   | Yes          |                   | NuGet feeds to authenticate against and optionally push to.
 buildParameters | object   | No           |                   | Build Parameters.
 toolCommandName | string   | No           |                   | Tool command name.
 publish         | bool     | No           |                   | Allow publish to Feed.
 skipTests       | bool     | No           |                   | Allow tests to be skipped.
 build           | string   | Yes          |                   | The environment to build.
 onlyPublish     | bool     | No           | true              | Allow update to source feed.
 projectSrc      | string   | No           | src               | Source folder to build, pack and publish.
 preBuildScript  | object   | No           |                   | Object containing pre-build parameters.
 environments    | array    | Yes          |                   | Array of environments and environment specific parameters.

## Pre-Build

 **Parameters**   | **Type** | **Required** | **Default value** | **Description**
------------------|----------|--------------|-------------------|----------------------------------
 scriptType       | string   | No           |                   | The type of script. pscore or bash.
 targetType       | string   | No           | filePath          | Specifies the type of script for the task to run. inline or filePath.
 filePath         | string   | No           |                   | The path of the script.
 script           | string   | No           |                   | The contents of the script. Supports either a loose file or inline script depending on the targetType.
 arguments        | string   | No           |                   | Specifies the arguments passed to the script.
 failOnStderr     | bool     | No           | false             | Fails task if errors are written to the error pipeline or if any data is written to the Standard Error stream.
 showWarnings     | bool     | No           | false             | Show warnings in pipeline logs.
 workingDirectory | string   | No           |                   | The working directory where the script is run.
 bashEnvValue     | string   | No           |                   | Value for BASH_ENV environment variable.
 pwsh             | bool     | No           | false             | Use PowerShell Core.

## Source

 **Parameters** | **Type** | **Required** | **Default value** | **Description**
----------------|----------|--------------|-------------------|------------------
 name           | string   | Yes          |                   | The source name.
 token          | string   | No           |                   | Access token.
 publish        | bool     | No           |                   | Allow update to NuGet source.

## Per environment

 **Parameters** | **Type** | **Required** | **Default value** | **Description**
----------------|----------|--------------|-------------------|---------------------------------------------
 env            | array    | Yes          |                   | The target environment.
 name           | string   | Yes          |                   | The target environment name.

## Examples

### Minimum needed

```yaml
name: $(Year:yyyy).$(Month).$(DayOfMonth)$(Rev:.r)

pool:
  vmImage: vmImage

trigger:
- main

resources:
  repositories:
    - repository: templates
      type: github
      endpoint: GitHubPublic
      name: WCOMAB/WCOM.AzurePipelines.YamlTemplates
      ref: refs/heads/main

stages:
- template: dotnet/stages.yml@templates
  parameters:
    shouldPublish: eq(variables['Build.SourceBranch'], 'refs/heads/main')
    sources:
      - name: sourceName
        publish: true/false
    build: envName
    environments:
      - env: dev
        name: Development
```

### Optional parameters

```yaml
name: $(Year:yyyy).$(Month).$(DayOfMonth)$(Rev:.r)

pool:
  vmImage: vmImage

trigger:
- main

resources:
  repositories:
    - repository: templates
      type: github
      endpoint: GitHubPublic
      name: WCOMAB/WCOM.AzurePipelines.YamlTemplates
      ref: refs/heads/main

stages:
- template: dotnet/stages.yml@templates
  parameters:
    shouldPublish: eq(variables['Build.SourceBranch'], 'refs/heads/main')
    sources:
      - name: authenticateSourceName
      - name: authenticateAndPushSourceName
        publish: true
      - name: authenticateUsingTokenSourceName
        token: $(CustomerNugetFeedToken)
      - name: authenticateUsingTokenAndPushSourceName
        token: $(CustomerNugetFeedToken)
        publish: true
    buildParameters:
      - '-p:PackAsTool=true/false'
      - '-p:ToolCommandName=ToolCommandName'
    skipTests: true/false
    projectSrc: projectSrc
    preBuildScript:
      - scriptType: scriptType
      - targetType: targetType
      - filePath: filePath
      - script: script.sh
      - script: |
          echo "Hello World!"
      - arguments: arguments
      - failOnStderr: true/false
      - showWarnings: true/false
      - pwsh: true/false
      - workingDirectory: workingDirectory
      - bashEnvValue: bashEnvValue
    build: envName
    environments:
      - env: dev
        name: Development
```