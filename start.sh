#/bin/bash
ERC4337_BUNDLER_GIN_MODE=debug nohup ./stackup-bundler start --mode private > output.log 2>&1 &
echo $! > bundler.pid