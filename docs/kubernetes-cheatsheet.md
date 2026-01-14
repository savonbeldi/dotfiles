# Kubernetes cheatsheet

## Workloads

### Deployment strategies

- Blue-Green Deployment: Maintain two identical production environments (blue and green). One environment is live while the other is idle. Switch traffic between them during deployments.
- Canary Deployment: Gradually roll out changes to a small subset of users before making it available to the entire infrastructure.
- Recreate Deployment: Terminate all existing pods before creating new ones.
- Rolling Update: Incrementally update pods with new versions without downtime.

## Authentication

### Users

There are no native user objects in Kubernetes. User management is typically handled outside of Kubernetes, often through an identity provider or certificate management system.

#### Creating user certificates

To create a user certificate for authentication, you can use OpenSSL to generate a private key and a certificate signing request (CSR). Then, sign the CSR with the cluster's Certificate Authority (CA).

```bash
# Generate a private key and CSR
openssl genrsa -out martin.key 2048
openssl req -new -key martin.key -subj "/CN=martin" -out martin.csr

# Sign the CSR with the cluster CA
openssl x509 -req -in martin.csr -CA /etc/kubernetes/pki/ca.crt -CAkey /etc/kubernetes/pki/ca.key -out martin.crt -CAcreateserial

# Configure kubeconfig for Martin
kubectl config set-credentials martin --client-certificate=martin.crt --client-key=martin.key
kubectl config set-context developer --cluster=kubernetes --user=martin
kubectl config use-context developer
```

### service accounts

A service account provides an identity for processes that run in a Pod. When a Pod is created, Kubernetes automatically assigns a default service account to it unless specified otherwise.

```bash
# Create a service account
kubectl create serviceaccount <service-account-name> -n <namespace>
```

### kube-apiserver

Authentication mechanisms supported by kube-apiserver:

- Static Token File: a simple csv file containing bearer tokens mapped to user names and groups.
- Certificates
- Identity Providers (LDAP, Kerberos, etc.)

## Kubernetes hardening best practices

### Hosts

- Disable root acces
- Disabled all authentication methods except SSH

### Kubernetes

- Secure kube-apiserver
  - Enable RBAC
  - Use Network Policies to restrict pod communication
  - Enable audit logging

## Debug issues

### Debug workloads

Debugging workloads such as deployments, statefulsets, and daemonsets and pods is pretty straight forward:

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

1. Use commands from [Debug kubectl commands](./kubectl-cheatsheet.md#debug-kubectl-commands) section to further investigate the issue.
