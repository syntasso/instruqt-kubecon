#!/bin/bash
set -euxHo pipefail

# Fail fast if secret is not set
set +x
source /etc/secret_environment
echo ${GHCR_BACKSTAGE} | grep ghp >/dev/null 2>&1
set -x


######################################
######################################
#              base vm               #
######################################
######################################

######################################
#            LINUX TOOLING           #
######################################
source /root/.bashrc_custom
cat >> ${BASH_RC} <<EOF
source ${BASH_RC_CUSTOM}
EOF

apt update
apt install -y bash-completion make nginx neovim software-properties-common tree vim wget

wget https://github.com/mikefarah/yq/releases/download/v${VERSION_YQ}/yq_linux_amd64 -O /usr/bin/yq
chmod +x /usr/bin/yq


######################################
#                HELM                #
######################################

curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | tee /usr/share/keyrings/helm.gpg > /dev/null
apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list
apt-get update
apt-get install helm=${VERSION_HELM}


######################################
#               DOCKER               #
######################################
# snap install --beta nvim --classic # Failing to load

for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do apt-get remove $pkg || true; done

# Add Docker's official GPG key:
apt -y install ca-certificates curl jq
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

docker version

######################################
#             KUBERNETES             #
######################################
curl -LO "https://dl.k8s.io/release/${VERSION_KUBECTL}/bin/linux/amd64/kubectl"
mv kubectl /usr/bin
chmod +x /usr/bin/kubectl
/usr/bin/kubectl completion bash | tee /etc/bash_completion.d/kubectl > /dev/null

curl -Lo ./kind https://kind.sigs.k8s.io/dl/v${VERSION_KIND}/kind-linux-amd64
chmod +x ./kind
mv ./kind /usr/local/bin/kind

(
  set -x; cd "$(mktemp -d)" &&
  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
  KREW="krew-${OS}_${ARCH}" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/${VERSION_KREW}/download/${KREW}.tar.gz" &&
  tar zxvf "${KREW}.tar.gz" &&
  ./"${KREW}" install krew
)

# Need to set the path for now, and via the BASH_RC_CUSTOM for always.
# Can't only source bashrc due to missing envvars in non-interactive mode
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
echo "export PATH=\"${KREW_ROOT:-$HOME/.krew}/bin:$PATH\"" >> ${BASH_RC_CUSTOM}

kubectl krew install ctx
kubectl krew install ns
kubectl krew install stern
kubectl krew install tree

cat >> ${BASH_RC_CUSTOM} <<EOF
alias kx="kubectl ctx"
alias kn="kubectl ns"
alias stern="kubectl stern"
EOF

cat >> ${BASH_RC_CUSTOM} <<EOF
source /usr/share/bash-completion/bash_completion

alias k=kubectl
alias kaf="kubectl apply -f"
complete -o default -F __start_kubectl k

if [ -f /etc/bash_completion ]; then
   . /etc/bash_completion
fi
EOF

######################################
#           GITOPS TOOLING           #
######################################
curl https://dl.min.io/client/mc/release/linux-amd64/mc \
  --create-dirs \
  -o $HOME/minio-binaries/mc
chmod +x $HOME/minio-binaries/mc
mv $HOME/minio-binaries/mc /usr/local/bin/mc
rm -rf $HOME/minio-binaries

wget https://dl.gitea.com/tea/${VERSION_TEA_CLI}/tea-${VERSION_TEA_CLI}-linux-amd64 -O /usr/bin/tea
chmod +x /usr/bin/tea

curl -s https://fluxcd.io/install.sh | FLUX_VERSION=${VERSION_FLUX_CLI} bash
cat >> ${BASH_RC_CUSTOM} <<EOF
. <(flux completion bash)
EOF

curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/download/v${VERSION_ARGOCD_CLI}/argocd-linux-amd64
install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64

######################################
#              SYNTASSO              #
######################################
mkdir -p bin
curl -sLo ./bin/worker-resource-builder.tar.gz https://github.com/syntasso/kratix/releases/download/v${VERSION_SYNTASSO_WORKER_RESOURCE_BUILDER}/worker-resource-builder_${VERSION_SYNTASSO_WORKER_RESOURCE_BUILDER}_linux_amd64.tar.gz
tar -xvf ./bin/worker-resource-builder.tar.gz -C ./bin
mv ./bin/worker-resource-builder-v* ./bin/worker-resource-builder
chmod +x ./bin/worker-resource-builder
mv ./bin/worker-resource-builder /usr/local/bin/worker-resource-builder

