output "kubeconfig" {
  value = ""
}

// This output should be backed with a null_resource in custom modules. The null resource should depend on
// all the resources in its module and its id should be used as the value of this output.
//
// See the EKS module (custom/provider/eks) as a reference implementation.
//
// The purpose of this is to declare dependencies that work as expected when destroying the infrastructure.
//
// The expectation comes from the way deployment is done. Deploy is a two phase process:
//  - first the custom provider is brought up using a "targeted" (-target module.custom) terraform apply
//  - next a full terraform apply brings up the whole stack, this time with module.custom resources already in place
//
// The reverse of this process is to bring down everything except the custom module, but unfortunately
// there is no way to do that. What we can do is to declare an explicit dependency on the module from the resources
// that should be destroyed before the custom module goes down, but currently terraform does not provide a direct
// mechanism for that.
//
// We expect this to be fixed in a future terreform version, until then please read for reference:
//  - https://github.com/hashicorp/terraform/issues/17101
//  - https://github.com/guitarmanvt/terraform-dependencies-explained#5-faking-module-dependencies-part-2-using-a-module_complete-output
output "ready" {
  value = ""
}