# Overview

Azure DevOps YAML template is used to build, validate and deploy resources to Azure using bicep templates. Publish bicep modules to an Azure Container Registry.

## Parameters

 **Parameter**           | **Type** | **Required** | **Default value**                                              | **Description**
-------------------------|----------|--------------|----------------------------------------------------------------|--------------------------------------------------------------
 system                  | string   | Yes          |                                                                | The target system.
 suffix                  | string   | Yes          |                                                                | The resource name suffix.
 devopsOrg               | string   | Yes          |                                                                | The devops organisation.
 build                   | string   | Yes          |                                                                | The environment to build.
 shouldDeploy            | bool     | No           |                                                                | Check if deploy and publish stages should run.
 azureSubscription       | string   | No           | format('azdo-{0}-{1}-{2}-{3}', devopsOrg, system, env, suffix) | The Azure Subscription name.
 azureSubscriptionFormat | string   | No           | 'azdo-{0}-{1}-{2}-{3}'                                         | The format for the azureSubscription.
 resourceGroup           | string   | No           | format('{0}-{1}-{2}', system, env, suffix)                     | The resource group name.
 resourceGroupFormat     | string   | No           | '{0}-{1}-{2}'                                                  | The format for the resourceGroup name.
 acr                     | string   | No           | format('{0}acr{1}{2}', system, env, suffix)                    | The resource name.
 preBuildScript          | object   | No           |                                                                | Object containing pre-build parameters.
 postDeploymentScript    | object   | No           |                                                                | Object containing post-deployment parameters.
 environments            | array    | Yes          |                                                                | Array of environments and environment specific parameters.
 artifactNamePrefix      | string   | No           |                                                                | Prefix for artifacts created by this pipeline.
 projectRoot             | string   | No           |                                                                | For changing the root of the project, ie where main.bicep or other files are located.
 validateBicep           | boolean  | No           |      true                                                      | To control if the Bicep code should be validated or not - default is true.
 acrFormat               | string   | No           | format('{0}acr{1}{2}', system, env, suffix)                    | The format which the bicep ACR follows.
 pool                    | string   | No           |                                                                | Controls which agent pool to use for all stages.
 buildPool               | string   | No           |                                                                | Controls which agent pool to use for build stages (overrides pool).
 publishPool             | string   | No           |                                                                | Controls which agent pool to use for publish stages (overrides pool).
 deployPool              | string   | No           |                                                                | Controls which agent pool to use for deploy stages (overrides pool).

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
 displayName      | string   | No           |                   | Custom display name for the task. If not specified, a default name will be generated.
 azureSubscription| string   | No           |                   | Azure Resource Manager subscription for Azure CLI execution. If specified, script runs using Azure CLI task.
 env              | object   | No           |                   | Dictionary of environment variables to pass to the script.

## Post-Deployment

 **Parameters**    | **Type** | **Required** | **Default value** | **Description**
-------------------|----------|--------------|-------------------|----------------------------------
 scriptType        | string   | No           |                   | The type of script. pscore or bash.
 targetType        | string   | No           | filePath          | Specifies the type of script for the task to run. inline or filePath.
 filePath          | string   | No           |                   | The path of the script.
 script            | string   | No           |                   | The contents of the script. Supports either a loose file or inline script depending on the targetType.
 arguments         | string   | No           |                   | Specifies the arguments passed to the script.
 failOnStderr      | bool     | No           | false             | Fails task if errors are written to the error pipeline or if any data is written to the Standard Error stream.
 showWarnings      | bool     | No           | false             | Show warnings in pipeline logs.
 workingDirectory  | string   | No           |                   | The working directory where the script is run.
 bashEnvValue      | string   | No           |                   | Value for BASH_ENV environment variable.
 pwsh              | bool     | No           | false             | Use PowerShell Core.
 displayName       | string   | No           |                   | Custom display name for the task.
 azureSubscription | string   | No           |                   | Azure Resource Manager subscription for Azure CLI execution. Defaults to deploy subscription.
 env               | object   | No           |                   | Dictionary of environment variables to pass to the script.

## Per environment

 **Parameters**       | **Type** | **Required** | **Default value** | **Description**
----------------------|----------|--------------|-------------------|---------------------------------------------------
 env                  | string   | Yes          |                   | The target environment.
 name                 | string   | Yes          |                   | The target environment name.
 extraParameters      | string   | No           |                   | Used for passing extra parameters to the template.
 postDeploymentScript | object   | No           |                   | Overrides root postDeploymentScript for this environment.
 deploy               | bool     | No           | true              | Allow deploy to Resource group.
 publish              | bool     | No           | true              | Allow publish of modules to container registry.
 dependsOn            | array    | No           |                   | Allows for deployment to depend on an optional stage, ie a Build stage fromm another template or outside the current template.
 pool                 | string   | No           |                   | Controls which agent pool to use for all stages.
 buildPool            | string   | No           |                   | Controls which agent pool to use for build stages.
 publishPool          | string   | No           |                   | Controls which agent pool to use for publish stages.
 deployPool           | string   | No           |                   | Controls which agent pool to use for deploy stages.

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
    validateBicep: true
    preBuildScript:
      scriptType: bash
      targetType: inline
      script: |
        echo "Hello World!"
      failOnStderr: false
      showWarnings: false
      pwsh: false
      workingDirectory: workingDirectory
      bashEnvValue: bashEnvValue
    postDeploymentScript:
      scriptType: bash
      targetType: inline
      script: |
        echo "Post-deploy from calling pipeline"
      displayName: Post-deploy smoke check
    build: envName
    shouldDeploy: eq(variables['Build.SourceBranch'], 'refs/heads/main')
    environments:
      - env: dev
        name: Development
        extraParameters: 'secretGreeting="$(SECRET_GREETING)" sqladminGroupId="$(sqladminGroupId)" sqladminGroupName="$(sqladminGroupName)"'
        deploy: true
        publish: true
        azureSubscriptionFormat: '{0}-{1}-{2}-{3}-{4}'
        resourceGroupFormat: '{0}-{1}-{2}-{3}'
        dependsOn:
          - Stage
```
