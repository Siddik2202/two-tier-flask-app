 
# Flask App with MySQL Docker Setup

This is a simple Flask app that interacts with a MySQL database. The app allows users to submit messages, which are then stored in the database and displayed on the frontend.

1. Launch a EC2 Instances by selecting type, security, storage And create.
   
2. Now access the instance and clonse your project from github.
   ```bash
   git clone https://github.com/Siddik2202/two-tier-flask-app.git
   ```
3. Now build your dockerfile and build and run this application.
   ```bash
   docker build -t flaskapp .
   ```
4. Now, make sure that you have created a network using following command
```bash
docker network create twotier
```

5. Attach both the containers in the same network, so that they can communicate with each other

i) MySQL container 
```bash
docker run -d \
    --name mysql \
    -v mysql-data:/var/lib/mysql \
    --network=twotier \
    -e MYSQL_DATABASE=mydb \
    -e MYSQL_ROOT_PASSWORD=admin \
    -p 3306:3306 \
    mysql:5.7

```
ii) Backend container
```bash
docker run -d \
    --name flaskapp \
    --network=twotier \
    -e MYSQL_HOST=mysql \
    -e MYSQL_USER=root \
    -e MYSQL_PASSWORD=admin \
    -e MYSQL_DB=mydb \
    -p 5000:5000 \
    flaskapp:latest

```
6. Open the `.env` file and add your MySQL configuration:

   ```
   MYSQL_HOST=mysql
   MYSQL_USER=your_username
   MYSQL_PASSWORD=your_password
   MYSQL_DB=your_database
   ```

7.  Create the `messages` table in your MySQL database:

   - Use a MySQL client or tool (e.g., phpMyAdmin) to execute the following SQL commands:
     ```bahs
     docker exec -it <mysql container id> bash 
     mysql -u root -p
     # Enter Password and chnaged to database and create table.
     ```
   
     ```sql
     CREATE TABLE messages (
         id INT AUTO_INCREMENT PRIMARY KEY,
         message TEXT
     );
     ```
### Using Docker Compose
1. Start the containers using Docker Compose, Befor that you need to logIn, add tag on image and push to DockerHub.

   ```bash
   docker-compose up --build
   ```

2. Access the Flask app in your web browser:

   - Frontend: http://localhost
   - Backend: http://localhost:5000

 
   - Visit http://localhost to see the frontend. You can submit new messages using the form.
   - Visit http://localhost:5000/insert_sql to insert a message directly into the `messages` table via an SQL query.

### Using kubeadm we add some advanced features.

1. First setup kubernetes kubeadm cluster

2. Move to k8s directory cd two-tier-flask-app/k8s

3. Now, execute below commands one by one
```bash
kubectl apply -f twotier-deployment.yml
kubectl apply -f twotier-deployment-svc.yml
kubectl apply -f mysql-deployment.yml
kubectl apply -f mysql-deployment-svc.yml
kubectl apply -f persistent-volume.yml
kubectl apply -f persistent-volume-claim.yml
```

### Using EKS we deploy this two-tire-flask app

1. Create EC2 instance- Connect instance. and install AWS CLI. 

2. Create a user and administratorAccess with attach policy. Also create a access key by enabling checkbox with command line interface. 
	2.1 AmazonEKSClusterPolicy , AmazonEKSWorkerNodePolicy, AmazonEC2FullAccess, IAMFullAccess (For not administrative)

3. Now configure aws and Install kubectl, eksctl. 

4. Now create Cluster->  
   ```bash
   eksctl create cluster  --name tws-cluster --region ap-sount-1 --node-type t3.small --node-min 2 --node-max-4
   ```
5. To set password on secret base-64 use echo -n "admin" | base64 (For secret manifest file)

6. Now clonse this project. And go to k8s or eks-manifests file.

6. Run using kubectl apply -f file1.yaml -f file2.yaml ... (all mysql and then project-files )

7. By running below commadn you can access using url
   ```bahs
   kubectl get all & kubectl get node
   ```

   Thank you so much

## Now We Deploy through EKS using Terraform

1. Ininitialize your terraform using, after creating try to run plan command and when complete then run apply command
```bash
terraform init
terraform plan
terraform apply # To create
terraform destroy # To delete all resources
```
2. Create you module separetly eks and vpc.

3.  After creating all resources completely run 
```bash
aws eks update-kubeconfig --region ap-south-1 --name my-eks-cluster
kubectl get nodes
```
    
4. Kubernetes does NOT have permission to talk to AWS directly ❌. OIDC Provider (IRSA Setup): You are telling AWS: “Trust this Kubernetes cluster identity”
```bash
# We already give access through code so no need but this crucial when you create fresh project.
eksctl utils associate-iam-oidc-provider \
  --region ap-south-1 \
  --cluster my-eks-cluster \
  --approve
```
5. It contains permissions (IAM policy) required by: 👉 AWS Load Balancer Controller.
```bash
curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json
```
6. You define what actions are allowed. like Create Load Balancer / Modify security group.
```bash
aws iam create-policy \
  --policy-name AWSLoadBalancerControllerIAMPolicy \
  --policy-document file://iam_policy.json
```
7. This specific Kubernetes component can use this IAM role”
```bash
eksctl create iamserviceaccount \
  --cluster=my-eks-cluster \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --role-name AmazonEKSLoadBalancerControllerRole \
  --attach-policy-arn=arn:aws:iam::<AWS-ACCOUNT-ID>:policy/AWSLoadBalancerControllerIAMPolicy \
  --approve
```
8. To add Helm Repo run below command
```bash
helm repo add eks https://aws.github.io/eks-charts
helm repo update
```
9. This installs a software inside your Kubernetes cluster: 👉 AWS Load Balancer Controlle.
```bash
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=my-eks-cluster \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller
```
10. # Verify Installation
```bash
kubectl get pods -n kube-system
kubectl get deployment -n kube-system aws-load-balancer-controller
```
11. After that clone you project from git, In my case I already create eks-manifest files so no need to create yaml file again.
```bash
git clone https://github.com/Siddik2202/two-tier-flask-app.git
```
12. Now go to eks-manifests path and run yaml file then run one by one
```bash
 kubectl apply -f mysql-configmap.yml
 kubectl apply -f mysql-secrets.yml
 kubectl apply -f mysql-deployment.yml
 kubectl apply -f mysql-svc.yml
 kubectl apply -f two-tier-app-deployment.yml
 kubectl apply -f two-tier-app-svc.yml
```

14. To show resources we need to create and associat Adminpolicy
```bash
aws eks associate-access-policy \
  --cluster-name my-eks-cluster \
  --principal-arn arn:aws:iam::<USER_ACCOUNT_ID>:user/terraform-admin \
  --policy-arn arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy \
  --access-scope type=cluster
```

 # 1. Create entry for the Root user
 ```bash
aws eks create-access-entry --cluster-name my-eks-cluster --principal-arn arn:aws:iam::339713170737:root --type STANDARD
```
# 2. Give the Root user admin permissions
```bash
aws eks associate-access-policy --cluster-name my-eks-cluster --principal-arn arn:aws:iam::339713170737:root --policy-arn arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy --access-scope type=cluster
```















   
