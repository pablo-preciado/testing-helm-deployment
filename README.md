# Managing applications in Virtual Machines with Red Hat Developer Hub and Ansible Automation Platform

## Resources needed to run this demo

You need an OpenShift cluster with OpenShift Virtualization capabilities. If you're a Red Hatter or a Red Hat partner, you can request an OpenShift cluster running in GCP for this demo. You can request it [here](https://catalog.demo.redhat.com/catalog?item=babylon-catalog-prod/gcp-gpte.ocp4-on-gcp.prod&utm_source=webapp&utm_medium=share-link).

If you're requesting an OpenShift cluster in GCP, you must add a new worker. Otherwise, there won't be enough resources to run your virtual machines. To add a new node, create a new MachineSet. You can find the template in this repository, specifically in `extra-node/machine-set-extra-node.yaml` (make sure you substitute the values according to the comments on that file). 

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
          value: <here-goes-your-openshift-cluster-domain>
        - name: github.pat
          value: <here-goes-your-github-pat>
        - name: rhn.username
          value: <here-goes-your-redhat-customer-portal-username>
        - name: rhn.password
          value: <here-goes-your-redhat-customer-portal-password>
        - name: rhn.poolId
          value: <here-goes-your-ansible-subscription-poolId>
        - name: automationhub.apiToken
          value: <here-goes-your-redhat-automationhub-apiToken>
        - name: rhn.clientId
          value: <here-goes-your-redhat-customer-portal-clientId>
        - name: rhn.clientSecret
          value: <here-goes-your-redhat-customer-portal-clientSecret>
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

You can run this demo and only look at everything from Red Hat Developer Hub point of view, but we're going to take a look at all the pieces involved in it, therefore the first step would be to open the following tabs in your browser:
 - Red Hat Developer Hub: get the url from `oc get route backstage-developer-hub -n rhdh-operator -o jsonpath='{.spec.host}'`.
 - Ansible Automation Platform: get the url from `oc get route my-aap -n aap` and login with the `admin` user and obtain the password running `oc get secret my-aap-admin-password -n aap -o jsonpath='{.data.password}' | base64 -d`
 - OpenShift GitOps (ArgoCD): obtain the password by running `oc get secret openshift-gitops-cluster -n openshift-gitops -o jsonpath='{.data.admin\.password}' | base64 -d`, use the `admin` user and get the url from `oc get route openshift-gitops-server -n openshift-gitops`
 - GitLab: get the url from `oc get routes -n GitLab-system | grep "GitLab-webservice-default"`, the user has been harcoded with a username `user1` and a password of `redhat1!`

Once you have all those tabs opened you can start the demo workflow. First log into Red Hat Developer Hub.

![Image1](images/image1.png)

Once you click on login it'll redirect you to Red Hat Build of Keycloak to provide user and password, in our case we are going to click on "GitLab" as it's the identity provider used during this demo:

![Image2](images/image2.png)

Log in via GitLab using `user1` and `redhat1!` users:

![Image3](images/image3.png)

Authorize keycloak to log in GitLab.

![Image4](images/image4.png)

You've logged in Red Hat Developer Hub.

![Image5](images/image5.png)

You can do a walkthrough of Red Hat Developer Hub if you wish, in this description we're going to go straigh to the point. Go to Catalog and see how there is only one template available. This template will create a Virtual Machine, install JBoss on it and deploy a Hello world application on top.

![Image6](images/image6.png)

Choose the template and fill the data being asked through the wizard. First give the application a name and let the rest as it is.

![Image7](images/image7.png)

Choose the size of the Virtual Machine, we recommend Medium to deliver a good enough performance.

![Image8](images/image8.png)

Paste your GitLab instance URL without `https://` so that Red Hat Developer Hub can create the appropriate repositories and access the scaffolding repository.

![Image9](images/image9.png)

Review your inputs, if everything looks good go ahead and click on "Create".

![Image10](images/image10.png)

Red Hat Developer Hub will create all the resources.

