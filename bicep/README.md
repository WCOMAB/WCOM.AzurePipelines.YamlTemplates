# Overview

Azure DevOps Pipelines YAML template used to Build, validate and deploy resources to Azure using bicep templates. Publish bicep modules to an Azure Container Registry.

## Parameters

 **Parameter**           | **Type** | **Required** | **Default value**                                              | **Description**
-------------------------|----------|--------------|----------------------------------------------------------------|-----------------------------------------------------------
 system                  | string   | Yes          |                                                                | The target system.
 suffix                  | string   | Yes          |                                                                | The resource name suffix.
 devopsOrg               | string   | Yes          |                                                                | The devops organisation.
 build                   | string   | Yes          |                                                                | The environment to build.
 azureSubscription       | string   | No           | format('azdo-{0}-{1}-{2}-{3}', devopsOrg, system, env, suffix) | The Azure Subscription name.
 azureSubscriptionFormat | string   | No           | 'azdo-{0}-{1}-{2}-{3}'                                         | The format for the azureSubscription.
 resourceGroup           | string   | No           | format('{0}-{1}-{2}', system, env, suffix)                     | The resource group name.
 resourceGroupFormat     | string   | No           | '{0}-{1}-{2}'                                                  | The format for the resourceGroup name.
 acr                     | string   | No           | format('{0}acr{1}{2}', system, env, suffix)                    | The resource name.
 preBuildScript          | object   | No           |                                                                | Object containing pre-build parameters.
 environments            | array    | Yes          |                                                                | Array of environments and environment specific parameters.
 artifactNamePrefix     | string   | No          |                                                                | Prefix for artifacts created by this pipeline.
 projectRoot            | string   | No          |                                                                | For changing the root of the project, ie where main.bicep or other files are located.
 validateBicep           | boolean   |   No          |      true                                        | To control if the Bicep code should be validated or not - default is true.

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

## Per environment

 **Parameters**  | **Type** | **Required** | **Default value** | **Description**
-----------------|----------|--------------|-------------------|---------------------------------------------------
 env             | array    | Yes          |                   | The target environment.
 name            | string   | Yes          |                   | The target environment name.
 extraParameters | string   | No           |                   | Used for passing extra parameters to the template.
 deploy          | bool     | No           | true              | Allow deploy to Resource group.
 publish         | bool     | No           | true              | Allow publish of modules to container registry.

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
- template: bicep/stages.yml@templates
  parameters:
    system: system
    devopsOrg: devopsOrg
    suffix: suffix
    build: envName
    shouldDeploy: eq(variables['Build.SourceBranch'], 'refs/heads/main')
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
- template: bicep/stages.yml@templates
  parameters:
    system: system
    devopsOrg: devopsOrg
    suffix: suffix
    azureSubscriptionFormat: '{0}-{1}-{2}-{3}-{4}'
    resourceGroupFormat: '{0}-{1}-{2}-{3}'
    artifactNamePrefix: prefix
    projectRoot: some/directory
    validateBicep: true/false
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
    shouldDeploy: eq(variables['Build.SourceBranch'], 'refs/heads/main')
    environments:
      - env: dev
        name: Development
        extraParameters: 'secretGreeting="$(SECRET_GREETING)" sqladminGroupId="$(sqladminGroupId)" sqladminGroupName="$(sqladminGroupName)"'
        deploy: true/false
        publish: true/false
```