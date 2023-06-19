FROM centos

MAINTAINER kevinwkwang@tencent.com

STOPSIGNAL 37


WORKDIR /usr/local/service

COPY ./scripts/*.sh  /root/

# 拷贝程序文件
COPY ./release/  ./

RUN echo "set encoding=utf-8" >> /root/.vimrc && echo "set fileencoding=utf-8" >> /root/.vimrc

# 不要使用CMD/ENTRYPOINT命令设置自己的docker启动命令，因为tlinux基础镜像启动需要CMD ["/usr/sbin/initStart"]，即systemd作为1号守护进程。
# 用户再写CMD/ENTRYPOINT会导致原CMD命令覆盖，导致systemd无法启动
COPY ./scripts/run.sh /etc/kickStart.d/