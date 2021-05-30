A [Kubegres](https://github.com/reactive-tech/kubegres) cluster with a custom Postgres v13.3 Docker image. It uses [Bank Vaults](https://github.com/banzaicloud/bank-vaults) to inject secrets into all Kubegres pods including the master, replica and backup cronjob pods.

````

kubectl apply -f https://raw.githubusercontent.com/reactive-tech/kubegres/main/kubegres.yaml

# For K3D
helm upgrade --install pg ./chart --set storageClassName=local-path

# For Kind
helm upgrade --install pg ./chart --set storageClassName=standard
````