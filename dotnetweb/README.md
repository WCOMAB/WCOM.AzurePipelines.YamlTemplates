# Overview

Azure DevOps YAML template is used to deploy and publish web applications.

## Parameters

 **Parameter**     | **Type** | **Required** | **Default value**                                              | **Description**                                             
-------------------|----------|--------------|----------------------------------------------------------------|----------------------------------------------------         
 name              | string   | Yes          |                                                                | The target environment name.                                
 env               | string   | Yes          |                                                                | The target environment.                                     
 system            | string   | Yes          |                                                                | The target system.                                          
 suffix            | string   | Yes          |                                                                | The resource name suffix.                                   
 devopsOrg         | string   | Yes          |                                                                | The devops organisation.                                    
 build             | string   | Yes          |                                                                | The environment to build.                                   
 azureSubscription | string   | No           | format(coalesce(parameters.azureSubscriptionFormat, 'azdo-{0}-{1}-{2}-{3}'), parameters.devopsOrg, parameters.system, environment.env, parameters.suffix) | The Azure Subscription name.                                
 sources           | object   | Yes          |                                                                | NuGet feeds to authenticate against and optionally push to. 
 WebAppName        | string   | No           | format(coalesce(parameters.webAppNameFormat, '{0}-{1}-{2}-{3}-{4}'), parameters.system, parameters.webAppName, coalesce(parameters.webAppType, 'web'), environment.env, parameters.suffix) | The Web App Name

 ## Examples

 ### Minimum needed

 ```yaml
name: $(Year:yyyy).$(Month).$(DayOfMonth)$(Rev:.r)

pool:
  vmImage: ubuntu-latest

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
    devopsOrg: devopsOrg
    system: system
    suffix: suffix
    webAppName: webAppName
    build: envName
    shouldDeploy: eq(variables['Build.SourceBranch'], 'refs/heads/main')
    sources:
      - name: wcom-intern-ecdevops
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

pool:
  vmImage: ubuntu-latest

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
    devopsOrg: devopsOrg
    system: system
    suffix: suffix
    webAppName: webAppName
    build: envName
    shouldDeploy: eq(variables['Build.SourceBranch'], 'refs/heads/main')
    sources:
      - name: wcom-intern-ecdevops
    environments:
      - env: dev
        name: Development
        deploy: true/false
      - env: stg
        name: Staging
        deploy: true/false
        deployAfter:
          - Development
      - env: prd
        name: Production
        deploy: true/false
        deployAfter:
          - Staging
 ```