# install go
curl -LO https://golang.org/dl/go${VERSION_GOLANG}.linux-amd64.tar.gz
rm -rf /usr/local/go && tar -C /usr/local -xzf go${VERSION_GOLANG}.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin
echo 'export PATH=$PATH:/usr/local/go/bin' >> ${BASH_RC_CUSTOM}

curl -s -o /usr/local/bin/kratix-ske http://s3.eu-west-2.amazonaws.com/syntasso-enterprise-releases/ske-cli/${VERSION_OSS_KRATIX_CLI}/ske-cli_linux_amd64_v1/ske
chmod +x /usr/local/bin/kratix-ske

# Install Kraitx CLI
go install github.com/syntasso/kratix-cli/cmd/kratix@latest
export PATH=$PATH:$HOME/go/bin


cd $HOME

git clone https://github.com/syntasso/kratix


######################################
#              RUN TIME              #
######################################

cat << EOF >> ${BASH_RC_CUSTOM}
docker_container_ip() {
    docker inspect \$1 | yq ".[0].NetworkSettings.Networks.kind.IPAddress"
}
export -f docker_container_ip
EOF
source ${BASH_RC_CUSTOM}

provision_clusters() {
  kind delete clusters --all

  kind create cluster \
      --name platform \
      --image kindest/node:${VERSION_KIND_NODE} \
      --config ${HOME}/resources/kind-platform-config.yaml

  kubectl --context $PLATFORM apply --filename https://github.com/cert-manager/cert-manager/releases/download/v${VERSION_CERT_MANAGER}/cert-manager.yaml

  kind create cluster \
      --name worker \
      --image kindest/node:${VERSION_KIND_NODE} \
      --config config/samples/kind-worker-config.yaml

  kubectl --context kind-platform wait --for condition=available -n cert-manager deployment/cert-manager --timeout 100s
  kubectl --context kind-platform wait --for condition=available -n cert-manager deployment/cert-manager-cainjector --timeout 100s
  kubectl --context kind-platform wait --for condition=available -n cert-manager deployment/cert-manager-webhook --timeout 100s

  kubectl config use-context $PLATFORM
}

install_kratix() {
  kubectl --context $PLATFORM apply --filename https://github.com/syntasso/kratix/releases/${VERSION_OSS_KRATIX}/download/kratix.yaml

  kubectl --context $PLATFORM wait --for=condition=available --timeout=5m deployment/kratix-platform-controller-manager --namespace kratix-platform-system
  kubectl --context $PLATFORM wait --for=condition=established --timeout=5m crd/gitstatestores.platform.kratix.io
  kubectl --context $PLATFORM wait --for=condition=established --timeout=5m crd/destinations.platform.kratix.io
  kubectl --context $PLATFORM wait --for=condition=established --timeout=5m crd/promises.platform.kratix.io
}

generate_gitea_credentials() {
    giteabin="bin/gitea"
    if which gitea > /dev/null; then
        giteabin="$(which gitea)"
    fi

    if [ ! -f "${giteabin}" ]; then
        error "gitea cli not found; run 'make gitea-cli' to download it"
        exit 1
    fi
    local context="${1:-kind-platform}"
    $giteabin cert --host "$(docker_container_ip ${PLATFORM_DOCKER_CONTAINER})" --ca

    kubectl create namespace gitea --context ${context} || true

    kubectl create secret generic gitea-credentials \
        --context "${context}" \
        --from-file=caFile=cert.pem \
        --from-file=privateKey=key.pem \
        --from-literal=username="gitea_admin" \
        --from-literal=password="r8sA8CPHD9" \
        --namespace=gitea \
        --dry-run=client -o yaml | kubectl apply --context ${context} -f -

    kubectl create secret generic gitea-credentials \
        --context "${context}" \
        --from-file=caFile=cert.pem \
        --from-file=privateKey=key.pem \
        --from-literal=username="gitea_admin" \
        --from-literal=password="r8sA8CPHD9" \
        --namespace=default \
        --dry-run=client -o yaml | kubectl apply --context ${context} -f -

    kubectl create namespace flux-system --context ${context} || true
    kubectl create secret generic gitea-credentials \
        --context "${context}" \
        --from-file=caFile=cert.pem \
        --from-file=privateKey=key.pem \
        --from-literal=username="gitea_admin" \
        --from-literal=password="r8sA8CPHD9" \
        --namespace=flux-system \
        --dry-run=client -o yaml | kubectl apply --context ${context} -f -

    rm cert.pem key.pem
}

