# Overview

Azure DevOps Pipelines YAML template used to build, provision, and deploy .NET Aspire applications using the Azure Developer CLI (azd).

## Parameters

 **Parameter**           | **Type** | **Required** | **Default value**                                              | **Description**
-------------------------|----------|--------------|----------------------------------------------------------------|-----------------------------------------------------------
 system                  | string   | Yes          |                                                                | The target system.
 suffix                  | string   | Yes          |                                                                | The resource name suffix.
 devopsOrg               | string   | Yes          |                                                                | The devops organisation.
 build                   | string   | Yes          |                                                                | The environment to build.
 whatIfDeploy            | bool     | No           | false                                                          | Use whatIf deployment in build stage to validate deployment of resources.
 azureSubscription       | string   | No           | format('azdo-{0}-{1}-{2}-{3}', devopsOrg, system, env, suffix) | The Azure Subscription name.
 azureSubscriptionFormat | string   | No           | 'azdo-{0}-{1}-{2}-{3}'                                         | The format for the azureSubscription.
 useDotNetSDK            | object   | No           |                                                                | Object containing parameters for specified dotnet SDK.
 shouldDeploy            | boolean  | No           | true                                                           | Conditional flag to control whether deployment should occur.
 sources                 | object   | No           |                                                                | NuGet feeds to authenticate against.
 dependsOn               | array    | No           |                                                                | Allows for build to depend on an optional stage.
 environments            | array    | Yes          |                                                                | Array of environments and environment specific parameters.
 projectSrc              | string   | No           | $(Build.SourcesDirectory)                                      | Parameter to manually set the root directory for the Aspire project.
 publishCodeCoverage     | bool     | No           | true                                                           | When false, skips merging and publishing code coverage.
 dpi                     | object   | No           |                                                                | Settings relating to Dependency reports using DPI tool. Use `dpi.azureSubscription`, not the job deploy connection.

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
 source         | string   | No           |                   | The source URL if the pipeline is adding sources.
 publish        | bool     | No           |                   | Allow update to NuGet source.
 onlyDeploy     | bool     | No           |                   | Decides of a source should be used to publish nugets or not.

## Per environment

 **Parameters**      | **Type** | **Required** | **Default value** | **Description**
---------------------|----------|--------------|-------------------|---------------------------------------------
 env                 | string   | Yes          |                   | The target environment identifier (e.g., dev, test, prod).
 name                | string   | Yes          |                   | The target environment name.
 deploy              | bool     | No           | true              | Flag to determine if deployment should happen for this environment.
 devOpsName          | string   | No           |                   | The environment name in Azure DevOps (defaults to name if not specified).
 deployAfter         | array    | No           |                   | List of environment names that should be deployed before this one.
 dependsOn           | array    | No           |                   | List of stage names that this deployment depends on.
 environmentVariables| array    | No           |                   | Collection of key-value pairs for environment variables to be passed to azd commands.

## dpi

When `report` is true and `dpi.azureSubscription` is set, DPI runs inside `AzureCLI@2` and reports through the Logs Ingestion API (`DefaultAzureCredential` from the service connection). The service connection principal needs **Monitoring Metrics Publisher** on the data collection rule. Workload identity federation is preferred (no client secret). Do not set `WorkspaceId`/`SharedKey` together with Logs Ingestion settings. On Linux agents, put `NUGETREPORTSETTINGS_ENDPOINT` and `NUGETREPORTSETTINGS_RULEID` in a variable group (ADO exposes those as uppercase env vars); the template copies them onto the PascalCase names DPI reads.

The Aspire **job** `azureSubscription` (from `azureSubscriptionFormat`) is the azd deploy identity and is **not** used for DPI. Set a nested `dpi.azureSubscription` to opt in.

When `report` is true and `dpi.azureSubscription` is omitted, the existing Data Collector `pwsh` path is used.

 **Parameters**     | **Type**          | **Required** | **Default value**     | **Description**
