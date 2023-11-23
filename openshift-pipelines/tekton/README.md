## I ran the following:

```bash
oc apply -f syft-task.yaml 
oc apply -f grype-task.yaml 
oc apply -f pipeline-pvc.yaml -n bootc
oc apply -f pipeline-keyless.yaml -n bootc

oc create -f pipeline-ci-run.yaml -n bootc
```
