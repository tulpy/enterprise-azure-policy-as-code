New-AzTenantDeployment -TemplateFile './managementGroups.bicep' -TemplateParameterFile './managementGroups-canary.bicepparam' -Location 'australiaeast' -Name 'canary-deployment'

New-AzTenantDeployment -TemplateFile './managementGroups.bicep' -TemplateParameterFile './managementGroups-production.bicepparam' -Location 'australiaeast' -Name 'production-deployment'