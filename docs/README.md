# Overview

Azure DevOps Pipelines Docs is used to publish and deploy Documentation to Azure. Each site is built to HTML, indexed with Pagefind, then published as a static site artifact.

## Parameters

 **Parameter**           | **Type** | **Required** | **Default value**                                                       | **Description**
-------------------------|----------|--------------|-------------------------------------------------------------------------|-------------------------------------------------------------
 system                  | string   | Yes          |                                                                         | The target system.
 suffix                  | string   | Yes          |                                                                         | The resource name suffix.
 devopsOrg               | string   | Yes          |                                                                         | The devops organisation.
 build                   | string   | Yes          |                                                                         | The environment to build.
 sources                 | array    | No           |                                                                         | NuGet feeds to authenticate against and optionally push to.
 sites                   | array    | Yes          |                                                                         | Array of sites. Each site can override webAppName, postBuildScript, and apiLocation.
 webAppName              | string   | No           |                                                                         | Name fragment used in the default web app name format when a site does not set webAppName.
 webAppNameFormat        | string   | No           | '{0}-{1}-{2}-{3}-{4}'                                                   | The format for the web app name.
 webAppType              | string   | No           | 'stapp'                                                                 | The type/abbreviation for the web app.
 azureSubscription       | string   | No           | format('azdo-{0}-{1}-{2}-{3}', devopsOrg, system, env, suffix)          | The Azure Subscription name.
 azureSubscriptionFormat | string   | No           | 'azdo-{0}-{1}-{2}-{3}'                                                  | The format for the azureSubscription.
 resourceGroup           | string   | No           | format('{0}-{1}-{2}', system, env, suffix)                              | The resource group name.
 resourceGroupFormat     | string   | No           | '{0}-{1}-{2}'                                                           | The format for the resourceGroup name.
 preBuildScript          | object   | No           |                                                                         | Object containing pre-build parameters. Runs once before tools are installed and sites are built.
 postBuildScript         | object   | No           |                                                                         | Default post-build hook. Used when a site does not set postBuildScript. Runs after Pagefind, before publish.
 shouldDeploy            | bool     | No           |                                                                         | Check if deploy stages should run.
 installSwaCli           | bool     | No           | true                                                                    | Install @azure/static-web-apps-cli on the deploy agent. Set false when swa is already installed.
 apiLocation             | string   | No           |                                                                         | Managed functions folder passed to `swa deploy --api-location`. Path is under the deploy checkout (e.g. `api`). Not copied into the HTML artifact. Used for every site unless a site sets apiLocation.
 environments            | array    | Yes          |                                                                         | Array of environments and environment specific parameters.
 useDotNetSDK            | object   | No           |                                                                         | Object containing parameters for specified dotnet SDK.
 artifactNamePrefix      | string   | No           |                                                                         | Prefix for artifacts created by this pipeline.
 projectRoot             | string   | No           | '.'                                                                     | For changing the root of the project, ie where input or other folders are located.

## Pre-Build

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
 displayName       | string   | No           |                   | Custom display name for the task. If not specified, a default name will be generated.
 azureSubscription | string   | No           |                   | Azure Resource Manager subscription for Azure CLI execution. If specified, script runs using Azure CLI task.
 env               | object   | No           |                   | Dictionary of environment variables to pass to the script.

## Sites

 **Parameter**     | **Type** | **Required** | **Default value** | **Description**
-------------------|----------|--------------|-------------------|----------------------------------
 name              | string   | Yes          |                   | Site name. Used as the input folder, artifact suffix, and SiteName env var. Must be job-id safe (letters, digits, underscore; hyphens are rewritten only in the deploy job id).
 webAppName        | string   | No           |                   | Exact Azure Static Web App resource name. When omitted, uses the environment-resolved web app name.
 postBuildScript   | object   | No           |                   | Site-specific post-build hook. When omitted, uses the template-level postBuildScript.
 apiLocation       | string   | No           |                   | Site-specific `--api-location`. When omitted, uses the template-level apiLocation. When both are empty, SWA deploys HTML only.

Sites in one environment deploy as parallel jobs in `Deploy_{environment}`. The job id is `{environment}_{site}_Deploy`. Each job targets the same Azure DevOps Environment (`environment.name`). An exclusive lock on that Environment serializes the jobs. Each `deployment` job may request its own approval. For a single approval then parallel SWA deploys, use a gate `deployment` job plus regular jobs in a wrapper pipeline; this template keeps per-site deployment jobs.

## Post-Build

Same script object shape as Pre-Build. A site-level `postBuildScript` is used when present, otherwise the template-level hook. If neither is set, the step is a no-op. Runs inside the site loop after Pagefind indexing and before the static site artifact is published.

When the hook runs it always receives:

 **Env**         | **Description**
