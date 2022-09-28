# About
Here I am deploying the provided application in Azure Cloud environment. I have containerized the application, _Dockerfile_ can be found in the repository. Designed the _CI/CD_ pipeline using **Azure DevOps** and deploying on to **Azure Kubernetes Cluster**. Using **Azure Container Registry** for storing the build images.

## Branching Strategy
As per the instruction I have considered three environments [ `dev/stage/production` ]. Hence followed below strategy
1. Any branch starts with `stage` referes to **stage** env. Example `stage/1.2`
2. Any branch starts with `release` referes to **production** env. Example `release/1.2`
3. Any branch starts with other than `stage/release` referes to **dev** env.

### Triggers
Following the above branching strategy triggers are configured as such that any changes to `stage/release` would trigger the pipeline automatically and any changes to other branches which refers to **dev** environment would require a manual trigger.

### Deployment Strategy
Considering the environments I have considered below facts
1. `dev/stage` environments would use **_Responses-other.json_** and `production` environment would use **_Responses.json_** as `DATA_FILE`.
2. Deploying the application in seperate `namespace` in the **k8-cluster** for specific environment.
3. Having the application deployed on **_distroless_** containers for **production** environment for added security.
4. Images are versioned with `builed number` in ACR.

# How to access the deployed application
1. Follow the **Instructions** section to deploy the application
2. Once pipeline is successfully completed go the **k8-cluster**.
3. List namespaces. Namespaces are created as $PROJECT_NAME-$ENV. In my case `accenture-dev/accenture-stage/accenture-release`
```
kubectl get namespace
```
![image](https://user-images.githubusercontent.com/34933018/184546905-411b1bdc-e2ff-4b20-8ae8-17da227969ae.png)

4. List all resources in the specific namespace
```
kubectl get all -n accenture-dev
```
![image](https://user-images.githubusercontent.com/34933018/184546923-e903d8cc-c94e-4a3f-bd14-286c66a604c2.png)

5. Verify all the resources are running. Then take a note of the **EXTERNAL-IP** coloumn of `service/accenture-sg-svc`.
6. Go to `http://<EXTERNAL-IP>:8081` in the browser and output should be as below.

![image](https://user-images.githubusercontent.com/34933018/184547399-5feceb0e-9969-4cc4-b5ad-b08885c7f166.png)


# Instructions
Here I have used Azure Cloud for the resources and Azure DevOps as CI/CD pipeline

## Resources Used
1. Azure Kubernetes Service (AKS)
2. Azure Container Regeistry (ACR)
3. Azure Repos

## Steps
Assuming an *Azure Organization* is created/existed and working in that organization.

### 1. Import To Azure Repos
1. Go to *Repos>Files*
2. Click on *repo dropdown*
![image](https://user-images.githubusercontent.com/34933018/184543154-208cb545-22d2-47ef-bd8f-fae2d5cc54cc.png)
3. Click on *Import Repository* and you should find the following panel
![image](https://user-images.githubusercontent.com/34933018/184543220-3fdc8fdf-cc9b-41d2-b420-048c9a091a77.png)
4. Provide *Clone URL*
5. Click *Import*

### 2. Create Service Connections
Assuming *AKS* and *ACR* resources are present.
#### a. ACR Service Connection
1. Go to *Porject Settings>Service connections>New service connections*
2. Search & select *Docker Registry* click **Next**

![image](https://user-images.githubusercontent.com/34933018/184544978-866170f5-6b3b-42e5-9140-06d75456724b.png)

3. Select *Others* in **Registry Type**
4. Fillup the bellow details
```
  Docker Registry: <Repo URI>
  Docker ID: <Access Token name> that has been generated in ACR Tokens section
  Docker Password: <Access Token>
  -----------
  # Example
  Docker Registry: https://utshab500acr.azurecr.io
  Docker ID: utshab-pat
  Docker Password: <generated token> # generated with admin permission which includes (push and pull)
```
5. Put *Service connection name*. Recomended **containerRegistry** as used in this repo
6. Check **Grant access permission to all pipelines** and click **Save**

![image](https://user-images.githubusercontent.com/34933018/184544156-c61caaa7-0bfd-4100-9337-ecf21d3d333c.png)

#### b. K8 Service Connection
1. Go to *Porject Settings>Service connections>New service connections*
2. Search & select *Kuernetes* click **Next**
3. Select *KubeConfig* in **Authentication method**
4. Copy paste clusters **KUBECONFIG** file content in *KubeConfig* section
5. Put *Service connection name*. Recomended **k8-serviceconnection** as used in this repo
6. Check **Grant access permission to all pipelines** and click **Save**

![image](https://user-images.githubusercontent.com/34933018/184544156-c61caaa7-0bfd-4100-9337-ecf21d3d333c.png)


### 3. Add Variable Gorup
1. Go to *Pipelines>Library*
2. Click *Variable group*

![image](https://user-images.githubusercontent.com/34933018/184543381-adb74210-2725-4cbd-90b8-739b74b7636e.png)

3. Place following details

**Variable Group Name:** *cicd-deploy*
|Variable|Value|
|-|-|
|CR_REPO| `container registry repo URI` [ Example: utshab500acr.azurecr.io ]|
|PROJECT_NAME|`any` [ Given `string` will be used to create `namespace` in *k8-cluster* ]|

### 4. Create Alert
Here I configure alert for the build pipeline so that an alert is generated when pipeline fails.
1. Go to *Porject Settings>Notifications*
2. Click *New subscription*

![image](https://user-images.githubusercontent.com/34933018/184545180-a850cee7-359d-4037-b753-55f90aeba44c.png)

3. Select *Build* in **Category** and *A build fails* in **Template** and click **Next**

![image](https://user-images.githubusercontent.com/34933018/184545322-276dfa48-40a3-4d76-b32e-26d017214303.png)

4. In the following panel we can configure the alert as per our requirement.

![image](https://user-images.githubusercontent.com/34933018/184545384-3b01fe01-78b9-4477-8600-ff1f75d26e05.png)

5. In *Filter criteria* choose *Value* to be **Failed** in order to generate alert on build fail

![image](https://user-images.githubusercontent.com/34933018/184545436-e2ae6d52-4d4e-4654-802c-fe198204182b.png)

### 5. Create Pipeline
1. Go to *Pipelines>New pipeline*.
2. Choose *Azure Repos Git* as I have already imported from my personal GitHub to specific Azure Subscription.
3. Select the **imported repo**. In my case `cicd-deploy-accenture-sg-poc.git`.
4. Click **Run**.
5. Pipeline should start to run and looks as below.

![image](https://user-images.githubusercontent.com/34933018/184545724-0e0dfb7b-3811-4ba7-b8aa-7026182f2084.png)


