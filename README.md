# Helm chart for deploying demo environment

## Resources needed to run this demo

You need an OpenShift cluster with OpenShift Virtualization capabilities. If you're a redhatter or a Red Hat partner you can request an OpenShift cluster running in GCP for the purposes of this demo, you can reuqeest it [here](https://catalog.demo.redhat.com/catalog?item=babylon-catalog-prod/gcp-gpte.ocp4-on-gcp.prod&utm_source=webapp&utm_medium=share-link).

In case you're requesting the OpenShift cluster running in GCP, be aware that you'll need to add a new worker, otherwise there will be no resources available for running your virtual machines.

To add a new node you do it by creating a new MachineSet, you can find the template in this repo. Specifically in `extra-node/machine-set-extra-node.yaml`

## Deploying demo environment

This demo uses all the software officially provided by Red Hat. Therefore, you need to provide certain users, passwords and tokens so the different softwares can reach Red Hat CDN and use official packages. You'll also need to obtain a Github Private Access Token (PAT).

This is the list of information that you need to get:
 - Red Hat Customer Portal username and password. This is simply the username and password you use to connect a RHEL system to Red Hat repos using subscription-manager.
 - Pool id for an Ansible Automation Platform subscription. You can find it in [Red Hat Customer Portal](https://access.redhat.com/), navigating to Subscriptions (top left) > Subscriptions tab > Search "Ansible Automation Platform" > Click on your subscription and find the Pool ID you need. Make sure it's a valid Ansible Automation Platform subscription.
 - Token for Red Hat Automation Hub. Ansible will need this token so it can download and use official Red Hat collections. To obtain this token navigate to [Red Hat Hybrid Cloud Console](https://console.redhat.com) and navigate to Services (on top left) > Automation > Automation Hub. Once there, click on "Connect to Hub" on the lef side navigation panel. There you'll be able to generate a token.
 - Client ID and Client Secret for a Red Hat Customer Portal Service Account. This is used during the jboss installation process, to obtain this values you can easily create a Service Account. Go to [Red Hat Hybrid Cloud Console](https://console.redhat.com) and click on the gear icon (top right), in the drop down menu click on "Service Accounts". Once there create a service account and note down the Client ID and Client Secret.
 - Github PAT (classic). Log in Github and navigate to the [tokens settings site](https://github.com/settings/tokens), create a classic token. This is needed to import the git repo in the Gitlab that we deploy locally for the demo. Even if the repo is public you need a PAT to interact with Github API.
 - Cluster domain. You need to pass the application doman of your cluster to the helm chart to properly deploy the demo. It should be something like `apps.cluster-dqxwv.dqxwv.gcp.redhatworkshops.io`.

Once you have retrieved all the username, passwords and tokens go to your openshift cluster and install OpenShift Gitops operator.
Once installed create an Application object with all the information you just collected under the values section:

```
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: rhdh2vm-demo-deploy
  namespace: openshift-gitops
spec:
  destination:
    server: 'https://kubernetes.default.svc'
  project: default
  source:
    helm:
      parameters:
        - name: cluster.domain
          value: <here-goes-your-cluster-domain>
        - name: github.pat
          value: <here-goes-your-github-pat>
        - name: rhn.username
          value: <here-goes-your-rhn-username>
        - name: rhn.password
          value: <here-goes-your-rhn-password>
        - name: rhn.poolId
          value: <here-goes-your-rhn-poolId>
        - name: rhn.clientId
          value: <here-goes-your-rhn-clientId>
        - name: rhn.clientSecret
          value: <here-goes-your-rhn-clientSecret>
        - name: automationhub.url
          value: <here-goes-your-automationhub-url>
        - name: automationhub.authUrl
          value: <here-goes-your-automationhub-authUrl>
        - name: automationhub.apiToken
          value: <here-goes-your-automationhub-apiToken>
    path: rhdh2vm-demo-deploy
    repoURL: 'https://github.com/pablo-preciado/testing-helm-deployment.git'
    targetRevision: HEAD
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    retry:
      backoff:
        duration: 10s
        factor: 2
        maxDuration: 10m
      limit: 10
    syncOptions:
      - CreateNamespace=true
```
You can also find this applitation template under the directory `/argo-application` of this repo.

Add the Application using OpenShift GUI, ArgoCD GUI or with `oc` command line with the command `oc apply -f rhdh2vm-demo-deploy-application.yaml`. After a few minutes all resources will be ready.