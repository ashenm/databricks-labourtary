#!/bin/bash

set -e

online ()
{

  wget --quiet --output-document="/mnt/driver-daemon/jars/log4j12-json-layout-1.0.0.jar" \
    "https://sa-iot.s3.ca-central-1.amazonaws.com/collateral/log4j12-json-layout-1.0.0.jar"

  mkdir --parent $CLOUDWATCH_INSTALLER_DIRECTORY

  wget --quiet --output-document="${CLOUDWATCH_INSTALLER_DIRECTORY}/amazon-cloudwatch-agent.deb" \
    "https://amazoncloudwatch-agent-${AWS_REGION}.s3.${AWS_REGION}.amazonaws.com/debian/$(dpkg --print-architecture)/latest/amazon-cloudwatch-agent.deb"
  wget --quiet --output-document="${CLOUDWATCH_INSTALLER_DIRECTORY}/amazon-cloudwatch-agent.deb.sig" \
    "https://amazoncloudwatch-agent-${AWS_REGION}.s3.${AWS_REGION}.amazonaws.com/debian/$(dpkg --print-architecture)/latest/amazon-cloudwatch-agent.deb.sig"

  CLOUDWATCH_INSTALLER_KEY=$(curl https://amazoncloudwatch-agent-${AWS_REGION}.s3.${AWS_REGION}.amazonaws.com/assets/amazon-cloudwatch-agent.gpg 2>/dev/null| gpg --import 2>&1 |  cut -d: -f2 | grep 'key' | sed -r 's/\s*|key//g')
  CLOUDWATCH_INSTALLER_FINGERPRINT=$(echo "9376 16F3 450B 7D80 6CBD 9725 D581 6730 3B78 9C72" | sed 's/\s//g')

  if ! gpg --fingerprint $CLOUDWATCH_INSTALLER_KEY | sed -r 's/\s//g' | grep -q "${CLOUDWATCH_INSTALLER_FINGERPRINT}"; then
    echo "cloudwatch agent deb gpg key fingerprint is invalid"
    exit 1
  fi

  if ! gpg --verify ${CLOUDWATCH_INSTALLER_DIRECTORY}/amazon-cloudwatch-agent.deb.sig ${CLOUDWATCH_INSTALLER_DIRECTORY}/amazon-cloudwatch-agent.deb; then
    echo "cloudwatch agent signature does not match deb"
    exit 1
  fi

  sudo -H apt-get install --yes ${CLOUDWATCH_INSTALLER_DIRECTORY}/amazon-cloudwatch-agent.deb
}

offline ()
{
  cp --force ${CLOUDWATCH_INSTALLER_DIRECTORY}/artifacts/log4j12-json-layout-1.0.0.jar /mnt/driver-daemon/jars/log4j12-json-layout-1.0.0.jar
  sudo -H apt-get install --yes ${CLOUDWATCH_INSTALLER_DIRECTORY}/artifacts/amazon-cloudwatch-agent-$(uname --machine).deb
}

set -x

AWS_REGION=${AWS_REGION:="ap-southeast-1"}
CLOUDWATCH_INSTALLER_TYPE=${CLOUDWATCH_INSTALLER_TYPE:="offline"}
CLOUDWATCH_INSTALLER_DIRECTORY=${CLOUDWATCH_INSTALLER_DIRECTORY:="/tmp/cloudwatch-agent-installer"}
DEBIAN_FRONTEND=noninteractive

if [ ${CLOUDWATCH_INSTALLER_TYPE} = "online" ]; then
  online
else
  offline
fi

CLUSTER_NAME=${DB_CLUSTER_NAME}
CLUSTER_NAME=${CLUSTER_NAME}-${DB_CLUSTER_ID}

# TODO remove
find /home/ubuntu/databricks/spark/dbconf/ -type f

# configure cloudwatch agent for driver & executor
if  [  ! -z $DB_IS_DRIVER ] && [ $DB_IS_DRIVER = "TRUE" ] ; then
    cat > /tmp/amazon-cloudwatch-agent.json << EOF
{"agent":{"metrics_collection_interval":10,"logfile":"/var/log/amazon-cloudwatch-agent.log","debug":false},"logs":{"logs_collected":{"files":{"collect_list":[{"file_path":"/databricks/driver/logs/log4j-active.log","log_group_name":"/databricks/$CLUSTER_NAME/driver/spark-log","log_stream_name":"databricks-cloudwatch"},{"file_path":"/databricks/driver/logs/stderr","log_group_name":"/databricks/$CLUSTER_NAME/driver/stderr","log_stream_name":"databricks-cloudwatch"},{"file_path":"/databricks/driver/logs/stdout","log_group_name":"/databricks/$CLUSTER_NAME/driver/stdout","log_stream_name":"databricks-cloudwatch"}]}}},"metrics":{"namespace":"$CLUSTER_NAME","metrics_collected":{"statsd":{"service_address":":8125"},"cpu":{"resources":["*"],"measurement":[{"name":"cpu_usage_idle","rename":"DRIVER_CPU_USAGE_IDLE","unit":"Percent"},{"name":"cpu_usage_iowait","rename":"DRIVER_CPU_USAGE_IOWAIT","unit":"Percent"},{"name":"cpu_time_idle","rename":"DRIVER_CPU_TIME_IDLE","unit":"Percent"},{"name":"cpu_time_iowait","rename":"DRIVER_CPU_TIME_IOWAIT","unit":"Percent"}],"totalcpu":true},"disk":{"resources":["/"],"measurement":[{"name":"disk_free","rename":"DRIVER_DISK_FREE","unit":"Gigabytes"},{"name":"disk_inodes_free","rename":"DRIVER_DISK_INODES_FREE","unit":"Count"},{"name":"disk_inodes_total","rename":"DRIVER_DISK_INODES_TOTAL","unit":"Count"},{"name":"disk_inodes_used","rename":"DRIVER_DISK_INODES_USED","unit":"Count"}]},"diskio":{"resources":["*"],"measurement":[{"name":"diskio_iops_in_progress","rename":"DRIVER_DISKIO_IOPS_IN_PROGRESS","unit":"Megabytes"},{"name":"diskio_read_time","rename":"DRIVER_DISKIO_READ_TIME","unit":"Megabytes"},{"name":"diskio_write_time","rename":"DRIVER_DISKIO_WRITE_TIME","unit":"Megabytes"}]},"mem":{"measurement":[{"name":"mem_available","rename":"DRIVER_MEM_AVAILABLE","unit":"Megabytes"},{"name":"mem_total","rename":"DRIVER_MEM_TOTAL","unit":"Megabytes"},{"name":"mem_used","rename":"DRIVER_MEM_USED","unit":"Megabytes"},{"name":"mem_used_percent","rename":"DRIVER_MEM_USED_PERCENT","unit":"Megabytes"},{"name":"mem_available_percent","rename":"DRIVER_MEM_AVAILABLE_PERCENT","unit":"Megabytes"}]},"net":{"resources":["eth0"],"measurement":[{"name":"net_bytes_recv","rename":"DRIVER_NET_BYTES_RECV","unit":"Bytes"},{"name":"net_bytes_sent","rename":"DRIVER_NET_BYTES_SENT","unit":"Bytes"}]}},"append_dimensions":{"InstanceId":"\${aws:InstanceId}"}}}
EOF
  sed -i '/<Appender[^>]*name="publicFile"[^>]*>/,/<\/Appender>/ s/^\(\s*<[^!].*Layout\)/<!-- \1/; s/\/>$/\/> -->/' /home/ubuntu/databricks/spark/dbconf/log4j/driver/log4j2.xml
  sed -i '/<Appender[^>]*name="publicFile"[^>]*>/a\    <JsonLayout compact="true" eventEol="true"/>' /home/ubuntu/databricks/spark/dbconf/log4j/driver/log4j2.xml
else
  cat > /tmp/amazon-cloudwatch-agent.json << EOF
{"agent":{"metrics_collection_interval":10,"logfile":"/var/log/amazon-cloudwatch-agent.log","debug":true},"logs":{"logs_collected":{"files":{"collect_list":[{"file_path":"/databricks/spark/work/*/*/stderr","log_group_name":"/databricks/$CLUSTER_NAME/executor/stderr","log_stream_name":"databricks-cloudwatch"},{"file_path":"/databricks/spark/work/*/*/stdout","log_group_name":"/databricks/$CLUSTER_NAME/executor/stdout","log_stream_name":"databricks-cloudwatch"}]}}},"metrics":{"namespace":"$CLUSTER_NAME","metrics_collected":{"statsd":{"service_address":":8125"},"cpu":{"resources":["*"],"measurement":[{"name":"cpu_usage_idle","rename":"EXEC_CPU_USAGE_IDLE","unit":"Percent"},{"name":"cpu_usage_iowait","rename":"EXEC_CPU_USAGE_IOWAIT","unit":"Percent"},{"name":"cpu_time_idle","rename":"EXEC_CPU_TIME_IDLE","unit":"Percent"},{"name":"cpu_time_iowait","rename":"EXEC_CPU_TIME_IOWAIT","unit":"Percent"}],"totalcpu":true},"disk":{"resources":["/"],"measurement":[{"name":"disk_free","rename":"EXEC_DISK_FREE","unit":"Gigabytes"},{"name":"disk_inodes_free","rename":"EXEC_DISK_INODES_FREE","unit":"Count"},{"name":"disk_inodes_total","rename":"EXEC_DISK_INODES_TOTAL","unit":"Count"},{"name":"disk_inodes_used","rename":"EXEC_DISK_INODES_USED","unit":"Count"}]},"diskio":{"resources":["*"],"measurement":[{"name":"diskio_iops_in_progress","rename":"EXEC_DISKIO_IOPS_IN_PROGRESS","unit":"Megabytes"},{"name":"diskio_read_time","rename":"EXEC_DISKIO_READ_TIME","unit":"Megabytes"},{"name":"diskio_write_time","rename":"EXEC_DISKIO_WRITE_TIME","unit":"Megabytes"}]},"mem":{"measurement":[{"name":"mem_available","rename":"EXEC_MEM_AVAILABLE","unit":"Megabytes"},{"name":"mem_total","rename":"EXEC_MEM_TOTAL","unit":"Megabytes"},{"name":"mem_used","rename":"EXEC_MEM_USED","unit":"Megabytes"},{"name":"mem_used_percent","rename":"EXEC_MEM_USED_PERCENT","unit":"Megabytes"},{"name":"mem_available_percent","rename":"EXEC_MEM_AVAILABLE_PERCENT","unit":"Megabytes"}]},"net":{"resources":["eth0"],"measurement":[{"name":"net_bytes_recv","rename":"EXEC_NET_BYTES_RECV","unit":"Bytes"},{"name":"net_bytes_sent","rename":"EXEC_NET_BYTES_SENT","unit":"Bytes"}]}},"append_dimensions":{"InstanceId":"\${aws:InstanceId}"}}}
EOF
  sed -i '/<Appender[^>]*name="console"[^>]*>/,/<\/Appender>/ s/^\(\s*<[^!].*Layout\)/<!-- \1/; s/\/>$/\/> -->/' /home/ubuntu/databricks/spark/dbconf/log4j/executor/log4j2.xml
  sed -i '/<Appender[^>]*name="console"[^>]*>/a\    <JsonLayout compact="true" eventEol="true"/>' /home/ubuntu/databricks/spark/dbconf/log4j/executor/log4j2.xml
fi

sudo sed -i '/^driver.sink.ganglia.class/,+4 s/^/#/g' /databricks/spark/conf/metrics.properties
sudo bash -c "cat <<EOF >> /databricks/spark/conf/metrics.properties
*.sink.statsd.class=org.apache.spark.metrics.sink.StatsdSink
*.sink.statsd.host=localhost
*.sink.statsd.port=8125
*.sink.statsd.prefix=spark
master.source.jvm.class=org.apache.spark.metrics.source.JvmSource
worker.source.jvm.class=org.apache.spark.metrics.source.JvmSource
driver.source.jvm.class=org.apache.spark.metrics.source.JvmSource
executor.source.jvm.class=org.apache.spark.metrics.source.JvmSource
EOF"

sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/tmp/amazon-cloudwatch-agent.json -s
sudo systemctl enable amazon-cloudwatch-agent

/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a status -m ec2
