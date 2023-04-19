# Overview

Azure DevOps Pipelines YAML template used to Build, validate, and deploy resources to Azure using bicep templates. Publish bicep modules to an Azure Container Registry.

## Parameters

 **Parameter**     | **Type** | **Required** | **Default value**                                              | **Description**                                    
-------------------|----------|--------------|----------------------------------------------------------------|----------------------------------------------------
 name              | string   | Yes          |                                                                | The target environment name.                       
 env               | string   | Yes          |                                                                | The target environment.                            
 system            | string   | Yes          |                                                                | The target system.                                 
 suffix            | string   | Yes          |                                                                | The resource name suffix.                          
 devopsOrg         | string   | Yes          |                                                                | The devps organisation.                            
 build             | string   | Yes          |                                                                | The environment to build.                          
 azureSubscription | string   | No           | format('azdo-{0}-{1}-{2}-{3}', devopsOrg, system, env, suffix) | The Azure Subscription name.                       
 resourceGroup     | string   | No           | format('{0}-{1}-{2}', system, env, suffix)                     | The resource group name.                           
 acr               | string   | No           | format('{0}acr{1}{2}', system, env, suffix)                    | The resource name.                                 
 extraParameters   | string   | No           |                                                                | Used for passing extra parameters to the template. 
 deploy            | bool     | No           | true                                                           | Allow deploy to resource group.                    
 publish           | bool     | No           | true                                                           | Allow publish of modules to container registry.    
                   |          |              |                                                                |

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
      - env: env
        name: envName
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
    build: envName
    shouldDeploy: eq(variables['Build.SourceBranch'], 'refs/heads/main')
    environments:
      - env: env
        name: envName
        extraParameters: 'secretGreeting="$(SECRET_GREETING)" sqladminGroupId="$(sqladminGroupId)" sqladminGroupName="$(sqladminGroupName)"'
        deploy: True/False
        publish: True/False
```