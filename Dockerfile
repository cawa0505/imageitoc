FROM centos:7
LABEL maintainer="jimmyyen"

RUN groupadd --gid 9999 bbs \
    && useradd -g bbs -s /bin/bash --uid 9999 bbs \
    && rm /etc/localtime \
    && ln -s /usr/share/zoneinfo/Asia/Taipei /etc/localtime

RUN rpm --import http://mirror.centos.org/centos/7/os/x86_64/RPM-GPG-KEY-CentOS-7 \
    && yum update -y    \
    && yum clean all \
    && yum install -y \
                epel-release git python3 \
                gcc   \
                make  \
                patch \
                glibc-devel \
                glibc-devel.i686 \
                libgcc.i686 \
                libstdc++-devel.i686 \
                ncurses-devel.i686 \
                crontabs


USER bbs
ENV HOME=/home/bbs

RUN cd /home/bbs \
    && sh -c "curl -L https://github.com/xeonchen/maplebbs-itoc/archive/5deda091832277d1997489d6572a5415aa7a242f.tar.gz|tar -zxv" \
    && mv maplebbs-itoc-5deda091832277d1997489d6572a5415aa7a242f maplebbs-itoc \
    && cp -r /home/bbs/maplebbs-itoc/bbs /home/

WORKDIR /home/bbs/patch
COPY file/patch-for64bit-Makefile /home/bbs/patch/patch-for64bit-Makefile
COPY file/config_h /home/bbs/src/include/config.h
RUN patch -p1 -d /home/bbs/src </home/bbs/patch/patch-for64bit-Makefile
RUN cd /home/bbs/src && make linux install clean

USER root
ADD ./file/crontab /tmp/crontab
ADD ./file/runbbsd.sh /runbbsd.sh
RUN chmod 0755 /runbbsd.sh

WORKDIR /home/bbs
RUN git clone https://github.com/novnc/websockify.git websockify \
    && cd websockify \
    && pip3 install numpy==1.19 \
    && python3 setup.py install

CMD ["sh","-c","/runbbsd.sh"]

EXPOSE 8888
EXPOSE 46783
