# Enterprise Azure Policy as Code

- Go through the repo structure
- Open the global settings file
- Run Build - no changes
- Update location - Australia East
- Delete from the portal
- Add files from SRC folder
- Export existing policies

connect-azaccount -TenantId "a2ebc691-c318-4ec2-998a-a87c528378e0"

Build-DeploymentPlans  -PacEnvironmentSelector "mg-epac"

Deploy-PolicyPlan -PacEnvironmentSelector "mg-epac"

Deploy-RolesPlan -PacEnvironmentSelector "mg-epac"

export-AzPolicyResources -ExemptionFiles json