setup_gitea() {
  export context="kind-platform"
  make gitea-cli
  generate_gitea_credentials

  helm repo add gitea-charts https://dl.gitea.com/charts/
  helm repo update
  helm template gitea gitea-charts/gitea --version ${VERSION_GITEA} --values ${HOME}/resources/gitea-provision.yaml | kubectl --context kind-platform apply -f -
  kubectl wait --context $PLATFORM --for=create -n gitea deployment/gitea
  kubectl wait --context $PLATFORM --for=condition=Available -n gitea --timeout=5m deployment/gitea
  kubectl wait --context $PLATFORM --for=create -n gitea job/gitea-create-repository
  kubectl wait --context $PLATFORM --for=condition=complete -n gitea --timeout=5m job/gitea-create-repository

  cat << EOF | kubectl --context $PLATFORM apply -f -
apiVersion: platform.kratix.io/v1alpha1
kind: GitStateStore
metadata:
  name: default
spec:
  secretRef:
    name: gitea-credentials
    namespace: default
  url: https://$(docker_container_ip ${PLATFORM_DOCKER_CONTAINER}):31443/gitea_admin/kratix
  branch: main
EOF
}

setup_minio() {
  kubectl --context $PLATFORM apply --filename config/samples/minio-install.yaml

  kubectl wait --context $PLATFORM --for=create -n kratix-platform-system deployment/minio
  kubectl wait --context $PLATFORM --for=condition=Available -n kratix-platform-system deployment/minio --timeout=100s
  kubectl wait --context $PLATFORM --for=create -n default job.batch/minio-create-bucket
  kubectl wait --context $PLATFORM --for=condition=complete -n default job.batch/minio-create-bucket --timeout 5m

  mc alias set kind http://localhost:31337 minioadmin minioadmin

  cat << EOF | kubectl --context $PLATFORM apply -f -
apiVersion: platform.kratix.io/v1alpha1
kind: BucketStateStore
metadata:
  name: default
spec:
  endpoint: minio.kratix-platform-system.svc.cluster.local
  insecure: true
  bucketName: kratix
  secretRef:
    name: minio-credentials
    namespace: default
EOF
}

register_and_setup_destinations() {
  ./scripts/register-destination --name platform-cluster --context $PLATFORM --state-store default --git --strict-match-labels --with-label environment=platform
  gitrepositories_platform=(
    kratix-platform-dependencies
    kratix-platform-resources
  )
  for repo in "${gitrepositories_platform[@]}"; do
    kubectl wait --context ${PLATFORM} -n flux-system --timeout=5s --for=create gitrepositories.source.toolkit.fluxcd.io $repo
    kubectl patch --context ${PLATFORM} GitRepository $repo -n flux-system --type='merge' -p '{"spec":{"url":"https://172.18.0.2:31443/gitea_admin/kratix"}}'
  done

  ./scripts/register-destination --name worker-cluster --context $WORKER --state-store default --git --with-label environment=dev
  gitrepositories_worker=(
    kratix-worker-dependencies
    kratix-worker-resources
  )
  for repo in "${gitrepositories_worker[@]}"; do
    kubectl wait --context ${WORKER} -n flux-system --timeout=5s --for=create gitrepositories.source.toolkit.fluxcd.io $repo
    kubectl patch --context ${WORKER} -n flux-system gitrepositories.source.toolkit.fluxcd.io $repo --type='json' -p='[{"op": "replace", "path": "/spec/url", "value": "https://172.18.0.2:31443/gitea_admin/kratix"}]'
  done
}

cd $HOME/kratix
provision_clusters
install_kratix
setup_gitea
setup_minio
register_and_setup_destinations


######################################
######################################
#          Backstage base            #
######################################
######################################

######################################
#             Pull images            #
######################################
set +x
echo ${GHCR_BACKSTAGE} | docker login --username syntasso-pkg --password-stdin ghcr.io >/dev/null 2>&1
set -x
docker pull ghcr.io/syntasso/backstage-instruqt:dev
docker pull ghcr.io/syntasso/ske-backstage-generator:${VERSION_SYNTASSO_BACKSTAGE_GENERATOR}
docker tag ghcr.io/syntasso/ske-backstage-generator:${VERSION_SYNTASSO_BACKSTAGE_GENERATOR} registry.syntasso.io/ske-backstage-generator:${VERSION_SYNTASSO_BACKSTAGE_GENERATOR}

######################################
#       NGINX for example app        #
######################################
configure_nginx() {
  # Setup nginx on the Instruqt VM
  # The site configuration below enables access to the Todo App running on the
  #   nginx deployed on the Kubernetes Cluster
  sudo cat > /etc/nginx/sites-available/default <<EOF
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    server_name _;

    location / {
        proxy_pass http://localhost:31338;
        proxy_set_header Host todoer.local.gd;
    }
}
EOF

  sudo systemctl restart nginx
}


