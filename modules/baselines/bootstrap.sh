#!/usr/bin/env sh

set -e

SELF=$(realpath $0)
ROOT=$(dirname $SELF)
DRIVERS="${ROOT}/drivers"

JAR_ORACLE_JDBC_VERSION="23.26.3.0.0"

curl --output "${DRIVERS}/jar/ojdbc11-${JAR_ORACLE_JDBC_VERSION}.jar" \
    --url "https://repo1.maven.org/maven2/com/oracle/database/jdbc/ojdbc11/${JAR_ORACLE_JDBC_VERSION}/ojdbc11-${JAR_ORACLE_JDBC_VERSION}.jar"
