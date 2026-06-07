# Certified Kubernetes Administrator (CKA) Cheatsheet

## Table of Contents
- [Kubernetes Components](#kubernetes-components)
  - [Overview](#overview)
  - [kube-apiserver](#kube-apiserver)
  - [etcd](#etcd)
  - [kube-controller-manager](#kube-controller-manager)
  - [kube-scheduler](#kube-scheduler)
  - [kubelet](#kubelet)
  - [kube-proxy](#kube-proxy)
  - [Metrics Server](#metrics-server)
- [Kubernetes Concepts](#kubernetes-concepts)



## Kubernetes Components

### Overview

> Note: we assume kubeadm installation:

| Component               | Description                                                               | Location      | Port  | Port Purpose                    | Runs As    | Config Location                                        |
| ----------------------- | ------------------------------------------------------------------------- | ------------- | ----- | ------------------------------- | ---------- | ------------------------------------------------------ |
| kube-apiserver          | Central API server; handles all REST operations and cluster communication | Control Plane | 6443  | Kubernetes API (HTTPS)          | Static Pod | /etc/kubernetes/manifests/kube-apiserver.yaml          |
| etcd                    | Stores all cluster state and configuration data                           | Control Plane | 2379  | Client API                      | Static Pod | /etc/kubernetes/manifests/etcd.yaml                    |
| kube-scheduler          | Assigns pods to nodes based on resource availability and constraints      | Control Plane | 10259 | HTTPS metrics and health checks | Static Pod | /etc/kubernetes/manifests/kube-scheduler.yaml          |
| kube-controller-manager | Maintains desired cluster state through control loops (nodes, replicas)   | Control Plane | 10257 | HTTPS metrics and health checks | Static Pod | /etc/kubernetes/manifests/kube-controller-manager.yaml |
| kubelet                 | Ensures containers are running in pods on each node                       | All Nodes     | 10250 | Kubelet API (HTTPS)             | systemd    | /var/lib/kubelet/config.yaml                           |
| kube-proxy              | Maintains network rules for pod-to-service communication                  | All Nodes     | 10249 | HTTP metrics                    | DaemonSet  | ConfigMap (kube-proxy)                                 |
| metrics-server          | Collects resource usage data from nodes and pods, stores data in-memory   | Control Plane | 4443  | HTTPS metrics                   | Deployment | N/A                                                    |

### kube-apiserver

Runs on master nodes as the front-end for the Kubernetes control plane. Exposes the Kubernetes API. Communicates with etcd to store and retrieve cluster data. Uses RESTful API over HTTP/HTTPS. Runs on port 6443.

Responsible for:

- Serving the Kubernetes API
- Authentication and authorization
- Validating and processing API requests
- Retrieving and updating cluster state in etcd
- Scheduling pods to nodes (in conjunction with kube-scheduler)
- Managing controllers (in conjunction with kube-controller-manager)

Check run options:

- Check pod yaml in /etc/kubernetes/manifests/kube-apiserver.yaml (kubeadm installation)
- Check pod yaml using `k get -n kube-system po kube-apiserver-<node-name> -o yaml` (kubeadm installation) 
- Check pod yaml in /etc/systemd/system/kube-apiserver.service (manual installation)

### etcd

> TODO: add https://learn.kodekloud.com/user/courses/cka-certification-course-certified-kubernetes-administrator/module/c6d2ac7d-8192-4cff-aa54-e36d888c5bd9/lesson/23a464ed-51a6-4c48-9ebd-d126d380a3ad

Runs on master nodes as a key-value store for all cluster data. Uses gRPC for communication. RUns on port 2379.

```bash
$ ./etcdctl put key1 value1
$ ./etcdctl get key1
$ ./etcdctl del key1
$ ./etcdctl txn
```

### kube-controller-manager

Responsible for running controller processes. Each controller is a separate process, but they are all compiled into a single binary and run in a single process.

Responsibilities:
- Node controller: monitors node health and evicts pods from unhealthy nodes.
- Replication controller: ensures that the desired number of pod replicas are running.

#### Node Controller

Looks after node health, evicts and reschedules pods from unhealthy nodes.

#### Replication Controller

- Ensures that the desired number of pod replicas are running of ReplicaSets.
- Evicts pods when nodes go down and creates new pods on healthy nodes.

### kube-scheduler

Responsibilities:

- Decides which pod runs on which node.
- Watches for newly created pods that have no node assigned, and selects a node for them to run on based on
  - Resource availability (CPU, memory)
  - Pod resource requests and limits
  - selectors and labels
  - Affinity/anti-affinity rules
  - Taints and tolerations
  - Other scheduling policies

The scheduler goes through two main phases:

1. Filtering: Filters out nodes that do not meet the pod's requirements.
2. Scoring: Scores the remaining nodes based on various criteria and selects the best one.

### kubelet

#### Installation

- Always installed manually on each node. It is not installed using kubeadm.
- Install:
  - > TODO: Instructions

#### Responsibilities

- Managing pods on the node.
- Communicates with the kube-apiserver to receive pod specifications and report node status.
- Uses cAdvisor to monitor resource usage of pods and containers.

### kube-proxy

#### Installation:

- Kubeadm installs kube-proxy as a DaemonSet, so it runs on all nodes in the cluster.
- Manual installation:

  ```bash
  # Check kubernetes release page

  # Download kube-proxy binary
  $ wget https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kube-proxy

  # Run it as a systemd service
  $ TODO: Instructions
  ```

#### Responsibilities

- Manages network rules on each node to allow communication from pods to services.
  - It basically maps service IPs to pod IPs.
- Implements service discovery and load balancing for services.
- Supports multiple proxy modes: userspace, iptables, and IPVS.1

### Metrics Server
Metrics Server is a cluster-wide aggregator of resource usage data. It collects metrics from the kubelet on each node and provides them to the Kubernetes API server. 

Installation:
```bash
$ k apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

## Kubernetes Concepts

### Overview

| Concept                  | Description                                                                               |
| ------------------------ | ----------------------------------------------------------------------------------------- |
| Pods                     | The smallest deployable units in Kubernetes, consisting of one or more containers.        |
| ReplicaSets              | Ensure that a specified number of pod replicas are running at any given time.             |
| Deployments              | Provide declarative updates for pods and ReplicaSets.                                     |
| DaemonSets               | Ensure that a copy of a pod is running on all or some nodes in the cluster.               |
| StatefulSets             | Manage stateful applications, providing stable network identities and persistent storage. |
| HorizontalPodAutoscalers | Automatically scale the number of pod replicas based on CPU utilization or other metrics. |
| Services                 | Abstract a set of pods and provide a stable IP address and DNS name for them.             |
| ConfigMaps               | Store configuration data in key-value pairs, which can be consumed by pods                |
| Secrets                  | Store sensitive information, such as passwords and API keys, in an encrypted format.      |
| Namespaces               | Provide a way to divide cluster resources between multiple users or teams.                |
| StorageClasses           | Define different types of storage that can be dynamically provisioned.                    |
| PersistentVolumes        | Provide storage resources that can be used by pods.                                       |
| PersistentVolumeClaims   | Requests for storage by pods.                                                             |
| Ingress                  | Manage external access to services, typically HTTP.                                       |
| NetworkPolicies          | Define rules for pod-to-pod communication within the cluster.                             |
| RBAC                     | Role-Based Access Control for managing permissions within the cluster.                    |
| ServiceAccounts          | Provide an identity for pods to interact with the Kubernetes API.                         |
| Roles and RoleBindings   | Define permissions within a namespace.                                                    |

## Container runtime cli tools

| Features \ tool | docker              | nerdctl            | ctr                     | crictl     |
| --------------- | ------------------- | ------------------ | ----------------------- | ---------- |
| Compatible with | Non-CRI/Docker      | containerd         | containerd              | CRI        |
| Community       | Docker              | containerd         | containerd              | Kubernetes |
| Purpose         | Build               | General purpose    | Debug                   | Debug      |
| Notes           |                     | Same as docker cli |                         |            |
| Installation    | shipped with docker | -                  | shipped with containerd | -          |

## Funny Terms

| Term                              | Description                                                                  |
| --------------------------------- | ---------------------------------------------------------------------------- |
| Container Runtime Interface (CRI) | An API that allows Kubernetes to interact with different container runtimes. |
| Open Container Initiative (OCI)   | A set of open standards for container image formats and runtimes.            |
| Container Network Interface (CNI) | A specification for configuring network interfaces in Linux containers.      |
| Container Storage Interface (CSI) | A standard for exposing storage systems to containerized workloads.          |
