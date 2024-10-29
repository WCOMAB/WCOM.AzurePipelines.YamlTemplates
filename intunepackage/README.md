# Overview

Azure DevOps Pipelines YAML template used to build IntunePackage.

## Parameters

 **Parameter**           | **Type** | **Required** | **Default value**                                              | **Description**
-------------------------|----------|--------------|----------------------------------------------------------------|-------------------------------------------------------------
 artifactStorageName     | string   | Yes          |                                                                | Name of the storage account, where latestVersion.json is located.
 appName                 | string   | Yes          |                                                                | Name of the app on the storage account.
 indexSASToken           | string   | Yes          |                                                                | SAS Token to be used for accessing latestVersion.json.


## Examples

```yaml
name: $(Year:yyyy).$(Month).$(DayOfMonth)$(Rev:.r)

trigger:
- main

pool:
  vmImage: windows-latest

resources:
  repositories:
    - repository: templates
      type: github
      endpoint: GitHubPublic
      name: WCOMAB/WCOM.AzurePipelines.YamlTemplates
      ref: refs/heads/main

stages:
  - template: intunepackage/stages.yml@templates
    parameters:
      artifactStorageName: 'mystorageaccount'
      appName: 'myappname'
      indexSASToken: '$(indexSASToken)'
```
