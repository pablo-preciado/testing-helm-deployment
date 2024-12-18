# Helm chart for deploying demo environment

To deploy this demo environment first you need to install the OpenShift Pipelines operator. Then modify the `rhdh2vm-demo-deploy-application.yaml` file so you input the applications domain of your cluster in line 14. It should look like this but with your value:

```
        - name: cluster.domain
          value: apps.cluster-dqxwv.dqxwv.gcp.redhatworkshops.io
```

You can add the Application using OpenShift GUI, ArgoCD GUI or with `oc` command line with the command `oc apply -f rhdh2vm-demo-deploy-application.yaml`. After sometime almost all resources will be ready except for the developer hub instance. For deploying RHDH you'll need to modify the `secrets-rhdh` in the `rhdh-operator` namespace with the command `oc edit secret/secrets-rhdh -n rhdh-operator`, add the Github variables and now you can deploy the RHDH instance (there is a definition template in /to-be-added/sw6/backstage.yaml).