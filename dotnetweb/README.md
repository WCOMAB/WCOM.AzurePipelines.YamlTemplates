# Overview

Azure DevOps YAML template is used to deploy and publish web applications.

## Parameters

 **Parameter**           | **Type** | **Required** | **Default value**                                              | **Description**
-------------------------|----------|--------------|----------------------------------------------------------------|-------------------------------------------------------------
 system                  | string   | Yes          |                                                                | The target system.
 suffix                  | string   | Yes          |                                                                | The resource name suffix.
 devopsOrg               | string   | Yes          |                                                                | The devops organisation.
 build                   | string   | Yes          |                                                                | The environment to build.
 sources                 | array    | No           |                                                                | NuGet feeds to authenticate against.
 buildParameters         | object   | No           |                                                                | Build Parameters.
 shouldDeploy            | bool     | No           |                                                                | Check if deploy stage should run.
 webAppNameFormat        | string   | No           | '{0}-{1}-{2}-{3}-{4}'                                          | The format for the web app name.
 webAppType              | string   | No           | 'web'                                                          | The type/abbreviation for the web app.
 azureSubscription       | string   | No           | format('azdo-{0}-{1}-{2}-{3}', devopsOrg, system, env, suffix) | The Azure Subscription name.
 azureSubscriptionFormat | string   | No           | 'azdo-{0}-{1}-{2}-{3}'                                         | The format for the azureSubscription.
 projectSrc	             | string	  | No	         | src	                                                          | Source folder to build, pack and publish.
 preBuildScript          | object   | No           |                                                                | Object containing pre-build parameters.
 environments            | array    | Yes          |                                                                | Array of environments and environment specific parameters.
 useDotNetSDK            | object   | No           |                   | Object containing parameters for specified dotnet SDK.
 artifactNamePrefix     | string   | No          |                                                                | Prefix for artifacts created by this pipeline.
 skipTests              | bool     | No           |  true                                                         | Allow tests to be skipped.
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

 **Parameters** | **Type** | **Required** | **Default value**          | **Description**
----------------|----------|--------------|----------------------------|------------------
 name           | string   | Yes          |                            | The source name.
 token          | string   | No           |                            | Access token.

## dpi

 **Parameters** | **Type** | **Required** | **Default value** | **Description**
----------------|----------|--------------|-------------------|------------------
 report           | bool   | no        | false                   | Boolean to create report or not.
 WorkspaceId          | string (secret)   | Yes           |                   | The Id of the log analytic workspace the reports gets sent to.
 SharedKey        | string (secret)   | Yes           |                   | Shared/Primary Key to the workspace you want to send the reports to

## Per environment

 **Parameters** | **Type** | **Required** | **Default value**                                                     | **Description**
----------------|----------|--------------|-----------------------------------------------------------------------|----------------------------------------------
 env            | array    | Yes          |                                                                       | The target environment.
 name           | string   | Yes          |                                                                       | The target environment name.
 WebAppName     | string   | No           | format('{0}-{1}-{2}-{3}-{4}', system, webAppName, 'web', env, suffix) | The Web App name.
 deploy         | bool     | No           | true                                                                  | Allow deploy to Resource group.
 deployAfter    | array    | No           |                                                                       | Object will be deployed after following env.
 dependsOn      | array    | No           |                                                                       | Allows for deployment to depend on an optional stage, ie a Build stage fromm another template or outside the current template. 

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
- template: dotnetweb/stages.yml@templates
  parameters:
    system: system
    suffix: suffix
    devopsOrg: devopsOrg
    build: envName
    shouldDeploy: eq(variables['Build.SourceBranch'], 'refs/heads/main')
    environments:
      - env: env
        name: Development
      - env: env
        name: Staging
      - env: env
        name: Production
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
- template: dotnetweb/stages.yml@templates
  parameters:
    artifactNamePrefix: prefix
    system: system
    suffix: suffix
    devopsOrg: devopsOrg
    webAppNameFormat: '{0}-{1}-{2}-{3}-{4}'
    webAppType: webAppType
    azureSubscriptionFormat: '{0}-{1}-{2}-{3}-{4}'
    sources:
      - name: authenticateSourceName
      - name: authenticateUsingTokenSourceName
        token: $(CustomerNugetFeedToken)
    buildParameters:
      - '-p:buildParameter=buildParameterValue'
    toolRestore: true/false
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
    build: envName
    useDotNetSDK:
      packageType: sdk/runtime
      useGlobalJson: true/false
      workingDirectory: workingDirectory
      version: '6.0.x'
    dpi:
      report: true/false
      WorkspaceId: <secret string>
      SharedKey: <secret string>
    shouldDeploy: eq(variables['Build.SourceBranch'], 'refs/heads/main')
    environments:
      - env: env
        name: Development
        webAppName: webAppName
        deploy: true/false
        dependsOn:
          - Stage
      - env: env
        name: Staging
        webAppName: webAppName
        deploy: true/false
        deployAfter:
          - Development
        dependsOn:
          - Stage
      - env: env
        name: Production
        webAppName: webAppName
        deploy: true/false
        deployAfter:
          - Staging
        dependsOn:
          - Stage
 ```
