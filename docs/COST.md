# Cost 
# Cost

This project was built on AWS using one control-plane node and two worker nodes.

## Monthly itemized cost

| Item             | Spec                                 | Qty | $/mo (approx.) |
| ---------------- | ------------------------------------ | --: | -------------: |
| Control-plane VM | t3.small                             |   1 |           ~$15 |
| Worker VMs       | t3.micro                             |   2 |           ~$14 |
| Public IPs       | AWS public IPv4 addresses            |   3 |           ~$11 |
| Block storage    | EBS volumes                          |   3 |            ~$3 |
| Object storage   | S3 bucket for Terraform remote state |   1 |            <$1 |
| DNS / domain     | None used                            |   0 |             $0 |
| **Total**        |                                      |     | **~$43/month** |

## Compared to the single-server Compose + Portainer deploy

* A single-server deployment would cost approximately **$7–15/month**.
* This Kubernetes cluster costs approximately **$43/month**.

### What the extra spend buys

The additional cost provides:

* High availability through multiple nodes.
* Automatic self-healing when Pods fail.
* Horizontal scaling using the HPA.
* Rolling updates with minimal downtime.
* Better separation of workloads and improved reliability.

For a personal project or small application, this extra cost may not be worth it. However, for production applications that require resilience and scalability, the additional expense is justified.

## How I'd halve this

I could reduce the cost significantly by using smaller instances, reducing the number of public IPv4 addresses, using spot instances for worker nodes, or even running a two-node cluster instead of three nodes for development purposes. Another option would be to shut down the environment when not in use and recreate it using Terraform when needed.

