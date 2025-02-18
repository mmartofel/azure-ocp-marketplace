
./create_rg.sh

rm -rf ./config
mkdir ./config
cp install-config.yaml ./config

./openshift-install create cluster --dir ./config # --log-level debug

