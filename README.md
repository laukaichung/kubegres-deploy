A [Kubegres](https://github.com/reactive-tech/kubegres) cluster using a custom PG image. It uses [Bank Vaults](https://github.com/banzaicloud/bank-vaults) to inject secrets into the pods environment.

````

kubectl apply -f https://raw.githubusercontent.com/reactive-tech/kubegres/main/kubegres.yaml

# For K3D
helm upgrade --install pg ./chart --set storageClassName=local-path

# For Kind
helm upgrade --install pg ./chart --set storageClassName=standard
````