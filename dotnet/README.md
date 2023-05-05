# Overview

Azure DevOps Pipelines YAML template used to build, test, pack, and publish .NET libraries or applications.

## Parameters

 **Parameter**   | **Type** | **Required** | **Default value** | **Description**                           
-----------------|----------|--------------|-------------------|-------------------------------------------
 sources         | object   | Yes          |                   | NuGet feeds to authenticate against and optionally push to.                  
 buildParameters | object   | No           |                   | Build Parameters.                         
 toolCommandName | string   | No           |                   | Tool command name.                        
 publish         | bool     | No           |                   | Allow publish to Feed.                    
 skipTests       | bool     | No           |                   | Allow tests to be skipped.                
 build           | string   | Yes          |                   | The environment to build.                 
 onlyPublish     | bool     | No           | true              | Allow update to source feed.               
 projectSrc      | string   | No           | src               | Source folder to build, pack and publish. 
 environments    | array    | Yes          |                   | Array of environments and environment specific parameters.

## Source

 **Parameters** | **Type** | **Required** | **Default value** | **Description**  
----------------|----------|--------------|-------------------|------------------
 name           | string   | Yes          |                   | The source name.
 token          | string   | No           |                   | Access token.
 publish        | bool     | No           |                   | Allow update to NuGet source.

## Per environment

 **Parameters** | **Type** | **Required** | **Default value** | **Description**                             
----------------|----------|--------------|-------------------|---------------------------------------------
 env            | array    | Yes          |                   | The target environment.
 name           | string   | Yes          |                   | The target environment name.

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
- template: dotnet/stages.yml@templates
  parameters:
    shouldPublish: eq(variables['Build.SourceBranch'], 'refs/heads/main')
    sources:
      - name: authenticateUsingTokenSourceName
        token: $(CustomerNugetFeedToken)
    build: envName
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
- template: dotnet/stages.yml@templates
  parameters:
    shouldPublish: eq(variables['Build.SourceBranch'], 'refs/heads/main')
    sources:
      - name: authenticateSourceName
      - name: authenticateAndPushSourceName
        publish: true
      - name: authenticateUsingTokenSourceName
        token: $(CustomerNugetFeedToken)
      - name: authenticateUsingTokenAndPushSourceName
        token: $(CustomerNugetFeedToken)
        publish: true
    buildParameters:
      - '-p:PackAsTool=true/false'
      - '-p:ToolCommandName=ToolCommandName'
    skipTests: true/false
    projectSrc: projectSrc
    build: envName
    environments:
      - env: dev
        name: Development
```