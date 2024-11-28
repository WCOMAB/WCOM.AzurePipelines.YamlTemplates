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
# Publish Intune Package to Wcom
stages:
  - template: intunetemplate/stages.yml
    parameters:
      artifactStorageName: 'storageName'
      appName: 'MyApp'
      indexSASToken: '$(indexSASToken)'
      build: dev
      tenants:
        - name: 'Tenant1'
          azureSubscription: 'azdo-tenant1-intunedeploy'
          environments:
            - name: dev
              apps:
                - name: c
                  id: 'IntuneAppId'
            - name: stg
              deployAfter:
                - dev
              apps:
                - name: 'MyApp-stg'
                  id: 'IntuneAppId'
        - name: 'Tenant2'
          azureSubscription: 'azdo-tenant2-intunedeploy'
          environments:
            - name: dev
              apps:
                - name: 'MyApp-dev'
                  id: 'IntuneAppId'
            - name: stg
              deployAfter:
                - dev
              apps:
                - name: 'MyApp-stg'
                  id: 'IntuneAppId'
      shouldDeploy: eq(variables['Build.SourceBranch'], variables['deploy_branch'])
```