-----------------|----------------------------------
 SiteName        | The current `sites[].name`.
 DocsOutputDir   | Site output path under `$(build.artifactstagingdirectory)/output/<site>`.

Consumer `postBuildScript.env` values override these keys if they clash.

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
 displayName       | string   | No           |                   | Custom display name for the task. If not specified, a default name will be generated.
 azureSubscription | string   | No           |                   | Azure Resource Manager subscription for Azure CLI execution. If specified, script runs using Azure CLI task.
 env               | object   | No           |                   | Dictionary of environment variables to pass to the script.

## Use DotNet SDK

 **Parameters**   | **Type** | **Required** | **Default value** | **Description**
------------------|----------|--------------|-------------------|----------------------------------
 packageType      | string   | No           | sdk               | Specifies if only the .NET runtime or the SDK should be installed.
 useGlobalJson    | bool     | No           | true              | Specifies if sdk should be installed from a globalJson file.
 workingDirectory | string   | No           |                   | The path to the globalJson file.
 version          | string   | No           |                   | Specifies a specific version of the dotnet sdk.
 skipTask         | bool     | No           | false             | Bool if you want to skip this task or not.

## Source

 **Parameters** | **Type** | **Required** | **Default value** | **Description**
----------------|----------|--------------|-------------------|------------------
 name           | string   | Yes          |                   | The source name.
 token          | string   | No           |                   | Access token.

## Per environment

 **Parameters**  | **Type**  | **Required** | **Default value**                                                       | **Description**
-----------------|-----------|--------------|-------------------------------------------------------------------------|----------------------------------------------
 env             | array     | Yes          |                                                                         | The target environment.
 name            | string    | Yes          |                                                                         | The target environment name.
 webAppName      | string    | No           | format('{0}-{1}-{2}-{3}-{4}', system, webAppName, 'stapp', env, suffix) | The Web App name.
 deploy          | bool      | No           | true                                                                    | Allow deploy to Resource group.
 deployAfter     | array     | No           |                                                                         | Object will be deployed after following env.
 dependsOn       | array     | No           |                                                                         | Allows for deployment to depend on an optional stage, ie a Build stage fromm another template or outside the current template.


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

### Multiple sites to different Static Web Apps

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
    system: contoso
    devopsOrg: contoso
    suffix: rg
    azureSubscriptionFormat: 'azdo-{1}-{2}-{3}'
    webAppName: docs
    apiLocation: api
    build: Production
    sites:
      - name: UserGuide
        webAppName: contoso-docs-stapp-prd
        postBuildScript:
          scriptType: pscore
          targetType: filePath
          filePath: scripts/Patch-UserGuide-SwaConfig.ps1
      - name: Operations
        webAppName: contoso-opsdocs-stapp-prd
        postBuildScript:
          scriptType: pscore
          targetType: filePath
          filePath: scripts/Patch-Operations-SwaConfig.ps1
    shouldDeploy: eq(variables['Build.SourceBranch'], 'refs/heads/main')
    environments:
      - env: prd
        name: Production
        deploy: true
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
    azureSubscriptionFormat: '{0}-{1}-{2}-{3}-{4}'
    resourceGroupFormat: '{0}-{1}-{2}-{3}'
    artifactNamePrefix: prefix
    projectRoot: some/directory
    useDotNetSDK:
      packageType: sdk/runtime
      useGlobalJson: true/false
      workingDirectory: workingDirectory
      version: '6.0.x'
    build: envName
    sources:
      - name: authenticateSourceName
      - name: authenticateUsingTokenSourceName
        token: $(CustomerNugetFeedToken)
    sites:
      - name: 'siteName'
    webAppName: webAppName
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
      displayName: Custom Pre-Build Step
      azureSubscription: My-Azure-Connection
      env:
        KEY1: value1
        KEY2: $(Pipeline.Variable)
    postBuildScript:
      scriptType: pscore
      targetType: filePath
      filePath: scripts/post-build.ps1
      script: |
        Write-Host "Post-build script"
      arguments: -Environment Production
      failOnStderr: true
      showWarnings: true
      pwsh: true
      workingDirectory: $(Build.SourcesDirectory)
      displayName: Custom Post-Build Step
      azureSubscription: My-Azure-Connection
      env:
        KEY1: value1
        KEY2: $(Pipeline.Variable)
    shouldDeploy: eq(variables['Build.SourceBranch'], 'refs/heads/main')
    installSwaCli: true/false
    apiLocation: api
    environments:
      - env: dev
        name: Development
        webAppName: webAppName
        deploy: true/false
        dependsOn:
          - Stage
      - env: stg
        name: Staging
        webAppName: webAppName
        deploy: true/false
        deployAfter:
          - Development
        dependsOn:
          - Stage
      - env: prd
        name: Production
        webAppName: webAppName
        deploy: true/false
        deployAfter:
          - Staging
        dependsOn:
          - Stage
```
