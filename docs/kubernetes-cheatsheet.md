# Kubernetes cheatsheet

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
- Static Token File:  a simple csv file containing bearer tokens mapped to user names and groups.
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

