After creating VPC, EKS 
* aws eks update-kubeconfig --region ap-south-1 --name my-eks-cluster
* kubectl get nodes
* aws sts get-caller-identity # To check AWS CLI is still configured

# 👉 Kubernetes does NOT have permission to talk to AWS directly ❌
# We give permission using: 👉 IAM Role + Service Account (IRSA)

# OIDC Provider (IRSA Setup): You are telling AWS: “Trust this Kubernetes cluster identity”
# IAM Open ID Connect provider is associated with cluster

* eksctl utils associate-iam-oidc-provider \
  --region ap-south-1 \
  --cluster my-eks-cluster \
  --approve

# 👉 It contains permissions (IAM policy) required by: 👉 AWS Load Balancer Controller
* curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json



# 👉 You define what actions are allowed. like Create Load Balancer / Modify security group

# “What permissions does this employee have?”
* aws iam create-policy \
  --policy-name AWSLoadBalancerControllerIAMPolicy \
  --policy-document file://iam_policy.json

# This specific Kubernetes component can use this IAM role”
* eksctl create iamserviceaccount \
  --cluster=my-eks-cluster \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --role-name AmazonEKSLoadBalancerControllerRole \
  --attach-policy-arn=arn:aws:iam::339713170737:policy/AWSLoadBalancerControllerIAMPolicy \
  --approve

# 
* helm repo add eks https://aws.github.io/eks-charts
helm repo update

# This installs a software inside your Kubernetes cluster: 👉 AWS Load Balancer Controlle
* helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=my-eks-cluster \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller

# Verify Installation
kubectl get pods -n kube-system
kubectl get deployment -n kube-system aws-load-balancer-controller



# To show resources we need to create and associat Adminpolicy

aws eks associate-access-policy \
  --cluster-name my-eks-cluster \
  --principal-arn arn:aws:iam::<USER_ACCOUNT_ID>:user/terraform-admin \
  --policy-arn arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy \
  --access-scope type=cluster


 # 1. Create entry for the Root user
aws eks create-access-entry --cluster-name my-eks-cluster --principal-arn arn:aws:iam::339713170737:root --type STANDARD

# 2. Give the Root user admin permissions
aws eks associate-access-policy --cluster-name my-eks-cluster --principal-arn arn:aws:iam::339713170737:root --policy-arn arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy --access-scope type=cluster