configs=("spaces" "ok")
versions=("2.0.1" "2.1.0" "2.1.1")

[ -d stdout ] || mkdir stdout
[ -d configmap ] || mkdir configmap
[ -d log ] || mkdir log

# Validate files
docker run --rm \
    -v ./.configs:/.configs \
    jeffail/benthos:4.24.0 lint .configs/* || {
        echo Configs are invalid
        exit 1
    }

echo Configs are valid

rm -rf stdout/*
rm -rf configmap/*
rm -rf logs/*

configs=()
cd .configs
for filename in *
do
    config=$(echo "$filename" | cut -d "." -f 1)
    configs+=($config)
done
cd ..

for config in ${configs[@]}; do
    for version in ${versions[@]}; do
        printf "Config: $config - Version: $version"
        bash poc_benthos.sh $version $config &> "stdout/$config-$version.txt"
        printf " -> Done\n"
    done
done
