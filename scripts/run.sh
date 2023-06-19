#!/bin/sh

PROJ_NAME="test_springboot_container"
LOG_PATH="/data/log/${PROJ_NAME}"
SRV_PATH="/usr/local/service/${PROJ_NAME}"
BIN_PATH="${SRV_PATH}/${PROJ_NAME}"

is_running()
{
  num=`ps -ef | grep $BIN_PATH | grep -v "grep" | wc -l`
  if [[ ${num} -eq 0 ]]; then
    false; return
  else
    true; return
  fi
}

start()
{
  echo "starting..."
  # 日志软链到/data/log
  if [[ ! -d ${LOG_PATH} ]]; then
      mkdir -p ${LOG_PATH}
  fi
  if [[ ! -d ${SRV_PATH}/log && ! -L ${SRV_PATH}/log ]]; then
      ln -s ${LOG_PATH} ${SRV_PATH}/log
  fi

  # 检查程序是否已经运行
  if is_running ; then
    echo "start fail, program is running"
    exit -1
  fi

  # 运行服务
  ${BIN_PATH} >> ${SRV_PATH}/log/run.log 2>&1 &

  sleep 1

  if is_running ; then
    echo "start success"
  else
    echo "start fail"
  fi
}

prestop()
{
  if ! is_running ; then
    echo "program not running, skip prestop "
    return 0
  fi

  echo "pre stopping..."

  # 发送SIGTERM信号给进程
  ps -ef | grep bin/${PROJ_NAME} | grep -v "grep" | awk '{print $2}' | xargs kill -15

  # 循环探测程序是否退出
  for i in {1..30}
  do
    sleep 3
    if is_running ; then
      echo "program is running, check no.${i} "
    else
      echo "pre stop done"
      break
    fi
  done

  if is_running ; then
    echo "pre stop fail"
  fi
}

stop()
{
  echo "stopping..."
  if is_running ; then
    # 发送SIGKILL信号给进程
    ps -ef | grep bin/${PROJ_NAME} | grep -v "grep" | awk '{print $2}' | xargs kill -9
  fi
  sleep 3
  if ! is_running ; then
    echo "stop success"
  else
    echo "stop fail"
  fi
}

restart()
{
  prestop
  stop
  start
}

# 无参数时，默认为start
if [[ $# -eq 0 ]]
  then
    start
    exit $?
fi
case "$1" in
  "start")
    start;;
  "prestop")
    prestop;;
  "stop")
    stop;;
  "restart")
    restart;;
  *)
    echo "Usage: $0 [start|stop|restart|prestop], default start"
    exit 1;;
esac