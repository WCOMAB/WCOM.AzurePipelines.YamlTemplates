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
 environments            | array    | Yes          |                                                                | Array of environments and environment specific parameters.

## Source

 **Parameters** | **Type** | **Required** | **Default value**          | **Description**  
----------------|----------|--------------|----------------------------|------------------
 name           | string   | Yes          |                            | The source name.
 token          | string   | No           |                            | Access token.


## Per environment

 **Parameters** | **Type** | **Required** | **Default value**                                                     | **Description**                              
----------------|----------|--------------|-----------------------------------------------------------------------|----------------------------------------------
 env            | array    | Yes          |                                                                       | The target environment.
 name           | string   | Yes          |                                                                       | The target environment name.
 WebAppName     | string   | No           | format('{0}-{1}-{2}-{3}-{4}', system, webAppName, 'web', env, suffix) | The Web App name.                            
 deploy         | bool     | No           | true                                                                  | Allow deploy to Resource group.              
 deployAfter    | array    | No           |                                                                       | Object will be deployed after following env.

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
    build: envName
    shouldDeploy: eq(variables['Build.SourceBranch'], 'refs/heads/main')
    environments:
      - env: env
        name: Development
        webAppName: webAppName
        deploy: true/false
      - env: env
        name: Staging
        webAppName: webAppName
        deploy: true/false
        deployAfter:
          - Development
      - env: env
        name: Production
        webAppName: webAppName
        deploy: true/false
        deployAfter:
          - Staging
 ```