######################################
#              Backstage             #
######################################


load_backstage_images() {
    kind load docker-image ghcr.io/syntasso/backstage-instruqt:dev --name platform
    kind load docker-image registry.syntasso.io/ske-backstage-generator:${VERSION_SYNTASSO_BACKSTAGE_GENERATOR} --name platform
}


setup_backstage_server() {
    kubectl --context kind-platform apply -f ${HOME}/resources/backstage
    kubectl --context kind-platform wait -n default --for=create deployment/backstage
    kubectl --context kind-platform wait -n default --for=condition=Available deployment/backstage
}

setup_postgres_backstage_workflow() {
  cd ${HOME}/resources/backstage/workflow-container
  docker build --platform linux/amd64 . --tag kubecon-workshop/backstage:dev
  kind load docker-image kubecon-workshop/backstage:dev --name platform
}

prepare_hackathon_resources() {
  mkdir -p ${HOME}/hackathon/{app-as-a-service,nginx-ingress,postgres}

  curl -o ${HOME}/hackathon/postgres/promise.yaml https://raw.githubusercontent.com/syntasso/promise-postgresql/main/promise.yaml
  cat <<EOF > $HOME/hackathon/postgres/request.yaml
apiVersion: marketplace.kratix.io/v1alpha2
kind: postgresql
metadata:
  name: example
  namespace: default
spec:
  env: dev
  teamId: acid
  dbName: bestdb
EOF


  curl -o ${HOME}/hackathon/nginx-ingress/promise.yaml https://raw.githubusercontent.com/syntasso/kratix-marketplace/${VERSION_KRATIX_MARKETPLACE}/nginx-ingress/promise.yaml
  
  # Pull the app-as-a-service Promise from the marketplace repo without environment variables.
  git clone -n --depth=1 --filter=tree:0 https://github.com/syntasso/kratix-marketplace ${HOME}/kratix-marketplace && cd ${HOME}/kratix-marketplace && git checkout ${VERSION_KRATIX_MARKETPLACE}
  git sparse-checkout set --no-cone /app-as-a-service && git checkout ${VERSION_KRATIX_MARKETPLACE}
  # Make pipeline script work locally (and not depend on whole marketplace repo)
  cp ${HOME}/resources/pipeline-image ${HOME}/kratix-marketplace/app-as-a-service/internal/scripts
  cp -r ${HOME}/kratix-marketplace/app-as-a-service ${HOME}/hackathon

  # Fetch the new script for v0.2.0 of the aspect
  curl -o ${HOME}/hackathon/environment-vars-configure https://raw.githubusercontent.com/Phiph/kratix-marketplace/refs/heads/env-vars/app-as-a-service/internal/configure-pipeline/environment-vars-configure
  chmod +x ${HOME}/hackathon/environment-vars-configure
}

load_platform_images() {
  container_images=(
    "docker.io/alpine/git:2.36.3"
    "docker.io/bitnami/kubectl:1.28.6"
    "ghcr.io/syntasso/kratix-marketplace/app-as-a-service-configure-pipeline:v0.1.0"
    "ghcr.io/syntasso/kratix-marketplace/app-as-a-service-configure-pipeline:v0.2.0"
    "ghcr.io/syntasso/kratix-marketplace/nginx-ingress-configure-pipeline:v0.1.0"
    "ghcr.io/syntasso/kratix-pipeline-utility:v0.0.1"
    "ghcr.io/syntasso/promise-postgresql/postgresql-configure-pipeline:v0.2.0"
  )
  for image in $container_images[@]; do
    (
        docker pull "$image"
        kind load docker-image --name platform "$image"
    ) &
  done
  wait
}

load_worker_images() {
  container_images=(
    "nginx/nginx-ingress:3.3.1"
    "registry.opensource.zalan.do/acid/postgres-operator:v1.8.2-43-g3e148ea5"
    "registry.opensource.zalan.do/acid/spilo-14:2.1-p6"
    "syntasso/sample-todo-app:v1.0.0"
  )
  for image in $container_images[@]; do
    (
        docker pull "$image"
        kind load docker-image --name worker "$image"
    ) &
  done
  wait
}

 
cd $HOME/kratix
configure_nginx
load_backstage_images
setup_backstage_server
setup_postgres_backstage_workflow
prepare_hackathon_resources

shutdown_kind_safely
