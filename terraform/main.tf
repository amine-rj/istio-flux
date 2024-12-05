terraform {
required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}
  provider "kubernetes" {
    config_path = "~/.kube/config"
    config_context = "minikube"
}

resource "null_resource" "install_helm" {
  provisioner "local-exec" {
    command = <<EOF
      #!/bin/bash
      if ! which helm > /dev/null; then
        curl -fsSL -o get_helm.sh \
          https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
        chmod 700 get_helm.sh
        ./get_helm.sh --version v3.8.2
      fi

      if ! which flux > /dev/null; then
        brew install fluxcd/tap/flux
      fi
    EOF
  }
}

resource "null_resource" "install_flux" {
  provisioner "local-exec" {
    command = <<EOF
      helm repo add fluxcd https://charts.fluxcd.io
      helm repo update

      helm upgrade --install flux fluxcd/flux \
        --set git.url=git@github.com:amine-rj/sandbox-flux-infra.git \
        --namespace flux-system --create-namespace
    EOF
  }

  depends_on = [null_resource.install_helm]
}
