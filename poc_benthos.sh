BENTHOS_HELM_CHART_VERSION=$1
CONFIG_NAME=$2
CONFIG_PATH=.configs/$CONFIG_NAME.yaml
NAMESPACE=poc-chart
RELEASE_NAME=benthos-simple-service

if [[ $BENTHOS_HELM_CHART_VERSION == "" ]] ; then
    echo "Missing benthos-helm-chart version"
    exit 1
fi

if [[ $CONFIG_NAME == "" ]] ; then
    echo "Missing config path"
    exit 1
fi

if [ ! -f $CONFIG_PATH ]; then
    echo "$CONFIG_PATH does not exist."
    exit 1
fi

# printf "Start minikube"
# minikube start

printf "benthos-helm-chart version $BENTHOS_HELM_CHART_VERSION\n"

printf "\nCreate namespace\n"
kubectl create namespace $NAMESPACE

printf "\nAdd helm repo\n"
helm repo add benthos https://benthosdev.github.io/benthos-helm-chart

printf "\nCreate release\n"
helm upgrade --install $RELEASE_NAME benthos/benthos \
    --version $BENTHOS_HELM_CHART_VERSION \
    -n $NAMESPACE \
    --set-file config=$CONFIG_PATH

kubectl wait pod --all --for=condition=Ready --namespace=$NAMESPACE --timeout=1m

POD_NAME=$(kubectl get pods --namespace $NAMESPACE -l "app.kubernetes.io/name=benthos,app.kubernetes.io/instance=$RELEASE_NAME" -o jsonpath="{.items[0].metadata.name}")

sleep 2

printf "\nLogs ------------------------\n"
LOGS=$(kubectl logs $POD_NAME --namespace $NAMESPACE)
printf "$LOGS"
printf "$LOGS" > "log/$CONFIG_NAME-$BENTHOS_HELM_CHART_VERSION.txt"
printf "\n------------------------\n"

printf "\nConfigMap ------------------------\n"
CONFIG_MAP=$(kubectl get configmap $RELEASE_NAME-config --namespace $NAMESPACE -o "jsonpath={.data['benthos\.yaml']}")
printf "$CONFIG_MAP"
printf "$CONFIG_MAP" > "configmap/$CONFIG_NAME-$BENTHOS_HELM_CHART_VERSION.txt"
printf "\n------------------------\n"

printf "\nTeardown ------------------------\n"

printf "\nDelete release\n"
helm del $RELEASE_NAME -n $NAMESPACE

printf "\nDelete namespace\n"
kubectl delete namespace $NAMESPACE

# printf "\nDelete MiniKube\n"
# minikube delete