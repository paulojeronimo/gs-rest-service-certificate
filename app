#!/bin/bash
set +x
set -e

BASE_DIR=`cd "$(dirname "$0")";pwd`
cd "$BASE_DIR"

config=config
[ -r $config ] || config=$config.sample
source $config

_rebuild() {
  ./gradlew clean bootJar
}

_start() {
  java -jar build/libs/gs-rest-service-0.1.0.jar
}

_install-https() {
  local pfx="$BASE_DIR"/generated/$CN.pfx
  local d=src/main/resources

  mkdir -p $d
  cp "$pfx" $d/
  cat > $d/application.properties <<EOF
server.port: 8443
server.ssl.key-store: classpath:$CN.pfx
server.ssl.key-store-password: ${storepass}
server.ssl.keyStoreType: PKCS12
server.ssl.keyAlias: ${alias}
EOF
}

op=$1
if type _$op &> /dev/null
then
  [ -d "$gs_rest_service_dir" ] || exit 1
  cd "$gs_rest_service_dir"/complete
  _$op
fi
