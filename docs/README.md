# Overview

Azure DevOps Pipelines YAML template used to Build, validate and deploy resources to Azure using bicep templates. Publish bicep modules to an Azure Container Registry.

## Parameters

 **Parameter**     | **Type** | **Required** | **Default value**                                              | **Description**                                    
-------------------|----------|--------------|----------------------------------------------------------------|----------------------------------------------------
 name              | string   | Yes          |                                                                | The target environment name.                       
 env               | string   | Yes          |                                                                | The target environment.                            
 system            | string   | Yes          |                                                                | The target system.                                 
 suffix            | string   | Yes          |                                                                | The resource name suffix.                          
 devopsOrg         | string   | Yes          |                                                                | The devops organisation.                            
 build             | string   | Yes          |                                                                | The environment to build.                          
 azureSubscription | string   | No           | format('azdo-{0}-{1}-{2}-{3}', devopsOrg, system, env, suffix) | The Azure Subscription name.                       
 resourceGroup     | string   | No           | format('{0}-{1}-{2}', system, env, suffix)                     | The resource group name.                           
 acr               | string   | No           | format('{0}acr{1}{2}', system, env, suffix)                    | The resource name.                                 
 extraParameters   | string   | No           |                                                                | Used for passing extra parameters to the template. 
 deploy            | bool     | No           | true                                                           | Allow deploy to resource group.                    
 publish           | bool     | No           | true                                                           | Allow publish of modules to container registry.    
 Source            | string   | No           |                                                                | 
 ## Examples

 ### Minimum needed

```yaml
name: $(Year:yyyy).$(Month).$(DayOfMonth)$(Rev:.r)
trigger:
  - main
pool:
  vmImage: ubuntu-latest

resources:
  repositories:
    - repository: templates
      type: git
      name: General/Common.Template

stages:
- template: docs/stages.yml@templates
  parameters:
    system: 'lab'
    devopsOrg: 'wcom-intern'
    suffix: 'ecdo'
    build: Development
    source: 'wcom-intern-ecdevops'
    shouldDeploy: eq(variables['Build.SourceBranch'], 'refs/heads/main')
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
trigger:
  - main
pool:
  vmImage: ubuntu-latest
resources:
  repositories:
    - repository: templates
      type: git
      name: General/Common.Template
stages:
- template: docs/stages.yml@templates
  parameters:
    system: system
    devopsOrg: devopsOrg
    suffix: suffix
    build: envName
    source: source
    shouldDeploy: eq(variables['Build.SourceBranch'], 'refs/heads/main')
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
    assembly_pipelines:
      - pipeline: 'HelloWorldApp.Common'
```