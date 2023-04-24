# Overview

Azure DevOps Pipelines YAML template used to build and deploy databases.

## Parameters

  **Parameter**           | **Type** | **Required** | **Default value**                                                                                                                                                       | **Description**                                             
-------------------------|----------|--------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------
 envName                 | string   | Yes          |                                                                                                                                                                         | The target environment name.                                
 env                     | string   | Yes          |                                                                                                                                                                         | The target environment.                                     
 system                  | string   | Yes          |                                                                                                                                                                         | The target system.                                          
 suffix                  | string   | Yes          |                                                                                                                                                                         | The resource name suffix.                                   
 devopsOrg               | string   | Yes          |                                                                                                                                                                         | The devops organisation.                                    
 build                   | string   | Yes          |                                                                                                                                                                         | The environment to build.                                   
 buildParameters         | string   | No           |                                                                                                                                                                         | Build Parameters.                                           
 sources                 | object   | No           |                                                                                                                                                                         | NuGet feeds to authenticate against and optionally push to. 
 deploy                  | bool     | No           | true                                                                                                                                                                    | Allow deploy to resource group.                             
 azureSubscription       | string   | No           | format('azdo-{0}-{1}-{2}-{3}', devopsOrg, system, env, suffix)                                                                                                          | The Azure Subscription name.                                
 azureSubscriptionFormat | string   | No           | 'azdo-{0}-{1}-{2}-{3}'                                                                                                                                                  | The format for the azureSubscription.                       
 resourceGroup           | string   | No           | format('{0}-{1}-{2}', system, env, suffix)                                                                                                                              | The resource group name.                                    
 resourceGroupFormat     | string   | No           | '{0}-{1}-{2}'                                                                                                                                                           | The format for the resourceGroup name.                      
 connectionString        | string   | No           | format(connectionStringFormat, serverName, databaseFormat, system, env, suffix)                                                                                         | String to connect to Azure Sql database.                    
 connectionStringFormat  | string   | No           | 'Server=tcp:{0}.database.windows.net,1433;Initial Catalog={1};Authentication=Active Directory Default;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;' | Format of connection string.                                
 serverName              | string   | No           | format('{0}-{1}-{2}-{3}-{4}', system, serverName, 'sql', env, suffix)                                                                                                   | The server name.                                            
 serverNameFormat        | string   | No           | '{0}-{1}-{2}-{3}-{4}'                                                                                                                                                   | Format of server name.                                      
 sqlType                 | string   | No           | 'sql'                                                                                                                                                                   | The sql type.                                               
 databases               | array    | No           |                                                                                                                                                                         | 	Array of databases.                                        
 databaseFormat          | string   | No           | '{1}'                                                                                                                                                                   | Format of database name.

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
    azureSubscriptionFormat: '{0}-{1}-{2}-{3}-{4}'
    resourceGroupFormat: '{0}-{1}-{2}-{3}'
    databaseFormat: '{1}'
    databases:
      - name: databaseName
      - name: secondDatabaseName
    sqlType: sqlType
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