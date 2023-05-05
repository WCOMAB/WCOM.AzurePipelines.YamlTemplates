# Overview

Azure DevOps Pipelines YAML template used to Build, validate and deploy resources to Azure using bicep templates. Publish bicep modules to an Azure Container Registry.

## Parameters

 **Parameter**           | **Type** | **Required** | **Default value**                                              | **Description**                                           
-------------------------|----------|--------------|----------------------------------------------------------------|-----------------------------------------------------------
 system                  | string   | Yes          |                                                                | The target system.                                        
 suffix                  | string   | Yes          |                                                                | The resource name suffix.                                 
 devopsOrg               | string   | Yes          |                                                                | The devops organisation.                                  
 build                   | string   | Yes          |                                                                | The environment to build.                                 
 azureSubscription       | string   | No           | format('azdo-{0}-{1}-{2}-{3}', devopsOrg, system, env, suffix) | The Azure Subscription name.                              
 azureSubscriptionFormat | string   | No           | 'azdo-{0}-{1}-{2}-{3}'                                         | The format for the azureSubscription.                     
 resourceGroup           | string   | No           | format('{0}-{1}-{2}', system, env, suffix)                     | The resource group name.                                  
 resourceGroupFormat     | string   | No           | '{0}-{1}-{2}'                                                  | The format for the resourceGroup name.                    
 acr                     | string   | No           | format('{0}acr{1}{2}', system, env, suffix)                    | The resource name.                                        
 environments            | array    | Yes          |                                                                | Array of environments and environment specific parameters.

## Per environment

 **Parameters**  | **Type** | **Required** | **Default value** | **Description**                                   
-----------------|----------|--------------|-------------------|---------------------------------------------------
 env             | array    | Yes          |                   | The target environment.                           
 name            | string   | Yes          |                   | The target environment name.                      
 extraParameters | string   | No           |                   | Used for passing extra parameters to the template.
 deploy          | bool     | No           | true              | Allow deploy to Resource group.                   
 publish         | bool     | No           | true              | Allow publish of modules to container registry.   

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
    build: envName
    shouldDeploy: eq(variables['Build.SourceBranch'], 'refs/heads/main')
    environments:
      - env: dev
        name: Development
        extraParameters: 'secretGreeting="$(SECRET_GREETING)" sqladminGroupId="$(sqladminGroupId)" sqladminGroupName="$(sqladminGroupName)"'
        deploy: true/false
        publish: true/false
```