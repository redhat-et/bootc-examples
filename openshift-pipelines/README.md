# Installing sigstore pipeline on OCP

## Install Vault + transit KMS for sigstore

```sh
helm repo add hashicorp https://helm.releases.hashicorp.com
oc new-project vault
oc adm policy add-role-to-user admin -z vault -n vault
export cluster_base_domain=$(oc get dns cluster -o jsonpath='{.spec.baseDomain}')
helm upgrade vault hashicorp/vault -i --create-namespace -n vault --atomic -f ./vault/vault-values.yaml --set server.route.host=vault-vault.apps.${cluster_base_domain}

#configure kube auth
export VAULT_ADDR=https://vault-vault.apps.${cluster_base_domain}
export VAULT_TOKEN=$(oc get secret vault-init -n vault -o jsonpath='{.data.root_token}' | base64 -d )
# this policy is intentionally broad to allow to test anything in Vault. In a real life scenario this policy would be scoped down.
vault policy write vault-admin  ./vault/vault-admin-policy.hcl
vault auth enable kubernetes
vault write auth/kubernetes/config kubernetes_host=https://kubernetes.default.svc:443
vault write auth/kubernetes/role/ci-system bound_service_account_names=pipeline bound_service_account_namespaces='*' policies=vault-admin ttl=10s

#configure transit
vault secrets enable transit
cosign generate-key-pair --kms hashivault://ci-system
```

## Install tekton and tekton chain configured to use cosign + OCI store for attestations

```sh
oc apply -f ./openshift-pipelines/operator.yaml
```

## Configure openshift pipelines

```sh
oc apply -f ./openshift-pipelines/tektonchain.yaml
oc patch configmap chains-config -n openshift-pipelines -p='{"data":{"artifacts.oci.storage": "oci"}}' 
oc patch configmap chains-config -n openshift-pipelines -p='{"data":{"artifacts.taskrun.format": "in-toto"}}'
oc patch configmap chains-config -n openshift-pipelines -p='{"data":{"artifacts.taskrun.storage": "oci"}}'
oc patch configmap chains-config -n openshift-pipelines -p='{"data":{"transparency.enabled": "false"}}'
oc patch configmap chains-config -n openshift-pipelines -p='{"data":{"artifacts.pipelinerun.format": "in-toto"}}'
oc patch configmap chains-config -n openshift-pipelines -p='{"data":{"artifacts.pipelinerun.storage": "oci"}}'
cosign generate-key-pair k8s://openshift-pipelines/signing-secrets
```

## Create a simple pipeline to test

create the pipeline

```sh
oc new-project test-sigstore
oc create secret docker-registry quay-push --docker-username=raffaelespazzoli --docker-password=<password> --docker-server=quay.io -n test-sigstore
oc patch serviceaccount pipeline -p "{\"imagePullSecrets\": [{\"name\": \"quay-push\"}]}" -n test-sigstore
oc patch secret quay-push -n test-sigstore -p "{\"data\": {\"config.json\": \"$(oc get secret quay-push -n test-sigstore -o jsonpath={.data."\.dockerconfigjson"})\"}}"
oc apply -f ./openshift-pipelines/syft-task.yaml 
oc apply -f ./openshift-pipelines/grype-task.yaml 
oc apply -f ./openshift-pipelines/pipeline-pvc.yaml -n test-sigstore
oc apply -f ./openshift-pipelines/pipeline-ci.yaml -n test-sigstore
```

run the pipeline

```sh
oc create -f ./openshift-pipelines/pipeline-ci-run.yaml -n test-sigstore
```