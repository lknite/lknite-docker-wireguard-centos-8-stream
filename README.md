A wireguard container built for centos-8-stream which takes advantage of the scripts from the linuxserver docker-wireguard project.

LinuxServer docker-wireguard project: https://github.com/linuxserver/docker-wireguard

To use follow the instructions at the docker-wireguard project using the docker image from here instead:
quay.io/lknight/docker-wireguard-centos-8-stream:latest

Note: Initial startup may take quite awhile, 4 minutes +, if the wireguard module is being recompiled.  Be sure to use a volume for the modules folder to avoid having to recompile.

(kubernetes)
Helm installation is available here:
https://github.com/lknite/lknite-helm-charts/tree/main/charts/wireguard-centos-8-stream

***

After concern over redhat support of certain features:
https://lists.zx2c4.com/pipermail/wireguard/2022-June/007664.html

The decision was made by the wireguard maintainers to no longer support centos-8-stream:
https://git.zx2c4.com/wireguard-linux-compat/commit/?id=3d3c92b4711b42169137b2ddf42ed4382e2babdf

And so, this effort is being retired.
