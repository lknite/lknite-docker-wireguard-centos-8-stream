# build using official centos 8 stream
FROM quay.io/centos/centos:stream8

# install what is needed in order to compile & use wireguard module
RUN yum -y update && \
        yum -y install net-tools && \
        yum -y install iproute iptables && \
        yum -y install jq qrencode && \
        yum -y install procps kmod git make gcc

# clone the linuxserver docker-wireguard repo to get access to their scripts
RUN cd /tmp; git clone https://github.com/linuxserver/docker-wireguard.git
# install linuxserver docker-wireguard scripts
RUN cp -r /tmp/docker-wireguard/root/* /
# clean up: remove linuxserver docker-wireguard repo
RUN rm -rf /tmp/docker-wireguard

# install wireguard & coredns (copied from linuxserver wireguard)
RUN \
 #mkdir /app && \
 cd /app && \
 echo "**** install wireguard-tools ****" && \
 if [ -z ${WIREGUARD_RELEASE+x} ]; then \
	WIREGUARD_RELEASE=$(curl -sX GET "https://api.github.com/repos/WireGuard/wireguard-tools/tags" \
	| jq -r .[0].name); \
 fi && \
 cd /app && \
 git clone https://git.zx2c4.com/wireguard-linux-compat && \
 git clone https://git.zx2c4.com/wireguard-tools && \
 cd wireguard-tools && \
 git checkout "${WIREGUARD_RELEASE}" && \
 make -C src -j$(nproc) && \
 make -C src install && \
 echo "**** install CoreDNS ****" && \
 COREDNS_VERSION=$(curl -sX GET "https://api.github.com/repos/coredns/coredns/releases/latest" \
	| awk '/tag_name/{print $4;exit}' FS='[""]' | awk '{print substr($1,2); }') && \
 curl -o \
	/tmp/coredns.tar.gz -L \
	"https://github.com/coredns/coredns/releases/download/v${COREDNS_VERSION}/coredns_${COREDNS_VERSION}_linux_amd64.tgz" && \
 tar xf \
	/tmp/coredns.tar.gz -C \
	/app && \
 echo "**** clean up ****" && \
 rm -rf \
	/tmp/* \
	/var/tmp/*

# clean up: remove dependencies needed to compile wireguard (will download again if recompile is necessary)
RUN yum -y remove \
    make gcc \
    elfutils-libelf-devel kernel-devel pkgconfig "@Development Tools" \
    kernel-devel kernel-headers kernel-tools perf linux-firmware

# modify linuxserver wireguard scripts just slightly, so they work with centos-8-stream
RUN sed -i '/^mkdir -p.*/a\
sysctl net.ipv4.ip_forward=1\
' /etc/cont-init.d/30-config

# ip link add dev test type wireguard wasn't failing without wireguard, using modprobe instead
RUN sed -i 's/ip link add dev test type wireguard/modprobe -q wireguard/g' /etc/cont-init.d/30-config
RUN sed -i 's/.*ip link del dev test.*//g' /etc/cont-init.d/30-config

# add initial check for yum, this is how we check if its centos (replaces an if with and if & elseif)
RUN sed -i 's/^  if apt-cache show linux-headers.*/\
  if [[ -f \/usr\/bin\/yum ]]; then\n\
    yum -y update\n\
    yum -y install elfutils-libelf-devel pkgconfig "@Development Tools"\n\
    yum -y install kernel kernel-devel kernel-headers kernel-tools perf linux-firmware\n\
  elif apt-cache show linux-headers-$(uname -r) 2\&\>1 \>\/dev\/null; then\
/g' /etc/cont-init.d/30-config

# abc:abc is erroring, replacing with PUID & PGID
RUN sed -i 's/chown -R abc:abc/chown -R $PUID:$PGID/g' /etc/cont-init.d/30-config

# linuxserver wireguard uses s6 overlay, so we need to also
ADD https://github.com/just-containers/s6-overlay/releases/download/v2.2.0.1/s6-overlay-amd64-installer /tmp/
RUN chmod +x /tmp/s6-overlay-amd64-installer && /tmp/s6-overlay-amd64-installer /

# ports and volumes
EXPOSE 51820/udp

# start wireguard using s6 overlay
ENTRYPOINT ["/init"]

# for debugging
#ENTRYPOINT ["tail", "-f", "/dev/null"]