--------------------|-------------------|--------------|-----------------------|------------------
 report             | bool              | No           | false                 | Boolean to create report or not.
 azureSubscription  | string            | No           |                       | ARM service connection for Logs Ingestion. When set, report uses Azure CLI instead of `pwsh`. Independent of the Aspire deploy connection.
 Endpoint           | string            | No           |                       | Logs Ingestion API endpoint. Required in practice when `azureSubscription` is set.
 RuleId             | string            | No           |                       | Data collection rule immutable ID. Required in practice when `azureSubscription` is set.
 Stream             | string            | No           | Custom-NuGetReport    | DCR **input** stream name (not the table stream `Custom-NuGetReport_CL`).
 WorkspaceId        | string (secret)   | No           |                       | Deprecated. Log Analytics workspace id for the Data Collector path when `azureSubscription` is omitted.
 SharedKey          | string (secret)   | No           |                       | Deprecated. Workspace shared key for the Data Collector path when `azureSubscription` is omitted.

## Example

```yaml
name: $(Year:yyyy).$(Month).$(DayOfMonth)$(Rev:.r)

trigger:
- main

pool: 'self-hosted-pool'

parameters:
- name: DEPLOY_FEATURE_BRANCH
  displayName: Deployment from feature branch
  type: string
  default: 'no'
  values:
  - 'no'
  - 'yes'

variables:
- name: deploy_branch
  ${{ if eq(parameters.DEPLOY_FEATURE_BRANCH, 'yes') }}:
    value: ${{ variables['Build.SourceBranch'] }}
  ${{ if eq(parameters.DEPLOY_FEATURE_BRANCH, 'no') }}:
    value: 'refs/heads/main'

resources:
  repositories:
    - repository: templates
      type: github
      endpoint: GitHubPublic
      name: WCOMAB/WCOM.AzurePipelines.YamlTemplates
      ref: refs/heads/main

stages:
- template: dotnetaspire/stages.yml@templates
  parameters:
    system: myapp
    devopsOrg: myorg
    build: test
    whatIfDeploy: true
    azureSubscriptionFormat: 'azure-devops-deployment-myapp-{2}'
    shouldDeploy: eq(variables['Build.SourceBranch'], variables['deploy_branch'])
    projectSrc: $(Build.SourcesDirectory)
    publishCodeCoverage: true/false
    dpi:
      report: true
      azureSubscription: dpi-logs-ingestion
      Endpoint: $(NUGETREPORTSETTINGS_ENDPOINT)
      RuleId: $(NUGETREPORTSETTINGS_RULEID)
    sources:
      - name: NuGetFeed
    environments:
      - env: test
        name: Test
        deploy: true
        environmentVariables:
          - key: AZD_INITIAL_ENVIRONMENT_CONFIG
            value: $(AZD_INITIAL_ENVIRONMENT_CONFIG)
          - key: AppSettings__SecureKey
            value: $(test_AppSettings__SecureKey)
          - key: ServiceSettings__Password
            value: $(test_ServiceSettings__Password)
          - key: API_KEY
            value: $(test_API_KEY)
      - env: staging
        name: Staging
        deploy: true
        deployAfter:
          - Test
        environmentVariables:
          - key: AZD_INITIAL_ENVIRONMENT_CONFIG
            value: $(AZD_INITIAL_ENVIRONMENT_CONFIG)
          - key: AppSettings__SecureKey
            value: $(staging_AppSettings__SecureKey)
          - key: ServiceSettings__Password
            value: $(staging_ServiceSettings__Password)
          - key: API_KEY
            value: $(staging_API_KEY)
      - env: prod
        name: Production
        deploy: true
        deployAfter:
          - Staging
        environmentVariables:
          - key: AZD_INITIAL_ENVIRONMENT_CONFIG
            value: $(AZD_INITIAL_ENVIRONMENT_CONFIG)
          - key: AppSettings__SecureKey
            value: $(prod_AppSettings__SecureKey)
          - key: ServiceSettings__Password
            value: $(prod_ServiceSettings__Password)
          - key: API_KEY
            value: $(prod_API_KEY)
``` 