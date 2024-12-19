# Helm chart for deploying demo environment

## Resources needed to run this demo

You need an OpenShift cluster with OpenShift Virtualization capabilities. If you're a redhatter or a Red Hat partner you can request an OpenShift cluster running in GCP for the purposes of this demo, you can reuqeest it [here](https://catalog.demo.redhat.com/catalog?item=babylon-catalog-prod/gcp-gpte.ocp4-on-gcp.prod&utm_source=webapp&utm_medium=share-link).

## Deploying demo environment

To deploy this demo environment first you need to install the OpenShift Pipelines operator. Then modify the `rhdh2vm-demo-deploy-application.yaml` file so you input the applications domain of your cluster in line 14. It should look like this but with your value:

```
        - name: cluster.domain
          value: apps.cluster-dqxwv.dqxwv.gcp.redhatworkshops.io
```

If you also want to modify the Github relate variables you can do it by adding all of those in the application definition:

```
        - name: cluster.domain
          value: apps.cluster-dqxwv.dqxwv.gcp.redhatworkshops.io
        - name: github.appId
          value: k4lj34nk32k5423h-h5jh7778f8g87fdj6
        - name: github.clientId
          value: 7231976382246464637383
        - name: github.clientSecret
          value: d88e-895e-ewq9-po0i
        - name: github.privateKey
          value: h4j32lkhc81nd92n19x1nhcwelncloa
        - name: auth.sessionSecret
          value: alcaparra
```

You can add the Application using OpenShift GUI, ArgoCD GUI or with `oc` command line with the command `oc apply -f rhdh2vm-demo-deploy-application.yaml`. After sometime almost all resources will be ready except for the developer hub instance. For deploying RHDH you'll need to modify the `secrets-rhdh` in the `rhdh-operator` namespace with the command `oc edit secret/secrets-rhdh -n rhdh-operator`, add the Github variables and now you can deploy the RHDH instance (there is a definition template in /to-be-added/sw6/backstage.yaml).