// Copyright © 2019 Banzai Cloud
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

data "helm_repository" "banzaicloud-stable" {
  count = var.enabled ? 1 : 0
  name  = "banzaicloud-stable"
  url   = "https://kubernetes-charts.banzaicloud.com/"
}

# Prepare helm values for feature_set
data "template_file" "ui" {
  count    = var.enabled ? 1 : 0
  template = file("${path.module}/values/ui.yaml")
  vars = {
    fqdn = var.fqdn
  }
}

resource "helm_release" "ui" {
  count      = var.enabled ? 1 : 0
  name       = var.release_name
  chart      = "pipeline-ui"
  repository = data.helm_repository.banzaicloud-stable[0].name
  namespace  = var.namespace
  version    = lookup(var.values, "chartVersion", "1.1.3")
  timeout    = lookup(var.values, "timeout", "300")
  wait       = lookup(var.values, "wait", "false")

  values = [
    data.template_file.ui[0].rendered,
    yamlencode(var.values),
  ]
}