BENTHOS_HELM_CHART_VERSION=$1
CONFIG_NAME=$2
CONFIG_PATH=.configs/$CONFIG_NAME.yaml
NAMESPACE=poc-chart
RELEASE_NAME=benthos-simple-service

if [[ $BENTHOS_HELM_CHART_VERSION == "" ]] ; then
    echo "Missing benthos-helm-chart version"
    exit 1
fi

helm install $RELEASE_NAME benthos/benthos \
    --namespace $NAMESPACE \
    --version $BENTHOS_HELM_CHART_VERSION \
    --set-file config=$CONFIG_PATH \
    --debug \
    --dry-run