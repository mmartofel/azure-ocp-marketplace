
rm /Users/mmartofe/.azure/osServicePrincipal.json

# My installation dir is ./config so I need to purge this one
rm -rf ./config

./openshift-install create install-config --dir ./config --log-level debug

