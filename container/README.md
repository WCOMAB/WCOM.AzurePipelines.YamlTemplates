# Overview

Azure DevOps YAML template is used to build, deploy to container registries, and publish images to Azure Container Apps.

## Parameters

| **Parameter**      | **Type** | **Required** | **Default value** | **Description**                                              |
|--------------------|----------|--------------|-------------------|--------------------------------------------------------------|
| build              | string   | Yes          |                   | The environment to build.                                    |
| dependsOn          | array    | No           |                   | Allows for build to depend on an optional stage.             |
| shouldDeploy       | bool     | No           |                   | Check if deploy stage should run.                            |
| azureSubscription  | string   | No           |                   | Runs az acr login when servers omit credential fields.       |
| resourceGroup      | string   | No           |                   | Resource group containing the container app.                 |
| environments       | array    | Yes          |                   | Array of environments and environment specific parameters.   |
| container          | object   | Yes          |                   | Container configuration for containerized deployments.       |

## Container

| **Parameters**        | **Type** | **Required** | **Default value**      | **Description**                                                |
|-----------------------|----------|--------------|------------------------|----------------------------------------------------------------|
| deploy                | bool     | No           |                        | Flag to deploy container.                                      |
| csproj                | string   | No           |                        | Path to the .csproj file for container build.                  |
| dockerfile            | string   | No           |                        | Path to Dockerfile used for container build.                   |
| dockerdirectory       | string   | No           | '.'                    | Build context directory for docker/buildah.                    |
| tool                  | string   | No           | docker                 | Container build tool. docker or buildah.                       |
| repository            | string   | Yes          |                        | Container repository name.                                     |
| artifact              | string   | No           | repository             | Name of the container artifact.                                |
| baseimage             | string   | No           |                        | Base image for dotnet publish container build.                 |
| port                  | string   | No           | '8080'                 | Port exposed by the container.                                 |
| tag                   | string   | No           | $(Build.BuildNumber)   | Tag for the container image.                                   |
| latest                | bool     | No           | true                   | Whether to tag the container as latest.                        |
| pullRegistryUsername  | string   | No           |                        | Username for pulling base images.                              |
| pullRegistryPassword  | string   | No           |                        | Password for pulling base images.                              |
| servers               | array    | No           |                        | Array of server configurations for container deployment.       |
| environments          | array    | No           |                        | Array of environments for Azure Container App publishing.      |

## Container Servers

| **Parameters**    | **Type** | **Required** | **Default value**            | **Description**                                                     |
|-------------------|----------|--------------|------------------------------|---------------------------------------------------------------------|
| name              | string   | Yes          |                              | Registry host (for example myregistry.azurecr.io).                  |
| registry          | string   | No           | container.repository         | Repository path after the registry host on push/import.             |
| username          | string   | No           |                              | Pair with password for regctl login.                                |
| password          | string   | No           |                              | Omit username or password to use az acr login instead.              |
| azureSubscription | string   | No           | parameters.azureSubscription | Overrides root service connection for az acr login.                 |
| environment       | string   | No           | parameters.build             | Environment to deploy to.                                           |
| latest            | bool     | No           | container.latest             | Whether to tag the container as latest on this server.              |
| deployAfter       | array    | No           |                              | List of publish stage names to depend on.                           |
| pool              | object   | No           |                              | Optional pool to run the stage on.                                  |

## Container Environments

| **Parameters**   | **Type** | **Required** | **Default value** | **Description**                                           |
|------------------|----------|--------------|-------------------|-----------------------------------------------------------|
| name             | string   | Yes          |                   | Name of the environment.                                  |
| environment      | string   | Yes          |                   | Azure DevOps environment name for the deployment.         |
| containerAppName | string   | Yes          |                   | Name of the Azure Container App to update.                |
| azureSubscription| string   | Yes          |                   | Azure Resource Manager subscription for the update.       |
| resourceGroup    | string   | Yes          |                   | Resource group containing the container app.              |
| sourceServer     | string   | Yes          |                   | Registry server name where the image exists.              |
| containerAppArgs | string   | No           |                   | Additional arguments passed to `az containerapp update`.  |
| deployAfter      | array    | No           |                   | List of stage names that must publish before this stage.  |
| pool             | object   | No           |                   | Optional pool to run the stage on.                        |

## Examples

### Extend from dotnetweb template

```yaml
stages:
- template: dotnetweb/stages.yml@templates
  parameters:
    build: Development
    azureSubscription: My-Azure-ServiceConnection
    environments:
      - env: dev
        name: Development
        deploy: false
    container:
      csproj: src/MyApp/MyApp.csproj
      repository: myapp
      artifact: myapp
      baseimage: mcr.microsoft.com/dotnet/aspnet:10.0
      servers:
        - name: myregistry.azurecr.io
      environments:
        - name: Development
          environment: dev
          containerAppName: myapp-dev
          azureSubscription: My-Azure-Subscription
          resourceGroup: myapp-dev-rg
          sourceServer: myregistry.azurecr.io
```

### Standalone container template (dockerfile)

```yaml
stages:
- template: container/stages.yml@templates
  parameters:
    build: test
    environments:
      - env: test
        name: test
    shouldDeploy: true
    azureSubscription: My-Azure-Subscription
    resourceGroup: my-rg
    container:
      deploy: true
      dockerfile: dockerfile
      dockerdirectory: .
      tool: docker
      repository: myimage
      artifact: myimage
      servers:
        - name: myregistry.azurecr.io
      environments:
        - name: Test
          environment: test
          containerAppName: myapp-test
          azureSubscription: My-Azure-Subscription
          resourceGroup: my-rg
          sourceServer: myregistry.azurecr.io
```
