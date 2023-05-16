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

module tagsTest 'modules/tags.bicep' = {
  name: 'default'
  params: {
    tags: tags
  }
}
