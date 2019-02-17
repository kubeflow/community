-- Based on
-- https://github.com/cncf/devstats/blob/ce383e8fd9bf05fbd3b08968e6704a2e6ccbdedf/scripts/all/repo_groups.sql
--
--# This script is used by devstats to group repositories.
--# It updates the table gha_repos 

-- Clear current repo groups (taken from merge of all other projects)
update
  gha_repos
set
  repo_group = null,
  alias = null
;

-- Kubernetes
update
  gha_repos
set
  repo_group = 'kubeflow',
  alias = 'kubeflow'
where  
  not name in ('kubeflow/homebrew-cask', 
  			   'kubeflow/homebrew-core')
;
