targetScope = 'tenant'

metadata name = 'ALZ Bicep - Management Groups Module'
metadata description = 'ALZ Bicep Module to set up Management Group structure'
metadata version = '1.0.0'
metadata author = 'Insight APAC Platform Engineering'

@description('Prefix for the management group hierarchy. This management group will be created as part of the deployment.')
@minLength(2)
@maxLength(15)
param topLevelManagementGroupPrefix string = 'alz'

@description('Optional suffix for the management group hierarchy. This suffix will be appended to management group names/IDs. Include a preceding dash if required. Example: -suffix')
@maxLength(10)
param topLevelManagementGroupSuffix string = ''

@description('Display name for top level management group. This name will be applied to the management group prefix defined in topLevelManagementGroupPrefix parameter.')
@minLength(2)
param topLevelManagementGroupDisplayName string = 'Azure Landing Zones'

@description('Optional parent for Management Group hierarchy, used as intermediate root Management Group parent, if specified. If empty, default, will deploy beneath Tenant Root Management Group.')
param parTopLevelManagementGroupParentId string = ''

@description('Deploys Corp & Online Management Groups beneath Landing Zones Management Group if set to true.')
param landingZoneMgAlzDefaultsEnable bool = true

@description('Deploys Management, Identity and Connectivity Management Groups beneath Platform Management Group if set to true.')
param platformMgAlzDefaultsEnable bool = true

@description('Deploys Confidential Corp & Confidential Online Management Groups beneath Landing Zones Management Group if set to true.')
param landingZoneMgConfidentialEnable bool = false

@description('Dictionary Object to allow additional or different child Management Groups of Landing Zones Management Group to be deployed.')
param landingZoneMgChildren object = {}

@description('Dictionary Object to allow additional or different child Management Groups of Platform Management Group to be deployed.')
param platformMgChildren object = {}

// Platform and Child Management Groups
var varPlatformMg = {
  name: '${topLevelManagementGroupPrefix}-platform${topLevelManagementGroupSuffix}'
  displayName: 'Platform'
}

// Used if platformMgAlzDefaultsEnable == true
var platformMgChildrenAlzDefault = {
  connectivity: {
    displayName: 'Connectivity'
  }
  identity: {
    displayName: 'Identity'
  }
  management: {
    displayName: 'Management'
  }
}

// Landing Zones & Child Management Groups
var varLandingZoneMg = {
  name: '${topLevelManagementGroupPrefix}-landingzones${topLevelManagementGroupSuffix}'
  displayName: 'Landing Zones'
}

// Used if landingZoneMgAlzDefaultsEnable == true
var varLandingZoneMgChildrenAlzDefault = {
  corp: {
    displayName: 'Corp'
  }
  online: {
    displayName: 'Online'
  }
}

// Used if landingZoneMgConfidentialEnable == true
var varLandingZoneMgChildrenConfidential = {
  'confidential-corp': {
    displayName: 'Confidential Corp'
  }
  'confidential-online': {
    displayName: 'Confidential Online'
  }
}

// Build final object based on input parameters for child MGs of LZs
var landingZoneMgChildrenUnioned = (landingZoneMgAlzDefaultsEnable && landingZoneMgConfidentialEnable && (!empty(landingZoneMgChildren)))
  ? union(varLandingZoneMgChildrenAlzDefault, varLandingZoneMgChildrenConfidential, landingZoneMgChildren)
  : (landingZoneMgAlzDefaultsEnable && landingZoneMgConfidentialEnable && (empty(landingZoneMgChildren)))
      ? union(varLandingZoneMgChildrenAlzDefault, varLandingZoneMgChildrenConfidential)
      : (landingZoneMgAlzDefaultsEnable && !landingZoneMgConfidentialEnable && (!empty(landingZoneMgChildren)))
          ? union(varLandingZoneMgChildrenAlzDefault, landingZoneMgChildren)
          : (landingZoneMgAlzDefaultsEnable && !landingZoneMgConfidentialEnable && (empty(landingZoneMgChildren)))
              ? varLandingZoneMgChildrenAlzDefault
              : (!landingZoneMgAlzDefaultsEnable && landingZoneMgConfidentialEnable && (!empty(landingZoneMgChildren)))
                  ? union(varLandingZoneMgChildrenConfidential, landingZoneMgChildren)
                  : (!landingZoneMgAlzDefaultsEnable && landingZoneMgConfidentialEnable && (empty(landingZoneMgChildren)))
                      ? varLandingZoneMgChildrenConfidential
                      : (!landingZoneMgAlzDefaultsEnable && !landingZoneMgConfidentialEnable && (!empty(landingZoneMgChildren)))
                          ? landingZoneMgChildren
                          : (!landingZoneMgAlzDefaultsEnable && !landingZoneMgConfidentialEnable && (empty(landingZoneMgChildren)))
                              ? {}
                              : {}
