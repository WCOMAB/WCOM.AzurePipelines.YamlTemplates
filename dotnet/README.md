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
 useDotNetSDK    | object   | No           |                   | Object containing parameters for specified dotnet SDK.
 environments    | array    | Yes          |                   | Array of environments and environment specific parameters
 artifactNamePrefix     | string   | No          |                                                                | Prefix for artifacts created by this pipeline.
 dpi        | object   | No          |                   | Settings relating to Dependency reports using DPI tool
 toolRestore     | bool     | No           | false             | Flag to be able to dotnet restore tools before prebuild script in the build pipeline.


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

## Use DotNet SDK

 **Parameters**   | **Type** | **Required** | **Default value** | **Description**
------------------|----------|--------------|-------------------|----------------------------------
 packageType      | string   | No           | sdk               | Specifies if only the .NET runtime or the SDK should be installed.
 useGlobalJson    | bool     | No           | true              | Specifies if sdk should be installed from a globalJson file.
 workingDirectory | string   | No           |                   | The path to the globalJson file.
 version          | string   | No           |                   | Specifies a specific version of the dotnet sdk.

## Source

 **Parameters** | **Type** | **Required** | **Default value** | **Description**
----------------|----------|--------------|-------------------|------------------
 name           | string   | Yes          |                   | The source name.
 token          | string   | No           |                   | Access token.
 publish        | bool     | No           |                   | Allow update to NuGet source.

## dpi

 **Parameters** | **Type** | **Required** | **Default value** | **Description**
----------------|----------|--------------|-------------------|------------------
 report           | bool   | no        | false                   | Boolean to create report or not.
 WorkspaceId          | string (secret)   | Yes           |                   | The Id of the log analytic workspace the reports gets sent to.
 SharedKey        | string (secret)   | Yes           |                   | Shared/Primary Key to the workspace you want to send the reports to

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
    artifactNamePrefix: prefix
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
    toolRestore: true/false
    useDotNetSDK: 
      packageType: sdk/runtime
      useGlobalJson: true/false
      workingDirectory: workingDirectory
      version: '6.0.x'
    preBuildScript:
      scriptType: scriptType
      targetType: targetType
      filePath: filePath
      script: script.sh
      script: |
        echo "Hello World!"
      arguments: arguments
      failOnStderr: true/false
      showWarnings: true/false
      pwsh: true/false
      workingDirectory: workingDirectory
      bashEnvValue: bashEnvValue
    dpi:
      report: true/false
      WorkspaceId: <secret string>
      SharedKey: <secret string>
    build: envName
    environments:
      - env: dev
        name: Development
```