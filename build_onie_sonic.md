# 1.环境准备

​	安装ubuntu server 20.04（带ssh-server)
​	（注：ubuntu 22.04会出错）

在deepin20.7上编译，已经跑到了编译docker的阶段，但磁盘空间不足了，估计没问题。ubuntu22.04可能也能编译通过，可能是网络下载出错了导致编译错误，以后有时间在验证。



​	安装zsh/oh-my-zsh（zsh-autosuggestions, zsh-highlighting)
​	准备环境

```
sudo apt install -y python3-pip git vim docker.io 
sudo pip3 install j2cli
sudo modprobe overlay
sudo adduser $USER docker
```

​	重新登录



# 2.编译onie

  	git config --global user.email "wangwei@qq.com"
  	git config --global user.name "wangwei"
  	git clone -b evb_8t_rel https://github.com/clounix/onie.git
  	cd onie
  	./build_env
  	make -j40 MACHINEROOT=../machine/clounix/ MACHINE=clounix_clx8000_48c8d all
  	注意：最后这个make过程需要多执行几次，最后会在build/image目录下生成onie-recovery-xxx.iso，整个编译过程会持续1个小时左右。

# 3.编译clounix提供的sonic		

```
编译sonic（注意：一定要用VPN软件，否则大量的包下载不下来，会出现各种各样的错误）
git config --global http.proxy http://10.211.55.2:1087
git config --global https.proxy http://10.211.55.2:1087
git clone -b evb_8t_rel https://github.com/clounix/sonic-buildimage.git
cd sonic-buildimage
http_proxy=http://10.211.55.2:1087 https_proxy=http://10.211.55.2:1087 make init
注意：Switch-SDK-drivers太大，clone的时候可能会出错，用下面的方法解决：
	sudo apt install gnutls-bin
	git config --global http.sslVerify false
	git config --global http.postBuffer 1048576000
http_proxy=http://10.211.55.2:1087 https_proxy=http://10.211.55.2:1087 make configure PLATFORM=clounix
http_proxy=http://10.211.55.2:1087 https_proxy=http://10.211.55.2:1087 make target/sonic-clounix.bin
```

注意：第一次编译过程会持续大几个小时，找个网速快的地方，做好顺利编译1-2天的心理准备.
**https_proxy的后面一定要用http://，否则python的ctypesgen包下载的时候会报ssl错误**

# 4.问题

-   整个三个编译过程严重依赖外网（vpn）和带宽
-   在虚拟机（4核CPU，4G内存）上编译（make target)需要很长时间，内核就编了1个多小时，整个过程得半天。
-   烧写到设备并验证需要不短时间，需要还是想办法编译成vs版本，在虚拟交换机上验证
-   修改代码，sonic-buildimage官网和clounix的都不能提交

# 5.编译vs版本

## 5.1 编译

```
make init/make clean
make configure PLATFORM=vs
make target/sonic-vs.img.gz
```

注意：这些make命令前还是需要加上http_proxy。

## 5.2 解压缩

```
gunzip sonic-vs.img.gz
```

## 5.3 安装依赖库

```bsh
sudo apt install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils
```

## 5.4 启动sonic-vs

```
qemu-system-x86_64 -machine q35 -m 1024 -smp 2 -hda ~/sonic-buildimage/target/sonic-vs.img \
  -nographic -netdev user,id=sonic0,hostfwd=tcp::5555-:22 \
  -device e1000,netdev=sonic0
```

```
                             GNU GRUB  version 2.02

 ┌────────────────────────────────────────────────────────────────────────────┐
 │*SONiC-OS-evb_8t_rel.0-61424bdae                                            │ 
 │ ONIE                                                                       │
 │                                                                            │
 │                                                                            │
 │                                                                            │
 │                                                                            │
 │                                                                            │
 │                                                                            │
 │                                                                            │
 │                                                                            │
 │                                                                            │
 │                                                                            │
 │                                                                            │ 
 └────────────────────────────────────────────────────────────────────────────┘

      Use the ↑ and ↓ keys to select which entry is highlighted.          
      Press enter to boot the selected OS, `e' to edit the commands 
      
      
      
