# Kubernetes cheatsheet

## Table of Contents
TODO

## Limit resource usage


### Limit Ranges

### Resource Quotas

## Workloads

### Deployment strategies

- Blue-Green Deployment: Maintain two identical production environments (blue and green). One environment is live while the other is idle. Switch traffic between them during deployments.
- Canary Deployment: Gradually roll out changes to a small subset of users before making it available to the entire infrastructure.
- Recreate Deployment: Terminate all existing pods before creating new ones.
- Rolling Update: Incrementally update pods with new versions without downtime.

## Authentication

### Users

There are no native user objects in Kubernetes. User management is typically handled outside of Kubernetes, often through an identity provider or certificate management system.



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
