A wireguard container built for centos-8-stream which takes advantage of the scripts from the linuxserver docker-wireguard project.

LinuxServer docker-wireguard project: https://github.com/linuxserver/docker-wireguard

To use follow the instructions at the docker-wireguard project using the docker image from here instead:
quay.io/lknight/docker-wireguard-centos-8-stream:latest

Note: Initial startup may take quite awhile, 4 minutes +, if the wireguard module is being recompiled.  Be sure to use a volume for the modules folder to avoid having to recompile.

(kubernetes)
Helm installation is available here:
https://github.com/lknite/lknite-helm-charts/tree/main/charts/wireguard-centos-8-stream
