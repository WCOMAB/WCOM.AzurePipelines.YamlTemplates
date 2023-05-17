
param tags object = {}

resource rgTags 'Microsoft.Resources/tags@2022-09-01' = {
  name: 'default'
  scope: resourceGroup()
  properties: {
    tags: tags
  }
}
