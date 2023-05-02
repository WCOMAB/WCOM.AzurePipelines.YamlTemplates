# Overview

Azure DevOps YAML template is used to deploy and publish web applications.

## Parameters

 **Parameter**           | **Type** | **Required** | **Default value**                                              | **Description**                                             
-------------------------|----------|--------------|----------------------------------------------------------------|-------------------------------------------------------------
 envName                 | string   | Yes          |                                                                | The target environment name.                                
 env                     | string   | Yes          |                                                                | The target environment.                                     
 system                  | string   | Yes          |                                                                | The target system.                                          
 suffix                  | string   | Yes          |                                                                | The resource name suffix.                                   
 devopsOrg               | string   | Yes          |                                                                | The devops organisation.                                    
 build                   | string   | Yes          |                                                                | The environment to build.                                   
 sources                 | object   | No           |                                                                | NuGet feeds to authenticate against and optionally push to. 
 buildParameters         | object   | No           |                                                                | Build Parameters.                                           
 shouldDeploy            | string   | No           |                                                                | Check if deploy stage should run.                           
 webAppNameFormat        | string   | No           | '{0}-{1}-{2}-{3}-{4}'                                          | The format for the web app name.                            
 webAppType              | string   | No           | 'web'                                                          | The type/abbreviation for the web app.                      
 azureSubscription       | string   | No           | format('azdo-{0}-{1}-{2}-{3}', devopsOrg, system, env, suffix) | The Azure Subscription name.                                
 azureSubscriptionFormat | string   | No           | 'azdo-{0}-{1}-{2}-{3}'                                         | The format for the azureSubscription.

## Environment
 **Parameters** | **Type** | **Required** | **Default value**                                                     | **Description**                              
----------------|----------|--------------|-----------------------------------------------------------------------|----------------------------------------------
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
      - name: authenticateAndPushSourceName
        publish: true
      - name: authenticateUsingTokenSourceName
        token: $(CustomerNugetFeedToken)
      - name: authenticateUsingTokenAndPushSourceName
        publish: true
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
