A [Kubegres](https://github.com/reactive-tech/kubegres) cluster with a custom Postgres v13.3 Docker image.

It uses [Bank Vaults](https://github.com/banzaicloud/bank-vaults) to inject secrets into all Kubegres pods including the master, replica and backup cronjob pods.

Both `backup_database.sh` and `primary_init_script.sh` are overridden in order to use S3 backup and initialization. 

The scripts will assume an IAM role before downloading or uploading from a bucket of your choice, so make sure you have created an IAM role and attached this policy to it.
````
{
    "Statement": [
        {
            "Action": [
                "s3:PutObject",
                "s3:GetObject"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::your_bucket/*"
            ]
        },
        {
            "Action": [
                "s3:ListBucket"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::your_bucket"
            ]
        }
    ],
    "Version": "2012-10-17"
}
````
The `s3:ListBucket` action is required by the initialization script in order to sort and fetch the latest dump files in a folder.

### Install Bank Vaults Operator
````
helm repo add banzaicloud-stable https://kubernetes-charts.banzaicloud.com
helm upgrade --install vault-operator banzaicloud-stable/vault-operator
````

### Install Vault

````
helm upgrade --install vault ./vault --set storageClassName=standard
````

### Install Vault Secrets Webhook
````
kubectl create namespace vault-infra
kubectl label namespace vault-infra name=vault-infra
helm repo add banzaicloud-stable https://kubernetes-charts.banzaicloud.com
# The `configMapMutation=true` is neccessary in order to inject secrets into ConfigMap.
helm upgrade --namespace vault-infra --install vault-secrets-webhook banzaicloud-stable/vault-secrets-webhook --set configMapMutation=true --set secretsFailurePolicy=Fail
````

### Import data to Vault
Once Vault is up, fill in your credentials in `pg-data.json` and import the file to Vault
````
kubectl port-forward vault-0 8200 &

export VAULT_ADDR=https://127.0.0.1:8200

kubectl get secret vault-tls -o jsonpath="{.data.ca\.crt}" | base64 --decode > /tmp/vault-ca.crt

export VAULT_CACERT=/tmp/vault-ca.crt

export VAULT_TOKEN=$(kubectl get secrets vault-unseal-keys -o jsonpath={.data.vault-root} | base64 --decode)

vault kv put -format=json secret/pg @pg-data.json

````

### Install Kubegres cluster
````
kubectl apply -f https://raw.githubusercontent.com/reactive-tech/kubegres/main/kubegres.yaml

# For Kind. If you use K3d, you should use storageClassName=local-path
helm upgrade --install pg ./pg --set storageClassName=standard

````

### Uninstall Kubegres cluster

````
helm uninstall pg
````

