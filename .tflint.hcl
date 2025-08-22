plugin "aws" {
  enabled = true
  version = "0.27.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

config {
  module = true
  force  = false
}

rule "terraform_deprecated_index" {
  enabled = true
}

rule "terraform_deprecated_interpolation" {
  enabled = true
}

rule "terraform_unused_declarations" {
  enabled = true
}

rule "terraform_comment_syntax" {
  enabled = true
}

rule "terraform_documented_outputs" {
  enabled = true
}

rule "terraform_documented_variables" {
  enabled = true
}

rule "terraform_typed_variables" {
  enabled = true
}

rule "terraform_module_pinned_source" {
  enabled = true
}

rule "terraform_naming_convention" {
  enabled = true
  format  = "snake_case"
}

rule "terraform_required_version" {
  enabled = true
}

rule "terraform_required_providers" {
  enabled = true
}

rule "terraform_standard_module_structure" {
  enabled = true
}

rule "terraform_workspace_remote" {
  enabled = true
}

rule "terraform_unused_required_providers" {
  enabled = true
}

rule "terraform_consistent_variable_names" {
  enabled = true
  format  = "snake_case"
}

rule "terraform_consistent_output_names" {
  enabled = true
  format  = "snake_case"
}

rule "terraform_consistent_resource_names" {
  enabled = true
  format  = "snake_case"
}

rule "terraform_consistent_data_source_names" {
  enabled = true
  format  = "snake_case"
}

rule "terraform_consistent_local_names" {
  enabled = true
  format  = "snake_case"
}

rule "terraform_consistent_module_names" {
  enabled = true
  format  = "snake_case"
}

rule "terraform_consistent_variable_types" {
  enabled = true
}

rule "terraform_consistent_output_types" {
  enabled = true
}

rule "terraform_consistent_resource_types" {
  enabled = true
}

rule "terraform_consistent_data_source_types" {
  enabled = true
}

rule "terraform_consistent_local_types" {
  enabled = true
}

rule "terraform_consistent_module_types" {
  enabled = true
}

rule "terraform_consistent_variable_descriptions" {
  enabled = true
}

rule "terraform_consistent_output_descriptions" {
  enabled = true
}

rule "terraform_consistent_resource_descriptions" {
  enabled = true
}

rule "terraform_consistent_data_source_descriptions" {
  enabled = true
}

rule "terraform_consistent_local_descriptions" {
  enabled = true
}

rule "terraform_consistent_module_descriptions" {
  enabled = true
}
