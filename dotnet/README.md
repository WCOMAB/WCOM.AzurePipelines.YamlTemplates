# Overview

Azure DevOps Pipelines YAML template used to build, test, pack, and publish .NET libraries or applications.

## Parameters

 **Parameter**   | **Type** | **Required** | **Default value** | **Description**                           
-----------------|----------|--------------|-------------------|-------------------------------------------
 name            | string   | Yes          |                   | The target environment name.              
 env             | string   | Yes          |                   | The target environment.                   
 sources         | object   | Yes          |                   | Authenticate source feed.                 
 buildParameters | object   | No           |                   | Build Parameters.                         
 toolCommandName | string   | No           |                   | Tool command name.                        
 packAsTool      | bool     | No           |                   | Allow pack as tool.                       
 publish         | bool     | No           |                   | Allow publish to Feed.                    
 skipTests       | bool     | No           |                   | Allow tests to be skipped.                
 build           | string   | Yes          |                   | The environment to build.                 
 onlyPublish     | bool     | No           | true              | Allow update to source feed               
 projectSrc      | string   | No           | src               | Source folder to build, pack and publish. 

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
      - name: sourceName
        publish: true/false
    build: envName
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
- template: dotnet/stages.yml@templates
  parameters:
    shouldPublish: eq(variables['Build.SourceBranch'], 'refs/heads/main')
    sources:
      - name: sourceName
        publish: true/false
    buildParameters:
      - '-p:PackAsTool=true/false'
      - '-p:ToolCommandName=ToolCommandName'
    skipTests: true/false
    projectSrc: projectSrc
    build: envName
    environments:
      - env: env
        name: envName
```