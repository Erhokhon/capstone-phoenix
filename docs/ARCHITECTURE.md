# Architecture (fill this in)

## 1. Topology diagram
> Draw it (ASCII, Excalidraw, draw.io — anything). Show: your nodes, where each TaskApp
> tier runs, the ingress controller, and the request path.

```
                          Internet
                            │
                            │
                    http://13.50.33.163
                            │
                            ▼
                    Traefik Ingress Controller
                            │
        ┌───────────────────┴───────────────────┐
        │                                       │
        ▼                                       ▼
 frontend Service                          backend Service
        │                                       │
        │                                       │
        ▼                                       ▼
frontend Pod 1                           backend Pod 1
(Node: ip-10-0-1-166)                    (Node: ip-10-0-1-243)

frontend Pod 2                           backend Pod 2
(Node: ip-10-0-1-243)                    (Node: ip-10-0-1-220)
                                                │
                                                │
                                                ▼
                                        postgres Service
                                                │
                                                ▼
                                           postgres-0
                                      PVC: 1Gi local-path
                                      (Node: ip-10-0-1-220)
## 2. Node & network
  * Nodes (role, size, AZ/region):

  * Control Plane: ip-10-0-1-220 (AWS EC2 t3.small, eu-north-1)
  * Worker 1: ip-10-0-1-166 (AWS EC2 t3.micro, eu-north-1)
  * Worker 2: ip-10-0-1-243 (AWS EC2 t3.micro, eu-north-1)

* CIDR / subnet choices and why:

  * VPC CIDR: 10.0.0.0/16
  * Private subnet: 10.0.1.0/24.
  * This provides enough addresses for cluster nodes and Kubernetes networking while keeping node-to-node communication internal.

* Firewall:

  * Port 22 (SSH): open only to my IP address.
  * Port 80 (HTTP): open to the internet.
  * Port 443 (HTTPS): open to the internet.
  * Kubernetes API port 6443 is not exposed to the public internet because only the cluster nodes need access to the control plane. Keeping it private reduces the attack surface and follows the principle of least privilege.


## 3. Request flow (one paragraph)
A user accesses the application through the public IP address (and later through a custom domain). The request reaches the Traefik Ingress Controller on port 80/443. Requests to `/` are forwarded to the `frontend` Service, which routes traffic to one of the frontend Pods running on port 80. Requests to `/api` are forwarded to the `backend` Service, which load-balances traffic across the backend Pods running on port 5000. The backend Pods communicate with the `postgres` Service on port 5432, which forwards database requests to the `postgres-0` StatefulSet Pod that stores its data on a persistent volume claim (PVC).


## 4. The single-server assumptions you fixed...
| Single-server assumption                              | Why it breaks at scale                                                                                               | How you fixed it                                                                                     |
| ----------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------- |
| Migrate-on-boot in the entrypoint                     | Multiple backend replicas can run migrations simultaneously and corrupt the schema or fail with migration conflicts. | Database migrations were moved to a dedicated Kubernetes Job (`migration-job.yaml`).                 |
| Database data stored on the container filesystem      | When a Pod is deleted or rescheduled, all data would be lost.                                                        | PostgreSQL runs as a StatefulSet with a Persistent Volume Claim (PVC).                               |
| Publishing ports directly from containers             | Multiple Pods and multiple nodes require a single entry point and service discovery mechanism.                       | Kubernetes Services and Traefik Ingress provide stable access and load balancing.                    |
| One backend process is enough                         | A single Pod failure causes application downtime.                                                                    | Backend runs with two replicas distributed across different nodes.                                   |
| One frontend process is enough                        | A single node failure makes the UI unavailable.                                                                      | Frontend runs with two replicas spread across different worker nodes.                                |
| Manual restarts after failures                        | Containers can crash unexpectedly and require automatic recovery.                                                    | Kubernetes Deployments automatically recreate failed Pods.                                           |
| Updating the application directly on the server       | Replacing containers manually causes downtime and configuration drift.                                               | Argo CD continuously reconciles the cluster state from Git (GitOps).                                 |
| Environment variables stored directly on the server   | Secrets and configuration become difficult to manage and unsafe to share.                                            | Non-sensitive values are stored in ConfigMaps and sensitive values are stored in Kubernetes Secrets. |
| Deploying a new version by stopping the old one first | Users experience downtime during deployments.                                                                        | RollingUpdate strategy with `maxUnavailable: 0` provides zero-downtime deployments.                  |


## 5. Choices & trade-offs
* Raw YAML vs Helm vs kustomize — why:

  * I used raw Kubernetes YAML manifests because the application is relatively small and I wanted to understand every Kubernetes object directly instead of abstracting them behind Helm templates.

* ingress-nginx vs k3s Traefik — why:

  * I used Traefik because it comes bundled with k3s, reduces setup complexity, and integrates easily with Ingress resources.

* CNI / NetworkPolicy enforcement — what and why:

  * The cluster uses the default k3s networking stack. Basic NetworkPolicies were added, although full enforcement would require a network plugin such as Cilium or Calico.

* Secrets approach (out-of-band vs Sealed/External Secrets) — why:

  * I used Kubernetes Secrets because they are simple to manage and sufficient for this project. In a production environment, I would use Sealed Secrets or External Secrets to keep secrets safely in Git.

