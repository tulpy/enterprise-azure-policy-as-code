# Enterprise Azure Policy as Code

- repo structure
- global settings
- Run Build

Build-DeploymentPlans  -PacEnvironmentSelector "mg-epac"

Deploy-PolicyPlan -PacEnvironmentSelector "mg-epac"

Deploy-RolesPlan -PacEnvironmentSelector "mg-epac"

export-AzPolicyResources -ExemptionFiles json       