Loading SONiC-OS OS kernel ...Loading SONiC-OS OS kernel ..
.
Loading SONiC-OS OS initial ramdisk ...Loading SONiC-OS OS initial ramdisk ..
.
[    1.039990] Spectre V2 : Spectre mitigation: LFENCE not serializing, switching to generic retpoline
tune2fs 1.44.5 (15-Dec-2018)
Setting reserved blocks percentage to 0% (0 blocks)
Setting reserved blocks count to 0
[   18.784023] rc.local[337]: + grep build_version
[   18.906323] rc.local[338]: + sed -e s/build_version: //g;s/'//g
[   19.003917] rc.local[336]: + cat /etc/sonic/sonic_version.yml
[   19.952138] rc.local[326]: + SONIC_VERSION=evb_8t_rel.0-61424bdae
[   19.954455] rc.local[326]: + FIRST_BOOT_FILE=/host/image-evb_8t_rel.0-61424bdae/platform/firsttime
[   19.967084] rc.local[326]: + SONIC_CONFIG_DIR=/host/image-evb_8t_rel.0-61424bdae/sonic-config
[   20.013749] rc.local[326]: + SONIC_ENV_FILE=/host/image-evb_8t_rel.0-61424bdae/sonic-config/sonic-environment
[   20.061616] rc.local[326]: + [ -d /host/image-evb_8t_rel.0-61424bdae/sonic-config -a -f /host/image-evb_8t_rel.0-61424bdae/sonic-config/sonic-environment ]
[   20.077718] rc.local[326]: + logger SONiC version evb_8t_rel.0-61424bdae starting up...
[   20.417119] rc.local[326]: + grub_installation_needed=
[   20.421825] rc.local[326]: + [ ! -e /host/machine.conf ]
[   20.437643] rc.local[326]: + . /host/machine.conf
[   20.453774] rc.local[326]: + onie_arch=x86_64
[   20.463553] rc.local[326]: + onie_bin=
[   20.474820] rc.local[326]: + onie_boot_reason=install
[   20.487874] rc.local[326]: + onie_build_date=2018-11-17T04:18+00:00
[   20.497826] rc.local[326]: + onie_build_machine=kvm_x86_64
[   20.511775] rc.local[326]: + onie_build_platform=x86_64-kvm_x86_64-r0
[   20.518529] rc.local[326]: + onie_config_version=1
[   20.538150] rc.local[326]: + onie_dev=/dev/vda2
[   20.553214] rc.local[326]: + onie_disco_boot_reason=install
[   20.563150] rc.local[326]: + onie_disco_dns=10.0.2.3
[   20.577991] rc.local[326]: + onie_disco_interface=eth0
[   20.584389] rc.local[326]: + onie_disco_ip=10.0.2.15
[   20.597833] rc.local[326]: + onie_disco_lease=86400
[   20.602093] rc.local[326]: + onie_disco_mask=24
[   20.617431] rc.local[326]: + onie_disco_opt53=05
[   20.618933] rc.local[326]: + onie_disco_router=10.0.2.2
[   20.621174] rc.local[326]: + onie_disco_serverid=10.0.2.2
[   20.637434] rc.local[326]: + onie_disco_siaddr=10.0.2.2
[   20.649523] rc.local[326]: + onie_disco_subnet=255.255.255.0
[   20.654612] rc.local[326]: + onie_exec_url=file://dev/vdb/onie-installer.bin
[   20.661811] rc.local[326]: + onie_firmware=auto
[   20.663370] rc.local[326]: + onie_grub_image_name=shimx64.efi
[   20.669550] rc.local[326]: + onie_initrd_tmp=/
[   20.701484] rc.local[326]: + onie_installer=/var/tmp/installer
[   20.708658] rc.local[326]: + onie_kernel_version=4.9.95
[   20.721387] rc.local[326]: + onie_local_parts=
[   20.736157] rc.local[326]: + onie_machine=kvm_x86_64
[   20.741486] rc.local[326]: + onie_machine_rev=0
[   20.754553] rc.local[326]: + onie_neighs=[fe80::2-eth0],
[   20.759333] rc.local[326]: + onie_partition_type=gpt
[   20.777409] rc.local[326]: + onie_platform=x86_64-kvm_x86_64-r0
[   20.782774] rc.local[326]: + onie_root_dir=/mnt/onie-boot/onie
[   20.793232] rc.local[326]: + onie_secure_boot=yes
[   20.812089] rc.local[326]: + onie_skip_ethmgmt_macs=yes
[   20.814773] rc.local[326]: + onie_switch_asic=qemu
[   20.821786] rc.local[326]: + onie_uefi_arch=x64
[   20.842270] rc.local[326]: + onie_uefi_boot_loader=shimx64.efi
[   20.853620] rc.local[326]: + onie_vendor_id=42623
[   20.865642] rc.local[326]: + onie_version=master-201811170418
[   20.878234] rc.local[326]: + program_console_speed
[   20.943968] rc.local[360]: + cat /proc/cmdline
[   20.984099] rc.local[361]: + grep -Eo console=ttyS[0-9]+,[0-9]+
[   21.025697] rc.local[362]: + cut -d , -f2
[   21.301235] rc.local[326]: + speed=115200
[   21.302854] rc.local[326]: + [ -z 115200 ]
[   21.305235] rc.local[326]: + CONSOLE_SPEED=115200
[   21.336715] rc.local[369]: + grep agetty /lib/systemd/system/serial-getty@.service
[   21.353521] rc.local[370]: + grep keep-baud
[   21.685390] rc.local[326]: + [ 1 = 0 ]
[   21.687635] rc.local[326]: + sed -i s|u' .* %I|u' 115200 %I|g /lib/systemd/system/serial-getty@.service
[   21.932100] rc.local[326]: + systemctl daemon-reload
[   24.386477] rc.local[326]: + [ -f /host/image-evb_8t_rel.0-61424bdae/platform/firsttime ]
[   24.444321] rc.local[326]: + [ -f /var/log/fsck.log.gz ]
[   24.476772] rc.local[393]: + gunzip -d -c /var/log/fsck.log.gz
[   24.497046] rc.local[394]: + logger -t FSCK
[   24.701924] rc.local[326]: + rm -f /var/log/fsck.log.gz
[   24.855476] rc.local[326]: + exit 0

