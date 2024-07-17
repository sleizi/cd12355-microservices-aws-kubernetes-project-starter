Setup
0. Create an EKS Cluster
Install eksctl(opens in a new tab) and use it to create an EKS cluster.

Ensure the AWS CLI is configured correctly.
aws sts get-caller-identity
Create an EKS Cluster
eksctl create cluster --name my-cluster --region us-east-1 --nodegroup-name my-nodes --node-type t3.small --nodes 1 --nodes-min 1 --nodes-max 2
aws eks --region us-east-1 update-kubeconfig --name my-cluster
Update the Kubeconfig
kubectl config current-context
kubectl config view
1. Configure a Database
Set up a Postgres database

Create a file pvc.yaml on your local machine, with the following content.
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: postgresql-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
Create PersistentVolume
apiVersion: v1
kind: PersistentVolume
metadata:
  name: my-manual-pv
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: gp2
  hostPath:
    path: "/mnt/data"
Create PersistentVolume
apiVersion: v1
kind: PersistentVolume
metadata:
  name: my-manual-pv
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: gp2
  hostPath:
    path: "/mnt/data"
run commands
cd ./deployment/database
kubectl apply -f pvc.yaml
kubectl apply -f pv.yaml
kubectl apply -f postgresql-deployment.yaml
Test Database Connection The database is accessible within the cluster. This means that when you will have some issues connecting to it via your local environment. You can either connect to a pod that has access to the cluster or connect remotely via Port Forwarding
Connecting Via Port Forwarding
kubectl port-forward --namespace default svc/<SERVICE_NAME>-postgresql 5432:5432 &
    PGPASSWORD="$POSTGRES_PASSWORD" psql --host 127.0.0.1 -U postgres -d postgres -p 5432
Connecting Via a Pod
kubectl exec -it <POD_NAME> bash
PGPASSWORD="<PASSWORD HERE>" psql postgres://postgres@<SERVICE_NAME>:5432/postgres -c <COMMAND_HERE>
Run Seed Files We will need to run the seed files in db/ in order to create the tables and populate them with data.
kubectl port-forward --namespace default svc/<SERVICE_NAME>-postgresql 5432:5432 &
    PGPASSWORD="$POSTGRES_PASSWORD" psql --host 127.0.0.1 -U postgres -d postgres -p 5432 < <FILE_NAME.sql>
2. Running the Analytics Application Locally
In the analytics/ directory:

Install dependencies
pip install -r requirements.txt
Run the application (see below regarding environment variables)
<ENV_VARS> python app.py
There are multiple ways to set environment variables in a command. They can be set per session by running export KEY=VAL in the command line or they can be prepended into your command.

DB_USERNAME
DB_PASSWORD
DB_HOST (defaults to 127.0.0.1)
DB_PORT (defaults to 5432)
DB_NAME (defaults to postgres)
If we set the environment variables by prepending them, it would look like the following:

DB_USERNAME=username_here DB_PASSWORD=password_here python app.py
The benefit here is that it's explicitly set. However, note that the DB_PASSWORD value is now recorded in the session's history in plaintext. There are several ways to work around this including setting environment variables in a file and sourcing them in a terminal session.

Verifying The Application
Generate report for check-ins grouped by dates curl <BASE_URL>/api/reports/daily_usage

Generate report for check-ins grouped by users curl <BASE_URL>/api/reports/user_visits