# SIG On Premises Charter

This charter adheres to the conventions, roles, and organization management outlined in [wg-governance].

## Scope

SIG On Premises 

### In scope

#### Product Functionality

This SIG aims to develop best practices for Kubeflow deployments in on-prem environments.

- Ensure that users have access to a list of validated reference designs for setting up a Kubeflow cluster.
- Ensure that a process is defined that will enable users to contribute to reference designs.
- Ensure that there is always at least one working and validated complete software stack. This software stack would be defined as a list of OSes and component versions that have been verified to create a working solution.


#### Cross-cutting and Externally Facing Processes

- Maintain testing infrastructure to provide a well-tested architecture for Kubeflow on-prem deployment.
- Coordinating with other Kubeflow WG to ensure they are aware of issues in on-prem deployments where appropriate.
- Coordinating with release teams to ensure they are aware of issues in on-prem deployments.
- Maintaining a list of hardware stacks known to work with Kubeflow.
- Maintaining instructions on how to verify a working stack.
- Maintaining a template for how to run benchmarks to verify a performant stack.
- Maintain a known-issues list
- Coordination with application working groups to ensure project artifacts are tested across onprem technologies such as:
  - Different CPU architectures and different accelerator architectures. 
  - Take into account different use cases, edge, and other "non-traditional" onprem technologies that are being developed in the field.

### Out of scope

- Providing fixes for every issue found for on-prem deployments.
- Providing root-cause analysis for every issue found.
- Maintaining manifests for Kubeflow on-prem deployments, our scope is to test the output of the WG Manifests working group on our onprem test infrastructure and then report back to other working groups. 
  - SIG On-prem does not directly maintain these manifests, we coordinate with the other working groups to help prioritize work.

## Roles and Organization Management

This SIG follows adheres to the Roles and Organization Management outlined in [wg-governance]
and opts-in to updates and modifications to [wg-governance].

### Subproject Creation

SIG Co-Chairs

- Jeff Fogarty - Co-chair - US Bank - jeff.fogarty@usbank.com - TZ: US CST
- Michael Tanenbaum - Co-chair - Arrikto -michael.tanenbaum@arrikto.com / michael.a.tanenbaum@gmail.com - Timezone: US EST
- Rui Vasconcelos - Co-chair - Canonical - rui.vasconcelos@canonical.com - TZ: EU West

SIG Technical Leads

- Jeff Fogarty - Co-tech-lead - US Bank - jeff.fogarty@usbank.com
- Igor Mameshin - Co-tech-lead - AgileStacks - igor@agilestacks.com - Timezone: US PST
- Marlow Weston - Co-tech-lead - Intel - catblade@gmail.com - Timezone: US CST

[wg-governance]: ../wgs/wg-governance.md