![Image11](images/image11.png)

Wait until all steps are shown as completed.

![Image12](images/image12.png)

Now navigate to Catalog and click on the application you just created:

![Image13](images/image13.png)

It's available for your to click on it and navigate through its options

![Image23](images/image21.png)

This application we just created has call Ansible Automation Platform so it executes a job that spawns a Virtual Machine, configures it, installs JBoss 8 and deploys a hello world application on it. We do this via a Custom Resource called AnsibleJob that the Ansible Automation Platform Operator made available for us to use it. Navigate to your OpenShift ArgoCD GUI to see the argo applications that were created by Red Hat Developer Hub.

![Image14](images/image14.png)

Look for one whose name ends in 'dev-build', click on it and see how it has deployed a resource of type AnsibleJob.

![Image15](images/image15.png)

If you navigate to you Ansible Automation Platform you'll see there is a new job being executed. That is the job that the object AnsibleJob started.

![Image16](images/image16.png)

As you can see, we have done a call to Ansible Automation Platform via Red Hat Developer Hub. For this we leverage the AnsibleJob object and ArgoCD capabilities. In our case Ansible Automation Platform is running on OpenShift but it could be a completely independent instance.

In Ansible Automation Platform GUI, click on the Workflow being run.

![Image17](images/image17.png)

As you can see our workflow has different steps. Once the first one appears as completed (with a green checkmark) you can take a look at the Virtual Machine that was created in you OpenShift cluster.

![Image18](images/image18.png)

You can also see the virtual machine in Topology view of Red Hat Developer Hub.

![Image19](images/image19.png)

And in kubernetes tab of Red Hat Developer Hub.

![Image20](images/image20.png)

As you can see, your virtual machine has been created by Ansible Automation Platform. As it's running in OpenShift Virtualization you could have just created with ArgoCD, instead we decided to create it via Ansible because that is the most similar scenario to customers using other virtualization platforms such as VMware, KVM, Nutanix, AWS, Azure, etc.

Once the virtual machine has been created it will take a while until Ansible finishes its job, which is installing JBoss 8 on the virtual machine and then building and deploying our newly created application. While this process is finishing we recommend to take a look at the repositories that Red Hat Developer Hub created for us. For this, in Red Hat Developer Hub, go to the catalog entry of your application and click on "View Source" in the "About" section.

![Image21](images/image21.png)

That will redirect you to the GitLab repo that was created for your application. You can navigate through it and see that it was create based on an skeleton in our scaffholding GitLab repo.
You can also navigate to the "development" organization of the GitLab instance. In there you'll find the base repo for our application that Red Hat Developer Hub created for us from a skeleton we provided to the template.

![Image22](images/image22.png)

You can also see the list of repos in the "development" organization. In there you'll find another repo with your application name followed by "-gitops", that is the repo Red Hat Developer Hub has created to manage the ArgoCD source.

![Image23](images/image23.png)

Lastly, wait until Ansible Automation Platform has finished running the whole workflow.

![Image24](images/image24.png)

 You can now navigate to the route exposing the virtual machine with our application. For this, go to your application in Red Hat Developer Hub catalog, go to topology view and click on the virtual machine. It'll show a blade menu on the righ side with two tabs, choose the resources tab and scroll down until you see routes.

![Image25](images/image25.png)

Click on route associated to your virtual machine, remember you need to allow insecure (http) traffic in your browser. The route will show you the JBoss 8 web interface.

![Image26](images/image26.png)

If you add the path `/helloworld` to your route you'll see our web application

![Image27](images/image27.png)

With this you've finished the demo and you've demonstrated how Red Hat Developer Hub can be used to manage legacy applications running in virtual machines as well as modern cloud native ones. In this demo we use OpenShift Virtualization but, thanks to Ansible Automation Platform, you could easily reproduce this behaviour with virtual machines in any legacy virtualization platform (like VMware or Hyper-V) or public cloud provider (AWS, Azure, GCP, etc).