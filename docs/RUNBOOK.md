# Runbook (fill this in — a teammate must rebuild from this alone)

## Provision from zero
```
# 1. Provision infrastructure
cd infra/terraform/cluster
terraform init
terraform apply

# 2. Configure the Kubernetes cluster
cd ../../ansible
ansible-playbook -i inventory site.yml

# 3. Verify cluster access
export KUBECONFIG=./kubeconfig
kubectl get nodes

# 4. Install platform components
kubectl apply -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# 5. Enable GitOps
kubectl apply -f https://raw.githubusercontent.com/Erhokhon/capstone-phoenix/main/gitops/taskapp/taskapp-app.yaml

# 6. Verify application
kubectl get applications -n argocd
kubectl get pods -n taskapp
```

## Day-2 operations
* **Scale a tier:**

  * Update the `replicas` field in the Deployment manifest, commit the change, and push it to Git. Argo CD automatically synchronizes the new desired state.

* **Roll back a bad deploy:**

  ```bash id="rollbk"
  kubectl rollout undo deployment/backend -n taskapp
  kubectl rollout undo deployment/frontend -n taskapp
  ```

* **Run a new migration safely:**

  * Update `migration-job.yaml`, commit the change, and let Argo CD apply the new migration Job. Migrations are not executed inside running backend containers.

* **Rotate a secret:**

  ```bash id="secretrot"
  kubectl delete secret backend-secret -n taskapp
  kubectl apply -f backend-secret.yaml
  ```

  Commit the updated manifest so Git remains the source of truth.


## Failure recovery (you'll demo one of these live)
* **A worker node dies / is drained:**

  * Kubernetes automatically reschedules affected Pods onto healthy nodes.
  * Deployments maintain the desired replica count and services continue routing traffic to healthy Pods.

  ```bash id="draincmd"
  kubectl drain <node> --ignore-daemonsets --delete-emptydir-data
  ```

  Expected recovery time is usually less than one minute because replacement Pods are scheduled automatically.

* **A backend Pod crashloops:**

  ```bash id="debug1"
  kubectl logs <pod-name> -n taskapp --previous
  kubectl describe pod <pod-name> -n taskapp
  kubectl get events -n taskapp
  ```

* **A bad migration:**

  * Restore the database from backup or roll back the migration manually.
  * Revert the migration Job manifest in Git and allow Argo CD to synchronize the corrected state.

* **Postgres Pod is rescheduled:**

  * Because PostgreSQL uses a StatefulSet and Persistent Volume Claim (PVC), the volume is reattached automatically and application data remains intact.
  * Data persistence can be verified by deleting the PostgreSQL Pod and confirming that previously stored data still exists after the new Pod starts.

