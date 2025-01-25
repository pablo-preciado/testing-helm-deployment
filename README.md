# Managing applications in Virtual Machines with Red Hat Developer Hub and Ansible Automation Platform

## Resources needed to run this demo

You need an OpenShift cluster with OpenShift Virtualization capabilities. If you're a Red Hatter or a Red Hat partner, you can request an OpenShift cluster running in GCP for this demo. You can request it [here](https://catalog.demo.redhat.com/catalog?item=babylon-catalog-prod/gcp-gpte.ocp4-on-gcp.prod&utm_source=webapp&utm_medium=share-link).

If you're requesting the OpenShift cluster running in GCP, be aware that you'll need to add a new worker; otherwise, there will be no resources available for running your virtual machines. To add a new node, create a new MachineSet. You can find the template in this repository, specifically in `extra-node/machine-set-extra-node.yaml` (make sure you substitute the values according to the comments on that file). 

## Deploying demo environment

This demo uses all the software officially provided by Red Hat. Therefore, you need to provide certain usernames, passwords, and tokens so the different software can access the Red Hat CDN and use official packages. You'll also need to obtain a GitHub Personal Access Token (PAT). 

This is the list of information you need to obtain:

- Red Hat Customer Portal username and password: These are used to connect a RHEL system to Red Hat repositories using subscription-manager.

- Pool ID for an Ansible Automation Platform subscription: You can find this in the [Red Hat Customer Portal](https://access.redhat.com/) by navigating to Subscriptions (top left) > Subscriptions tab > Search "Ansible Automation Platform" > Click on your subscription and locate the Pool ID. Ensure it's a valid Ansible Automation Platform subscription.

- Token for Red Hat Automation Hub. Ansible will need this token to download and use official Red Hat collections. To obtain this token, navigate to the [Red Hat Hybrid Cloud Console](https://console.redhat.com) and go to Services (on the top left) > Automation > Automation Hub. Once there, click on "Connect to Hub" on the left side navigation panel. There, you'll be able to generate a token.

- Client ID and Client Secret for a Red Hat Customer Portal Service Account are used during the JBoss installation process. To obtain these values, you can easily create a Service Account. Go to the [Red Hat Hybrid Cloud Console](https://console.redhat.com) and click on the gear icon (top right). In the drop-down menu, click on "Service Accounts." Once there, create a service account and note down the Client ID and Client Secret.

- GitHub PAT (classic): Log in to GitHub and navigate to the [tokens settings site](https://github.com/settings/tokens) to create a classic token. This is needed to import the Git repo into the GitLab that we deploy locally for the demo. Even if the repo is public, you need a PAT to interact with the GitHub API.

- Cluster domain. You need to pass the application domain of your cluster to the Helm chart to properly deploy the demo. It should be something like `apps.cluster-dqxwv.dqxwv.gcp.redhatworkshops.io`. 

Once you have retrieved all the usernames, passwords, and tokens, go to your OpenShift cluster and install the OpenShift GitOps operator. Once installed, create an Application object with all the information you just collected under the helm parameters section. 

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
You can also find this application template under the directory `/argo-application` of this repository.

Add the application using OpenShift GUI, ArgoCD GUI, or with the `oc` command line using the command `oc apply -f rhdh2vm-demo-deploy-application.yaml`. After a few minutes, all resources will be ready.

## Demo walkthrough

Use this section to explain what's the flow of the demo, what should be shown and how.