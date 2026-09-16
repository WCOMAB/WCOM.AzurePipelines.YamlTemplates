# Overview

Azure DevOps YAML template to **package**, **sign**, and **publish** release ZIPs for [WCOM Launch](https://github.com/WCOMAB/WCOM.Launch.Client).

There is **no compiler in this template**. The first stage only:

1. Fills **`packageStagingFolder`** (via **`preBuildScript`** — copy scripts or `dotnet publish`, depending on the app).
2. Optionally verifies **`entryPoint`** exists in that folder.
3. Optionally signs **`*.exe`** under that folder (**Trusted Signing**; see **`signExecutables`**).
4. Creates the versioned ZIP and a pipeline artifact.

A second stage uploads the ZIP to Azure Storage (and optionally **`manifest.json`**).

End users already have **WCOM.Launch.Client** on the machine; shortcut / install scripts are **not** part of this template.

Set pipeline **`name:`** in the **application repository** (not here), typically:

```yaml
name: $(Year:yyyy).$(Month).$(DayOfMonth)$(Rev:.r)
```

`$(Build.BuildNumber)` is the version segment in the ZIP file name.

## App types

### PowerShell / script apps (default expectation now)

Examples: a script tree (`.ps1` plus support folders), no MSBuild step.

- Implement **`preBuildScript`** only: copy or stage files into **`$(Build.ArtifactStagingDirectory)/Package`**.
- **`entryPoint`**: primary file in the ZIP (e.g. `Start.ps1`) for a post-stage sanity check; WCOM Launch runtime config (e.g. `powershell.exe` + arguments) lives in the install shortcut / future client options.
- Omit **`signExecutables`** (default **`false`**) and signing parameters. There is nothing to Authenticode-sign in a script-only ZIP.

Reuse **[dotnetcommon pre-build / post-build](../dotnet/README.md#pre-build)** only as the **script runner** shape (`preBuildScript` / `postBuildScript`), not the **[dotnet/stages.yml](../dotnet/README.md)** pipeline (no NuGet pack/publish here).

### .NET apps (later)

Examples: a publish output folder with **`MyApp.exe`** at the ZIP root.

Do **not** duplicate compile logic inside `wcomlaunchpackage`. When you add .NET WCOM Launch apps:

- Set **`signExecutables: true`** and **`shouldSign`** for main (same pattern as WCOM.Launch.Client).
- Either **`preBuildScript`** runs **`dotnet publish`** (or a repo script) with output directed to **`packageStagingFolder`**, then this template signs and zips, **or**
- Compose a **dotnet** template stage that produces a publish folder, then call **`publish_stages.yml`** only (split) once artifact hand-off is defined.

Same **`packageStagingFolder` → sign → ZIP → blob`** path for all app types; only the **staging** step differs.

## Storage layout

| Item | Pattern |
|------|---------|
| Storage account | Parameter `storageAccountName` (per app / environment) |
| Container | `blobContainer` (default `wcomlaunch`) |
| Product folder | `product` (WCOM Launch product id) |
| Release ZIP | `{product}/{packageNamePrefix}-{Build.BuildNumber}.zip` |
| Manifest | `{product}/manifest.json` (optional; see `writeManifest`) |

Example blob path (placeholders):

`{container}/{product}/{packageNamePrefix}-{Build.BuildNumber}.zip`

When **`writeManifest`** is `false` (default), uploading the ZIP can trigger **Wcom.Launch.Api** `UpdateProduct` to refresh `manifest.json` (if configured on that storage account).

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `build` | string | Yes | | Stage name suffix (e.g. `MyProduct`). Stage ids: `Package_{build}`, `Publish_{build}`. |
| `artifactNamePrefix` | string | No | `''` | Prefix for the pipeline artifact name (same pattern as **dotnet** / **sql** templates). Published artifact is `{artifactNamePrefix}{build}`. Set distinct prefixes when this template is used more than once in the same `azure-pipelines.yml`. |
| `product` | string | Yes | | Blob folder and API product id (no spaces). |
| `packageNamePrefix` | string | Yes | | ZIP base name without version, e.g. `src-ORG.Repo-Release`. |
| `entryPoint` | string | No | `''` | If set, fails when this file is missing under `packageStagingFolder` after staging. |
| `packageStagingFolder` | string | No | `$(Build.ArtifactStagingDirectory)/Package` | Folder that is signed (exes only) and zipped. |
| `preBuildScript` | object | No | `{}` | **Staging / packaging** step(s). Required in practice for script apps. |
| `postBuildScript` | object | No | `{}` | After the release ZIP is created, before the pipeline artifact is published (rare). |
| `storageAccountName` | string | Yes | | Target storage account; override for testing. |
| `blobContainer` | string | No | `wcomlaunch` | Blob container name. |
| `azureSubscription` | string | Yes | | ADO service connection for storage upload. |
| `signExecutables` | boolean | No | `false` | When `true`, run Trusted Signing on **`*.exe`** in `packageStagingFolder`. Use for **.NET publish** packages; leave `false` for script-only ZIPs. |
| `signingAzureSubscription` | string | When signing | | Service connection for signing (app pipeline; required when `signExecutables` is `true`). |
| `trustedSigningEndpoint` | string | When signing | | Trusted Signing endpoint (app pipeline). |
| `trustedSigningAccountName` | string | When signing | | Trusted Signing account name (app pipeline). |
| `trustedSigningCertificateProfileName` | string | When signing | | Certificate profile name (app pipeline). |
| `shouldSign` | object | No | main branch | Expression gating sign steps when `signExecutables` is `true`. |
| `shouldPublish` | object | No | main branch | Expression for publish stage. |
| `writeManifest` | boolean | No | `false` | Upload `{product}/manifest.json` when `true`. |
| `pool` | object | No | `windows-latest` | Agent pool. |

## Example — PowerShell app

```yaml
name: $(Year:yyyy).$(Month).$(DayOfMonth)$(Rev:.r)

resources:
  repositories:
    - repository: templates
      type: github
      endpoint: GitHubPublic
      name: WCOMAB/WCOM.AzurePipelines.YamlTemplates
      ref: refs/heads/main

stages:
  - template: wcomlaunchpackage/stages.yml@templates
    parameters:
      build: MyProduct
      product: MyProduct
      packageNamePrefix: src-ORG.MyRepo-Release
      entryPoint: Start.ps1
      storageAccountName: $(STORAGE_ACCOUNT_NAME)
      azureSubscription: $(AZURE_SERVICE_CONNECTION)
      shouldPublish: eq(variables['Build.SourceBranch'], 'refs/heads/main')
      writeManifest: false
      preBuildScript:
        scriptType: pscore
        targetType: inline
        pwsh: true
        displayName: Stage package files
        script: |
          & '$(Build.SourcesDirectory)/scripts/Build-WcomLaunchPackage.ps1' `
            -DestinationPath '$(Build.ArtifactStagingDirectory)/Package'
```

## Related

- **[dotnet](../dotnet/README.md)** — build/test/NuGet; compose with this template for .NET WCOM Launch apps when needed.
- **WCOM.Launch.Client** — machine launcher; signing reference pipeline.
- **intunepackage** — Intune `.intunewin` flow; different from WCOM Launch storage.
- **Agentic.Skills** — Cursor / Claude skill **`create-wcomlauncher`** (canonical) for app-repo `azure-pipelines.yml` and staging scripts; mirrors **`wcom-bicep-pipeline`** for Bicep repos.
