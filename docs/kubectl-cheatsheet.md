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

### Create user certificates

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

### Usefull commands

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

### Debug workloads

Debugging workloads such as deployments, statefulsets, and daemonsets and pods is pretty straight forward. The steps below can be followed from top to bottom or vice versa.

1. Check problems with workloads:

   ```bash
   # Find pods that are not in Running or Completed state
   # State can be CrashLoopBackOff, Error, ImagePullBackOff, Pending, Terminating
   kubectl get -A po | grep -ivE 'Running|Completed'
   ```

1. Describe the problematic parent resource to check events and status:

   ```bash
   kubectl describe -n NAMESPACE deploy/DEPLOYMENT
   ```

1. Describe the problematic pod to check events and status:

   Events usually give good hints about what is going wrong. Most common issues are related to image pull errors, scheduling issues (resources or pod affinity), or failing liveness/readiness probes.

   ```bash
   kubectl describe -n NAMESPACE po/POD
   ```

1. Check the logs of the problematic pod:

   ```bash
   kubectl logs -n NAMESPACE po/POD -c CONTAINER --tail 100 --follow --previous
   ```

1. Use commands from [Debug kubectl commands](#usefull-commands) section to further investigate the issue.

### Debug scheduling issues

Scheduling issues can be tricky to debug. Here are some steps to help you identify and resolve scheduling problems:

1. Describe the unschedulable pod to check events and status. Look for events related to scheduling, such as insufficient resources, node affinity/taints, or other constraints.

1. Check pod conditions and reasons for unschedulability.

1. Check nodes status and resources.

1. If none of the above steps help, check the logs of the scheduler component:

   ```bash
   # Get the scheduler pod name
   kubectl get pods -n kube-system | grep kube-scheduler

   # Check the logs of the scheduler pod
   kubectl logs -n kube-system POD_NAME
   ```

### Debug networking

Debugging networking issues can be hard, you often get unrelated errors, such as timeouts, connection refused or SSL errors. Here are some tips and steps to help you debug networking issues in your cluster:

- Before you even start debugging, take some time to understand the network setup and how traffic flows. Drawing out the network topology with something like draw.io can really help you spot where things might be going wrong.
- Use `nginx:alpine` or `yauritux/busybox-curl` images for debugging networking issues, as they come with useful networking tools like `curl`, `wget`, `ping`, and `nslookup`.
- Use `nicolaka/netshoot` image for advanced network troubleshooting. It includes tools like `tcpdump`, `traceroute`, `dig`, and more.
