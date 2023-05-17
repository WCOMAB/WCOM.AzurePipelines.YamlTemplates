# Overview

Azure DevOps Pipelines Docs is used to publish and deploy Documentation to Azure.

## Parameters

 **Parameter**           | **Type** | **Required** | **Default value**                                                       | **Description**
-------------------------|----------|--------------|-------------------------------------------------------------------------|-------------------------------------------------------------
 system                  | string   | Yes          |                                                                         | The target system.
 suffix                  | string   | Yes          |                                                                         | The resource name suffix.
 devopsOrg               | string   | Yes          |                                                                         | The devops organisation.
 build                   | string   | Yes          |                                                                         | The environment to build.
 sources                 | array    | No           |                                                                         | NuGet feeds to authenticate against and optionally push to.
 sites                   | array    | Yes          |                                                                         | Array of sites.
 webAppNameFormat        | string   | No           | '{0}-{1}-{2}-{3}-{4}'                                                   | The format for the web app name.
 webAppType              | string   | No           | 'stapp'                                                                 | The type/abbreviation for the web app.
 searchServiceName       | string   | No           | format('{0}-{1}-{2}-{3}', system, 'srch', env, suffix)                  | The Search Service name.
 searchServiceNameFormat | string   | No           | '{0}-{1}-{2}-{3}'                                                       | The format for the search service.
 searchServiceType       | string   | No           | 'srch'                                                                  | The type/abbreviation for the Search Service name.
 azureSubscription       | string   | No           | format('azdo-{0}-{1}-{2}-{3}', devopsOrg, system, env, suffix)          | The Azure Subscription name.
 azureSubscriptionFormat | string   | No           | 'azdo-{0}-{1}-{2}-{3}'                                                  | The format for the azureSubscription.
 resourceGroup           | string   | No           | format('{0}-{1}-{2}', system, env, suffix)                              | The resource group name.
 resourceGroupFormat     | string   | No           | '{0}-{1}-{2}'                                                           | The format for the resourceGroup name.
 preBuildScript          | object   | No           |                                                                         | Object containing pre-build parameters.
 environments            | array    | Yes          |                                                                         | Array of environments and environment specific parameters.
 artifactNamePrefix     | string   | No          |                                                                | Prefix for artifacts created by this pipeline.
 projectRoot            | string   | No          |                                                                | For changing the root of the project, ie where input or other folders are located.

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

## Per environment

 **Parameters** | **Type** | **Required** | **Default value**                                                       | **Description**
----------------|----------|--------------|-------------------------------------------------------------------------|----------------------------------------------
 env            | array    | Yes          |                                                                         | The target environment.
 name           | string   | Yes          |                                                                         | The target environment name.
 webAppName     | string   | No           | format('{0}-{1}-{2}-{3}-{4}', system, webAppName, 'stapp', env, suffix) | The Web App name.
 deploy         | bool     | No           | true                                                                    | Allow deploy to Resource group.
 deployAfter    | array    | No           |                                                                         | Object will be deployed after following env.

 ## Examples

 ### Minimum needed

```yaml
name: $(Year:yyyy).$(Month).$(DayOfMonth)$(Rev:.r)

trigger:
  - main

pool:
  vmImage: vmImage

resources:
  repositories:
    - repository: templates
      type: github
      endpoint: GitHubPublic
      name: WCOMAB/WCOM.AzurePipelines.YamlTemplates
      ref: refs/heads/main

stages:
- template: docs/stages.yml@templates
  parameters:
    system: system
    suffix: suffix
    devopsOrg: devopsOrg
    build: envName
    sites:
      - name: 'siteName'
    shouldDeploy: eq(variables['Build.SourceBranch'], 'refs/heads/main')
    environments:
      - env: dev
        name: Development
      - env: stg
        name: Staging
      - env: prd
        name: Production
```

### Optional parameters

```yaml
name: $(Year:yyyy).$(Month).$(DayOfMonth)$(Rev:.r)

trigger:
  - main

pool:
  vmImage: vmImage

resources:
  repositories:
    - repository: templates
      type: github
      endpoint: GitHubPublic
      name: WCOMAB/WCOM.AzurePipelines.YamlTemplates
      ref: refs/heads/main

stages:
- template: docs/stages.yml@templates
  parameters:
    system: system
    suffix: suffix
    devopsOrg: devopsOrg
    webAppNameFormat: '{0}-{1}-{2}-{3}-{4}-{5}'
    webAppType: webAppType
    searchServiceName: searchServiceName
    searchServiceNameFormat: '{0}-{1}-{2}-{3}-{4}'
    searchServiceType: searchServiceType
    azureSubscriptionFormat: '{0}-{1}-{2}-{3}-{4}'
    resourceGroupFormat: '{0}-{1}-{2}-{3}'
    artifactNamePrefix: prefix
    projectRoot: some/directory
    build: envName
    sources:
      - name: authenticateSourceName
      - name: authenticateUsingTokenSourceName
        token: $(CustomerNugetFeedToken)
    sites:
      - name: 'siteName'
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
    shouldDeploy: eq(variables['Build.SourceBranch'], 'refs/heads/main')
    environments:
      - env: dev
        name: Development
        webAppName: webAppName
        deploy: true/false
      - env: stg
        name: Staging
        webAppName: webAppName
        deploy: true/false
        deployAfter:
          - Development
      - env: prd
        name: Production
        webAppName: webAppName
        deploy: true/false
        deployAfter:
          - Staging
```