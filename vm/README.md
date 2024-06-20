# Overview

Azure DevOps Pipelines YAML template used to start Azure VMs when needed.

## Parameters

 **Parameter**           | **Type** | **Required** | **Default value**                                              | **Description**
-------------------------|----------|--------------|----------------------------------------------------------------|-----------------------------------------------------------
 vms                     | array   | Yes          |                                                                | Array of vm objects





## vm properties

 **Parameter**           | **Type** | **Required** | **Default value**                                              | **Description**
-------------------------|----------|--------------|----------------------------------------------------------------|-----------------------------------------------------------
 system                  | string   | Yes          |                                                                | The target system.
 suffix                  | string   | Yes          |                                                                | The resource name suffix.
 devopsOrg               | string   | Yes          |                                                                | The devops organisation.
 env                     | string   | Yes          |                                                                | Environment short name.
 envName                 | string   | Yes          |                                                                | Environment long name.
 vmName                  | string   | No           | format('{0}-{1}-{2}', system, env, suffix)                     | The virtual machine name.
 vmNameFormat            | string   | No           | '{0}-{1}-{2}'                                                  | The format for the virtual machine name.
 azureSubscription       | string   | No           | format('azdo-{0}-{1}-{2}-{3}', devopsOrg, system, env, suffix) | The Azure Subscription name.
 azureSubscriptionFormat | string   | No           | 'azdo-{0}-{1}-{2}-{3}'                                         | The format for the azureSubscription.
 resourceGroup           | string   | No           | format('{0}-{1}-{2}', system, env, suffix)                     | The resource group name.
 resourceGroupFormat     | string   | No           | '{0}-{1}-{2}'                                                  | The format for the resourceGroup name.


## Examples

### Minimum needed

```yaml
name: $(Year:yyyy).$(Month).$(DayOfMonth)$(Rev:.r)

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
- template: vm/stages.yml@templates
  parameters:
    vms:
      - env: dev
        envName: Development
        vmName : ''
        azureSubscription: ''
        resourceGroup: ''
        system: system
        devopsOrg: devopsOrg
        suffix: suffix
    
```

### Optional parameters

```yaml
name: $(Year:yyyy).$(Month).$(DayOfMonth)$(Rev:.r)

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
- template: vm/stages.yml@templates
  parameters:
    vms:
      - env: dev
        envName: Development
        vmName : ''
        azureSubscription: ''
        resourceGroup: ''
        system: system
        devopsOrg: devopsOrg
        suffix: suffix
        azureSubscriptionFormat: ''
        resourceGroupFormat: ''
        vmNameFormat: ''
```