Debian GNU/Linux 10 sonic ttyS0

sonic login: 

```

可以正常启动，但是登录用admin/YourPaSsWoRd或admin/admin登录不上去？

# 6.编译自己维护的sonic

~~为了修改sonic里面的代码，把sonic-buildimage.git中的代码（删除.git目录）提交到~~

~~https://gitee.com/wangweif1976/sonic.git~~

~~这条路不通，这种方式得到的代码编译出问题了。~~

用官方的方法，从github上创建fork自己的仓库，**https://github.com/wangweif/sonic-buildimage.git**

另外为了方便的阅读和修改代码，重新安装了个ubuntu 20.04 desktop虚拟机，可以用vscode修改代码（用ssh访问还是不方便）

```
git clone -b evb_8t_rel https://github.com/wangweif/sonic-buildimage.git
cd sonic
http_proxy=http://10.211.55.2:1087 https_proxy=http://10.211.55.2:1087 make init
http_proxy=http://10.211.55.2:1087 https_proxy=http://10.211.55.2:1087 make configure PLATFORM=clounix
http_proxy=http://10.211.55.2:1087 https_proxy=http://10.211.55.2:1087 make target/sonic-clounix.bin
```





# 参考

用make list命令，可以看到所有的可编译的target（和make configure的配置有关，下面的列表是

make configure PLATFORM=vs 配置命令生成的）

```
target/files/buster/configdb-load.sh
target/files/buster/arp_update
target/files/buster/arp_update_vars.j2
target/files/buster/buffers_config.j2
target/files/buster/qos_config.j2
target/files/buster/supervisor-proc-exit-listener
target/files/buster/sysctl-net.conf
target/files/buster/update_chassisdb_config
target/files/buster/swss_vars.j2
target/files/buster/copp_cfg.j2
target/files/buster/container
target/files/buster/container_startup.py
target/files/buster/remote_ctr.config.json
target/files/buster/ctrmgrd.service
target/debs/buster/phy-credo_1.0_amd64.deb
target/files/buster/onie-recovery-x86_64-kvm_x86_64-r0.iso
target/files/buster/ixgbe.ko
target/files/buster/sonic_version.yml
target/debs/buster/initramfs-tools_0.133_all.deb
target/debs/buster/lm-sensors_3.5.0-3_amd64.deb
target/debs/buster/libteam5_1.30-1_amd64.deb
target/debs/buster/libnl-3-200_3.5.0-1_amd64.deb
target/debs/buster/sonic-device-data_1.0-1_all.deb
target/debs/buster/libsnmp-base_5.7.3+dfsg-5_all.deb
target/debs/buster/libmpdec2_2.4.2-2_amd64.deb
target/debs/buster/libtac2_1.4.1-1_amd64.deb
target/debs/buster/libnss-tacplus_1.0.4-1_amd64.deb
target/debs/buster/ethtool_5.9-1_amd64.deb
target/debs/buster/monit_5.20.0-6_amd64.deb
target/debs/buster/kdump-tools_1.6.1-1_all.deb
target/debs/buster/smartmontools_6.6-1_amd64.deb
target/debs/buster/socat_1.7.3.1-2+deb9u1_amd64.deb
target/debs/buster/ifupdown2_1.2.8-1_all.deb
target/debs/buster/bash_4.3-14_amd64.deb
target/debs/buster/lldpd_1.0.4-1_amd64.deb
target/debs/buster/libhiredis0.14_0.14.0-3~bpo9+1_amd64.deb
target/debs/buster/openssh-server_7.9p1-10+deb10u2_amd64.deb
target/debs/buster/linux-headers-4.19.0-12-2-common_4.19.152-1_all.deb
target/debs/buster/iproute2_4.9.0-1_amd64.deb
target/debs/buster/iptables_1.8.2-4_amd64.deb
target/debs/buster/libthrift-0.11.0_0.11.0-4_amd64.deb
target/debs/buster/libyang1_1.0.184-2_amd64.deb
target/debs/buster/frr_7.5.1-sonic-0_amd64.deb
target/debs/buster/systemd-sonic-generator_1.0.0_amd64.deb
target/debs/buster/libyang_1.0.73_amd64.deb
target/debs/buster/ntp_4.2.8p12+dfsg-4+deb10u2_amd64.deb
target/debs/buster/isc-dhcp-relay_4.4.1-2_amd64.deb
target/debs/buster/libthrift-0.13.0_0.13.0-6_amd64.deb
target/debs/buster/hsflowd_2.0.32-1_amd64.deb
target/debs/buster/sflowtool_5.04_amd64.deb
target/debs/buster/psample_1.1-1_amd64.deb
target/debs/buster/sonic-mgmt-framework_1.0-01_amd64.deb
target/debs/buster/sonic-host-services-data_1.0-1_all.deb
target/debs/buster/sonic-telemetry_0.1_amd64.deb
target/debs/buster/gobgp_1.16-01_amd64.deb
target/debs/buster/iccpd_0.0.5_amd64.deb
target/debs/buster/python-ptf_0.9-1_all.deb
target/debs/buster/sonic-mgmt-common_1.0.0_amd64.deb
target/debs/buster/swss_1.0.0_amd64.deb
target/debs/buster/sonic-rest-api_1.0.1_amd64.deb
target/debs/buster/sonic-dhcpmon_1.0.0-0_amd64.deb
target/debs/buster/sonic-ztp_1.0.0_all.deb
target/debs/buster/sonic-dhcp6relay_1.0.0-0_amd64.deb
target/debs/buster/libsairedis_1.0.0_amd64.deb
target/debs/buster/sonic-utilities-data_1.0-1_all.deb
target/debs/buster/sonic-linkmgrd_1.0.0-1_amd64.deb
target/debs/buster/libswsscommon_1.0.0_amd64.deb
target/debs/buster/sonic-platform-pddf_1.1_amd64.deb
target/debs/buster/libsaithrift-dev_0.9.4_amd64.deb
target/debs/buster/sonic-mgmt-framework-dbg_1.0-01_amd64.deb
target/debs/buster/iccpd-dbg_0.0.5_amd64.deb
target/debs/buster/lm-sensors-dbgsym_3.5.0-3_amd64.deb
target/debs/buster/fancontrol_3.5.0-3_all.deb
target/debs/buster/libsensors5_3.5.0-3_amd64.deb
target/debs/buster/libsensors5-dbgsym_3.5.0-3_amd64.deb
target/debs/buster/sensord_3.5.0-3_amd64.deb
target/debs/buster/sensord-dbgsym_3.5.0-3_amd64.deb
target/debs/buster/libteam5-dbgsym_1.30-1_amd64.deb
target/debs/buster/libteam-dev_1.30-1_amd64.deb
target/debs/buster/libteamdctl0_1.30-1_amd64.deb
target/debs/buster/libteamdctl0-dbgsym_1.30-1_amd64.deb
target/debs/buster/libteam-utils_1.30-1_amd64.deb
target/debs/buster/libteam-utils-dbgsym_1.30-1_amd64.deb
target/debs/buster/libnl-3-dev_3.5.0-1_amd64.deb
target/debs/buster/libnl-genl-3-200_3.5.0-1_amd64.deb
target/debs/buster/libnl-genl-3-dev_3.5.0-1_amd64.deb
target/debs/buster/libnl-route-3-200_3.5.0-1_amd64.deb
target/debs/buster/libnl-route-3-dev_3.5.0-1_amd64.deb
target/debs/buster/libnl-nf-3-200_3.5.0-1_amd64.deb
target/debs/buster/libnl-nf-3-dev_3.5.0-1_amd64.deb
target/debs/buster/libnl-cli-3-200_3.5.0-1_amd64.deb
target/debs/buster/libnl-cli-3-dev_3.5.0-1_amd64.deb
target/debs/buster/sonic-mgmt-common-codegen_1.0.0_amd64.deb
target/debs/buster/swss-dbg_1.0.0_amd64.deb
target/debs/buster/snmptrapd_5.7.3+dfsg-5_amd64.deb
target/debs/buster/snmp_5.7.3+dfsg-5_amd64.deb
target/debs/buster/snmpd_5.7.3+dfsg-5_amd64.deb
target/debs/buster/snmp-dbgsym_5.7.3+dfsg-5_amd64.deb
target/debs/buster/snmpd-dbgsym_5.7.3+dfsg-5_amd64.deb
target/debs/buster/libsnmp30_5.7.3+dfsg-5_amd64.deb
target/debs/buster/libsnmp30-dbg_5.7.3+dfsg-5_amd64.deb
target/debs/buster/libsnmp-dev_5.7.3+dfsg-5_amd64.deb
target/debs/buster/libsnmp-perl_5.7.3+dfsg-5_amd64.deb
target/debs/buster/tkmib_5.7.3+dfsg-5_all.deb
target/debs/buster/libmpdec-dev_2.4.2-2_amd64.deb
target/debs/buster/libtac-dev_1.4.1-1_amd64.deb
target/debs/buster/monit-dbgsym_5.20.0-6_amd64.deb
target/debs/buster/sonic-dhcpmon-dbgsym_1.0.0-0_amd64.deb
target/debs/buster/liblldpctl-dev_1.0.4-1_amd64.deb
target/debs/buster/lldpd-dbgsym_1.0.4-1_amd64.deb
target/debs/buster/libhiredis-dev_0.14.0-3~bpo9+1_amd64.deb
target/debs/buster/libhiredis0.14-dbgsym_0.14.0-3~bpo9+1_amd64.deb
target/debs/buster/linux-headers-4.19.0-12-2-amd64_4.19.152-1_amd64.deb
target/debs/buster/linux-image-4.19.0-12-2-amd64-unsigned_4.19.152-1_amd64.deb
target/debs/buster/sonic-dhcp6relay-dbgsym_1.0.0-0_amd64.deb
target/debs/buster/libip4tc0_1.8.2-4_amd64.deb
target/debs/buster/libip6tc0_1.8.2-4_amd64.deb
target/debs/buster/libiptc0_1.8.2-4_amd64.deb
target/debs/buster/libxtables12_1.8.2-4_amd64.deb
target/debs/buster/libthrift-dev_0.11.0-4_amd64.deb
target/debs/buster/python-thrift_0.11.0-4_amd64.deb
target/debs/buster/thrift-compiler_0.11.0-4_amd64.deb
target/debs/buster/libyang-dev_1.0.184-2_amd64.deb
target/debs/buster/libyang1-dbgsym_1.0.184-2_amd64.deb
target/debs/buster/libyang-cpp1_1.0.184-2_amd64.deb
target/debs/buster/libyang-cpp-dev_1.0.184-2_amd64.deb
target/debs/buster/libyang-cpp1-dbgsym_1.0.184-2_amd64.deb
target/debs/buster/yang-tools_1.0.184-2_all.deb
target/debs/buster/libyang-tools_1.0.184-2_amd64.deb
target/debs/buster/libyang-tools-dbgsym_1.0.184-2_amd64.deb
target/debs/buster/libsairedis-dev_1.0.0_amd64.deb
target/debs/buster/libsaivs_1.0.0_amd64.deb
target/debs/buster/libsaivs-dev_1.0.0_amd64.deb
target/debs/buster/libsaimetadata_1.0.0_amd64.deb
target/debs/buster/libsaimetadata-dev_1.0.0_amd64.deb
target/debs/buster/libsairedis-dbg_1.0.0_amd64.deb
target/debs/buster/libsaivs-dbg_1.0.0_amd64.deb
target/debs/buster/libsaimetadata-dbg_1.0.0_amd64.deb
target/debs/buster/libyang-dev_1.0.73_amd64.deb
target/debs/buster/libyang-dbg_1.0.73_amd64.deb
target/debs/buster/libyang-cpp_1.0.73_amd64.deb
target/debs/buster/python3-yang_1.0.73_amd64.deb
target/debs/buster/python2-yang_1.0.73_amd64.deb
target/debs/buster/isc-dhcp-relay-dbgsym_4.4.1-2_amd64.deb
target/debs/buster/libthrift-dev_0.13.0-6_amd64.deb
target/debs/buster/python3-thrift_0.13.0-6_amd64.deb
target/debs/buster/thrift-compiler_0.13.0-6_amd64.deb
target/debs/buster/hsflowd-dbg_2.0.32-1_amd64.deb
target/debs/buster/sonic-linkmgrd-dbgsym_1.0.0-1_amd64.deb
target/debs/buster/libswsscommon-dev_1.0.0_amd64.deb
target/debs/buster/python-swsscommon_1.0.0_amd64.deb
target/debs/buster/python3-swsscommon_1.0.0_amd64.deb
target/debs/buster/libswsscommon-dbg_1.0.0_amd64.deb
target/debs/buster/syncd-vs_1.0.0_amd64.deb
target/debs/buster/syncd-vs-dbg_1.0.0_amd64.deb
target/debs/buster/initramfs-tools-core_0.133_all.deb
target/debs/buster/libpam-tacplus_1.4.1-1_amd64.deb
target/debs/buster/ethtool-dbgsym_5.9-1_amd64.deb
target/debs/buster/frr-pythontools_7.5.1-sonic-0_all.deb
target/debs/buster/frr-dbgsym_7.5.1-sonic-0_amd64.deb
target/debs/buster/frr-snmp_7.5.1-sonic-0_amd64.deb
target/debs/buster/frr-snmp-dbgsym_7.5.1-sonic-0_amd64.deb
target/debs/buster/python-saithrift_0.9.4_amd64.deb
target/debs/buster/saiserver_0.9.4_amd64.deb
target/debs/buster/saiserver-dbg_0.9.4_amd64.deb
target/python-wheels/sonic_d-2.0.0-py3-none-any.whl
target/python-wheels/scapy-2.4.5-py2.py3-none-any.whl
target/python-wheels/sonic_ycabled-1.0-py3-none-any.whl
target/python-wheels/system_health-1.0-py3-none-any.whl
target/python-wheels/sonic_yang_models-1.0-py3-none-any.whl
target/python-wheels/asyncsnmp-2.1.0-py3-none-any.whl
target/python-wheels/sonic_ctrmgrd-1.0.0-py3-none-any.whl
target/python-wheels/sonic_frr_mgmt_framework-1.0-py3-none-any.whl
target/python-wheels/sonic_py_common-1.0-py2-none-any.whl
target/python-wheels/sonic_py_common-1.0-py3-none-any.whl
target/python-wheels/sonic_bgpcfgd-1.0-py3-none-any.whl
target/python-wheels/sonic_xcvrd-1.0-py2-none-any.whl
target/python-wheels/sonic_xcvrd-1.0-py3-none-any.whl
target/python-wheels/sonic_thermalctld-1.0-py2-none-any.whl
target/python-wheels/sonic_thermalctld-1.0-py3-none-any.whl
target/python-wheels/sonic_config_engine-1.0-py2-none-any.whl
target/python-wheels/sonic_config_engine-1.0-py3-none-any.whl
target/python-wheels/swsssdk-2.0.1-py2-none-any.whl
target/python-wheels/sonic_psud-1.0-py2-none-any.whl
target/python-wheels/sonic_psud-1.0-py3-none-any.whl
target/python-wheels/sonic_host_services-1.0-py3-none-any.whl
target/python-wheels/sonic_chassisd-1.0-py3-none-any.whl
target/python-wheels/redis_dump_load-1.1-py2-none-any.whl
target/python-wheels/sonic_syseepromd-1.0-py2-none-any.whl
target/python-wheels/sonic_syseepromd-1.0-py3-none-any.whl
target/python-wheels/sonic_ledd-1.1-py2-none-any.whl
target/python-wheels/sonic_ledd-1.1-py3-none-any.whl
target/python-wheels/swsssdk-2.0.1-py3-none-any.whl
target/python-wheels/sonic_platform_common-1.0-py2-none-any.whl
target/python-wheels/sonic_platform_common-1.0-py3-none-any.whl
target/python-wheels/sonic_yang_mgmt-1.0-py3-none-any.whl
target/python-wheels/redis_dump_load-1.1-py3-none-any.whl
target/python-wheels/sonic_pcied-1.0-py2-none-any.whl
target/python-wheels/sonic_pcied-1.0-py3-none-any.whl
target/python-wheels/sonic_utilities-1.2-py3-none-any.whl
target/python-wheels/sonic_platform_pddf_common-1.0-py2-none-any.whl
target/python-wheels/sonic_platform_pddf_common-1.0-py3-none-any.whl
target/docker-config-engine.gz
target/docker-database.gz
target/docker-mux.gz
target/docker-sflow.gz
target/docker-swss-layer-buster.gz
target/docker-dhcp-relay.gz
target/docker-snmp.gz
target/docker-sonic-telemetry.gz
target/docker-fpm-frr.gz
target/docker-orchagent.gz
target/docker-sonic-mgmt-framework.gz
target/docker-lldp.gz
target/docker-platform-monitor.gz
target/docker-router-advertiser.gz
target/docker-config-engine-buster.gz
target/docker-base-buster.gz
target/docker-nat.gz
target/docker-teamd.gz
target/docker-base.gz
target/docker-sonic-vs.gz
target/docker-syncd-vs.gz
target/docker-gbsyncd-vs.gz
target/docker-ptf-sai.gz
target/docker-database-dbg.gz
target/docker-mux-dbg.gz
target/docker-sflow-dbg.gz
target/docker-dhcp-relay-dbg.gz
target/docker-snmp-dbg.gz
target/docker-sonic-telemetry-dbg.gz
target/docker-fpm-frr-dbg.gz
target/docker-orchagent-dbg.gz
target/docker-sonic-mgmt-framework-dbg.gz
target/docker-lldp-dbg.gz
target/docker-platform-monitor-dbg.gz
target/docker-router-advertiser-dbg.gz
target/docker-nat-dbg.gz
target/docker-teamd-dbg.gz
target/docker-syncd-vs-dbg.gz
target/docker-gbsyncd-vs-dbg.gz
target/sonic-vs.bin
target/sonic-vs.img.gz
target/sonic-vs.raw
```


