# Overview

Azure DevOps Pipelines YAML template used to build and deploy databases.

## Parameters

 **Parameter**           | **Type** | **Required** | **Default value**                                              | **Description**
-------------------------|----------|--------------|----------------------------------------------------------------|-------------------------------------------------------------
 system                  | string   | Yes          |                                                                | The target system.
 suffix                  | string   | Yes          |                                                                | The resource name suffix.
 devopsOrg               | string   | Yes          |                                                                | The devops organisation.
 build                   | string   | Yes          |                                                                | The environment to build.
 buildParameters         | string   | No           |                                                                | Build Parameters.
 sources                 | object   | No           |                                                                | NuGet feeds to authenticate against and optionally push to.
 azureSubscription       | string   | No           | format('azdo-{0}-{1}-{2}-{3}', devopsOrg, system, env, suffix) | The Azure Subscription name.
 azureSubscriptionFormat | string   | No           | 'azdo-{0}-{1}-{2}-{3}'                                         | The format for the azureSubscription.
 resourceGroup           | string   | No           | format('{0}-{1}-{2}', system, env, suffix)                     | The resource group name.
 resourceGroupFormat     | string   | No           | '{0}-{1}-{2}'                                                  | The format for the resourceGroup name.
 serverNameFormat        | string   | No           | '{0}-{1}-{2}-{3}-{4}'                                          | Format of server name.
 sqlType                 | string   | No           | 'sql'                                                          | The sql type.
 databases               | array    | No           |                                                                | Array of databases.
 databaseFormat          | string   | No           | '{1}'                                                          | Format of database name.
 projectSrc	             | string	  | No	         | src	                                                          | Source folder to build, pack and publish.
 preBuildScript          | object   | No           |                                                                | Object containing pre-build parameters.
 environments            | array    | Yes          |                                                                | Array of environments and environment specific parameters.
 useDotNetSDK           | object   | No           |                   | Object containing parameters for specified dotnet SDK.
 artifactNamePrefix     | string   | No          |                                                                | Prefix for artifacts created by this pipeline.
 useFirewall            | bool     | No          |          true                                                      | Should SQL deployment create a temporary firewall rule or not.

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
----------------|----------|--------------|-------------------|------------------------------
 name           | string   | Yes          |                   | The source name.
 token          | string   | No           |                   | Access token.
 publish        | bool     | No           |                   | Allow update to NuGet source.

## Database

 **Parameters**   | **Type** | **Required** | **Default value** | **Description**
------------------|----------|--------------|-------------------|------------------------------
 name             | string   | Yes          |                   | The database name.
 deployParameters | array    | No           |                   | Optional string array of per database, for all environments additional deploy parameters.

## Per environment

 **Parameters**          | **Type** | **Required** | **Default value**                                                                                                                                                       | **Description**
-------------------------|----------|--------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------
 env                     | array    | Yes          |                                                                                                                                                                         | The target environment.
 name                    | string   | Yes          |                                                                                                                                                                         | The target environment name.
 deploy                  | bool     | No           | true                                                                                                                                                                    | Allow deploy to Resource group.
 connectionString        | string   | No           | format(connectionStringFormat, serverName, databaseFormat, system, env, suffix)                                                                                         | String to connect to Azure Sql database.
 connectionStringFormat  | string   | No           | 'Server=tcp:{0}.database.windows.net,1433;Initial Catalog={1};Authentication=Active Directory Default;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;' | Format of connection string.
 serverName              | string   | No           | format('{0}-{1}-{2}-{3}-{4}', system, serverName, 'sql', env, suffix)                                                                                                   | The server name.
 deployParameters        | array    | No           |                                                                                                                                                                         | Optional string array of per environment, for all databases additional deploy parameters.

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
- template: sql/stages.yml@templates
  parameters:
    devopsOrg: devopsOrg
    system: system
    suffix: suffix
    serverName: serverName
    build: envName
    shouldDeploy: eq(variables['Build.SourceBranch'], 'refs/heads/main')
    databases:
      - name: databaseName
    environments:
      - env: env
        name: envName
        deploy: true/false
      - env: env
        name: envName
        deploy: true/false
      - env: env
        name: envName
        deploy: true/false
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
- template: sql/stages.yml@templates
  parameters:
    artifactNamePrefix: prefix
    system: system
    suffix: suffix
    devopsOrg: devopsOrg
    sources:
      - name: authenticateSourceName
      - name: authenticateAndPushSourceName
        publish: true
      - name: authenticateUsingTokenSourceName
        token: $(CustomerNugetFeedToken)
      - name: authenticateUsingTokenAndPushSourceName
        token: $(CustomerNugetFeedToken)
        publish: true
    azureSubscriptionFormat: '{0}-{1}-{2}-{3}-{4}'
    resourceGroupFormat: '{0}-{1}-{2}-{3}'
    databaseFormat: '{1}'
    databases:
      - name: databaseName
      - name: secondDatabaseName
    sqlType: sqlType
    buildParameters:
      - '-p:buildParameter=buildParameterValue'
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
    useFirewall: true/false
    shouldDeploy: eq(variables['Build.SourceBranch'], 'refs/heads/main')
    environments:
      - env: dev
        name: Development
        deploy: true/false
      - env: stg
        name: Staging
        serverName: serverName
        connectionString: connectionString
        deploy: true/false
        deployAfter:
          - Development
      - env: prd
        name: Production
        serverNameFormat: '{0}-{1}-{2}'
        serverName: serverName
        connectionStringFormat: '{0}-{1}-{2}-{3}'
        connectionString: connectionString
        deploy: true/false
        deployAfter:
          - Staging
```