# Overview

Azure DevOps Pipelines YAML template used to build and deploy databases.

## Parameters

 **Parameter**          | **Type** | **Required** | **Default value**                                                     | **Description**                                             
------------------------|----------|--------------|-----------------------------------------------------------------------|-------------------------------------------------------------
 envName                | string   | Yes          |                                                                       | The target environment name.                                
 env                    | string   | Yes          |                                                                       | The target environment.                                     
 system                 | string   | Yes          |                                                                       | The target system.                                          
 suffix                 | string   | Yes          |                                                                       | The resource name suffix.                                   
 devopsOrg              | string   | Yes          |                                                                       | The devops organisation.                                    
 buildParameters        | object   | No           |                                                                       | Build Parameters.                                           
 sources                | object   | No           |                                                                       | NuGet feeds to authenticate against and optionally push to. 
 deploy                 | bool     | No           |                                                                       | Allow deploy to resource group.                             
 azureSubscription      | string   | No           | format('azdo-{0}-{1}-{2}-{3}', devopsOrg, system, env, suffix)        | The Azure Subscription name.                                
 resourceGroup          | string   | No           | format('{0}-{1}-{2}', system, env, suffix)                            | The resource group name.                                    
 connectionString       | string   | No           |                                                                       | String to connect to Azure Sql database.                    
 connectionStringFormat | string   | No           |                                                                       | Format of connection string.                                
 serverName             | string   | No           | format('{0}-{1}-{2}-{3}-{4}', system, serverName, 'sql', env, suffix) | Server name.                                                
 serverNameFormat       | string   | No           |                                                                       | Format of server name.                                      
 databases              | array    | Yes          |                                                                       | Array of databases.                                         
 databaseFormat         | string   | No           |                                                                       | Format of database name.

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
    system: system
    suffix: suffix
    devopsOrg: devopsOrg
    databaseFormat: '{1}'
    databases:
      - name: databaseName
      - name: secondDatabaseName
    buildParameters:
      - '-p:buildParameter=buildParameterValue'
    build: envName
    shouldDeploy: eq(variables['Build.SourceBranch'], 'refs/heads/main')
    environments:
      - env: env
        name: Development
        deploy: true/false
      - env: env
        name: Staging
        serverName: serverName
        connectionString: connectionString
        deploy: true/false
        deployAfter:
          - Development
      - env: env
        name: Production
        serverNameFormat: '{0}-{1}-{2}'
        serverName: serverName
        connectionStringFormat: '{0}-{1}-{2}-{3}'
        connectionString: connectionString
        deploy: true/false
        deployAfter:
          - Staging
```