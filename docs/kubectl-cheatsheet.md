# Kubectl cheatsheet

## Create resources

```bash
# Create namespace
kubectl create namespace NAMESPACE --dry-run -o yaml > ns.yaml

# Create pod
kubectl run -n NAMESPACE POD --image=IMAGE --dry-run -o yaml > po.yaml

# Create deployment
kubectl create -n NAMESPACE deployment DEPLOYMENT --image=IMAGE --dry-run -o yaml > deploy.yaml

# Create configmap from file
kubectl create -n NAMESPACE configmap CONFIGMAP --from-file=path/to/file --dry-run -o yaml > cm.yaml

# Create secret from literal
kubectl create -n NAMESPACE secret generic SECRET --from-literal=key1=value1 --from-literal=key2=value2 --dry-run -o yaml > sc.yaml

# Create service
kubectl create -n NAMESPACE service SERVICE_TYPE SERVICE_NAME --tcp=HOST_PORT:TARGET_PORT --dry-run -o yaml > svc.yaml

# Create network policy
kubectl create -n NAMESPACE networkpolicy POLICY --pod-selector=key=value --ingress --dry-run -o yaml > np.yaml

# Create service account
kubectl create -n NAMESPACE serviceaccount SERVICEACCOUNT --dry-run -o yaml > serviceaccount.yaml
```

## Create user certificates

To create a user certificate for authentication, you can use OpenSSL to generate a private key and a certificate signing request (CSR). Then, sign the CSR with the cluster's Certificate Authority (CA).

```bash
# Generate a private key and CSR
openssl genrsa -out hamid.key 2048
openssl req -new -key hamid.key -subj "/CN=hamid" -out hamid.csr

# Sign the CSR with the cluster CA
openssl x509 -req -in hamid.csr -CA /etc/kubernetes/pki/ca.crt -CAkey /etc/kubernetes/pki/ca.key -out hamid.crt -CAcreateserial

# Configure kubeconfig for Hamid
kubectl config set-credentials hamid --client-certificate=hamid.crt --client-key=hamid.key
kubectl config set-context developer --cluster=kubernetes --user=hamid
kubectl config use-context developer
```

## Debug issues

### Debug commands

```bash
# Launch a separate debug pod
kubectl run -n NAMESPACE debug --image busybox --rm -it --restart Never -- sh

# Launch a debug container in a target pod
kubectl debug -n NAMESPACE pods/POD --image busybox -it -- sh

# Run a command in an existing container
kubectl exec -n NAMESPACE pods/POD -c CONTAINER  -it -- sh

# Attach to a running container
kubectl attach -n NAMESPACE pods/POD -c CONTAINER -it

# Copy file to a remote pod
kubectl cp /tmp/local NAMESPACE/POD:/tmp/remote

# Copy file from a remote pod
kubectl cp NAMESPACE/POD:/tmp/remote /tmp/local
```

### Debug nodes

Crashed kube-apiserver logs can be checked using `crictl`:

```bash
# Get the actual container ID of the crashed kube-apiserver
sudo crictl ps -a | grep kube-apiserver

# Check the logs of the crashed container (use the container ID from above)
sudo crictl logs <container-id>

# Check journal logs for kubelet and kube-apiserver
sudo journalctl -u kubelet -n 500 --no-pager | grep -i error
```
