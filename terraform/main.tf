provider "kind" {}

resource "kind_cluster" "kind" {
    name = "flux-cd"
    node_image = "kindest/node:v1.26.6"
    kind_config  {
        kind = "Cluster"
        api_version = "kind.x-k8s.io/v1alpha4"
        node {
            role = "control-plane"
        }
        node {
            role =  "worker"
        }
        node {
            role =  "worker"
        }
    }
}

provider "helm" {
  kubernetes {
    host                   = kind_cluster.kind.endpoint
    client_certificate     = kind_cluster.kind.client_certificate
    client_key             = kind_cluster.kind.client_key
    cluster_ca_certificate = kind_cluster.kind.cluster_ca_certificate
  }
}

resource "helm_release" "flux-cd" {
  repository       = "https://fluxcd-community.github.io/helm-charts"
  chart            = "flux2"
  name             = "flux2"
  namespace        = "flux-system"
  create_namespace = true
  set {
    name = "kustomizeController.create"
    value = "true"
  }
}

resource "helm_release" "flux-sync" {
    repository       = "https://fluxcd-community.github.io/helm-charts"
    chart            = "flux2-sync"
    name             = "flux2-sync"
    namespace        = "bancaempresas"
    create_namespace = true
    set {
        name  = "gitRepository.spec.url"
        value = "ssh://git@github.com:axelluguercio/flux-cd.git"
    }
    set {
        name  = "gitRepository.spec.secretRef.name"
        value = "secret-git-credentials"
    }
}