var platformMgChildrenUnioned = (platformMgAlzDefaultsEnable && (!empty(platformMgChildren)))
  ? union(platformMgChildrenAlzDefault, platformMgChildren)
  : (platformMgAlzDefaultsEnable && (empty(platformMgChildren)))
      ? platformMgChildrenAlzDefault
      : (!platformMgAlzDefaultsEnable && (!empty(platformMgChildren)))
          ? platformMgChildren
          : (!platformMgAlzDefaultsEnable && (empty(platformMgChildren))) ? {} : {}

// Sandbox Management Group
var varSandboxMg = {
  name: '${topLevelManagementGroupPrefix}-sandbox${topLevelManagementGroupSuffix}'
  displayName: 'Sandbox'
}

// Decomissioned Management Group
var varDecommissionedMg = {
  name: '${topLevelManagementGroupPrefix}-decommissioned${topLevelManagementGroupSuffix}'
  displayName: 'Decommissioned'
}

// Level 1
resource topLevelMg 'Microsoft.Management/managementGroups@2023-04-01' = {
  name: '${topLevelManagementGroupPrefix}${topLevelManagementGroupSuffix}'
  properties: {
    displayName: topLevelManagementGroupDisplayName
    details: {
      parent: {
        id: empty(parTopLevelManagementGroupParentId)
          ? '/providers/Microsoft.Management/managementGroups/${tenant().tenantId}'
          : parTopLevelManagementGroupParentId
      }
    }
  }
}

// Level 2
resource platformMg 'Microsoft.Management/managementGroups@2023-04-01' = {
  name: varPlatformMg.name
  properties: {
    displayName: varPlatformMg.displayName
    details: {
      parent: {
        id: topLevelMg.id
      }
    }
  }
}

resource landingZonesMg 'Microsoft.Management/managementGroups@2023-04-01' = {
  name: varLandingZoneMg.name
  properties: {
    displayName: varLandingZoneMg.displayName
    details: {
      parent: {
        id: topLevelMg.id
      }
    }
  }
}

resource sandboxMg 'Microsoft.Management/managementGroups@2023-04-01' = {
  name: varSandboxMg.name
  properties: {
    displayName: varSandboxMg.displayName
    details: {
      parent: {
        id: topLevelMg.id
      }
    }
  }
}

resource decommissionedMg 'Microsoft.Management/managementGroups@2023-04-01' = {
  name: varDecommissionedMg.name
  properties: {
    displayName: varDecommissionedMg.displayName
    details: {
      parent: {
        id: topLevelMg.id
      }
    }
  }
}

// Level 3 - Child Management Groups under Landing Zones MG
resource landingZonesChildMgs 'Microsoft.Management/managementGroups@2023-04-01' = [
  for mg in items(landingZoneMgChildrenUnioned): if (!empty(landingZoneMgChildrenUnioned)) {
    name: '${topLevelManagementGroupPrefix}-landingzones-${mg.key}${topLevelManagementGroupSuffix}'
    properties: {
      displayName: mg.value.displayName
      details: {
        parent: {
          id: landingZonesMg.id
        }
      }
    }
  }
]

//Level 3 - Child Management Groups under Platform MG
resource platformChildMgs 'Microsoft.Management/managementGroups@2023-04-01' = [
  for mg in items(platformMgChildrenUnioned): if (!empty(platformMgChildrenUnioned)) {
    name: '${topLevelManagementGroupPrefix}-platform-${mg.key}${topLevelManagementGroupSuffix}'
    properties: {
      displayName: mg.value.displayName
      details: {
        parent: {
          id: platformMg.id
        }
      }
    }
  }
]

// Output Management Group IDs
output topLevelManagementGroupId string = topLevelMg.id

output platformManagementGroupId string = platformMg.id
output platformChildrenManagementGroupIds array = [
  for mg in items(platformMgChildrenUnioned): '/providers/Microsoft.Management/managementGroups/${topLevelManagementGroupPrefix}-platform-${mg.key}${topLevelManagementGroupSuffix}'
]

output landingZonesManagementGroupId string = landingZonesMg.id
output landingZoneChildrenManagementGroupIds array = [
  for mg in items(landingZoneMgChildrenUnioned): '/providers/Microsoft.Management/managementGroups/${topLevelManagementGroupPrefix}-landingzones-${mg.key}${topLevelManagementGroupSuffix}'
]

output sandboxManagementGroupId string = sandboxMg.id

output decommissionedManagementGroupId string = decommissionedMg.id

// Output Management Group Names
output topLevelManagementGroupName string = topLevelMg.name

output platformManagementGroupName string = platformMg.name
output platformChildrenManagementGroupNames array = [for mg in items(platformMgChildrenUnioned): mg.value.displayName]

output landingZonesManagementGroupName string = landingZonesMg.name
output landingZoneChildrenManagementGroupNames array = [
  for mg in items(landingZoneMgChildrenUnioned): mg.value.displayName
]

output sandboxManagementGroupName string = sandboxMg.name

output decommissionedManagementGroupName string = decommissionedMg.name
