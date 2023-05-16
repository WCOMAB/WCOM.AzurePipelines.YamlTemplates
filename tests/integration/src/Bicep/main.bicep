param env string
param version string
param system string
param suffix string

var tags = {
Creator: 'Bicep-${system}'
Dimension: system
BillingDimension: system
Environment: env
}

resource rgTags 'Microsoft.Resources/tags@2022-09-01' = {
  name: 'default'
  scope: resourceGroup()
  properties: {
    tags: tags
  }
}
