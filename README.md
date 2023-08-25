[aguslr/docker-atftpd][1]
=========================

[![docker-pulls](https://img.shields.io/docker/pulls/aguslr/atftpd)](https://hub.docker.com/r/aguslr/atftpd) [![image-size](https://img.shields.io/docker/image-size/aguslr/atftpd/latest)](https://hub.docker.com/r/aguslr/atftpd)


This *Docker* image sets up *aftpd* inside a docker container.

> **[atftpd][2]** is a client/server implementation of the TFTP protocol that
> implements RFCs [1350][3], [2090][4], [2347][5], [2348][6], [2349][7] and
> [7440][8].


Installation
------------

To use *docker-atftpd*, follow these steps:

1. Clone and start the container:

       docker run -p 69:69/udp \
         docker.io/aguslr/atftpd:latest

2. Configure your *PXE* server to connect to your *TFTP* server's IP address
   (e.g. `192.168.1.10`). For example, this would be the [configuration for
   *dnsmasq*][14]:

       dhcp-match=set:bios,option:client-arch,0
       dhcp-match=set:efi32,option:client-arch,6
       dhcp-match=set:efi64,option:client-arch,7
       dhcp-match=set:efi64,option:client-arch,9
       dhcp-boot=tag:bios,grub/i386-pc/core.0,tfp.lan,192.168.1.10
       dhcp-boot=tag:efi32,grub/i386-efi/core.efi,tfp.lan,192.168.1.10
       dhcp-boot=tag:efi64,grub/x86_64-efi/core.efi,tfp.lan,192.168.1.10


#### Custom GRUB entries

To configure additional GRUB entries, we can add these to a `custom.cfg` file
(e.g. for [nextboot.xyz][13]):

    menuentry --hotkey=n "netboot.xyz" {
      if [ "$_EFI" == true ]; then
        if [ "$_ARM64" == true ]; then
          chainloader disks/netboot.xyz/boot-arm64.efi
        else
          chainloader disks/netboot.xyz/boot.efi
        fi
      else
        linux16 grub/memdisk iso raw
        initrd16 disks/netboot.xyz/boot.iso
      fi
    }

We would have to copy the necessary image files into the `./disks` directory so
we can go ahead and mount the volumes as follows:

    docker run -p 69:69/udp \
      -v "${PWD}"/disks:/data/disks \
      -v "${PWD}"/custom.cfg:/data/grub/custom.cfg \
      docker.io/aguslr/atftpd:latest


Build locally
-------------

Instead of pulling the image from a remote repository, you can build it locally:

1. Clone the repository:

       git clone https://github.com/aguslr/docker-atftpd.git

2. Change into the newly created directory and use `docker-compose` to build and
   launch the container:

       cd docker-atftpd && docker-compose up --build -d


References
----------

- [TFTP - Debian Wiki][9]
- [TFTP - ArchWiki][10]
- [GitHub - csclabs/atftpd: Docker container for atftpd][11]
- [PXE (with grub2) — Linux Guide and Hints][12]


[1]:  https://github.com/aguslr/docker-atftpd
[2]:  https://sourceforge.net/projects/atftp/
[3]:  https://www.rfc-editor.org/rfc/rfc1350
[4]:  https://www.rfc-editor.org/rfc/rfc2090
[5]:  https://www.rfc-editor.org/rfc/rfc2347
[6]:  https://www.rfc-editor.org/rfc/rfc2348
[7]:  https://www.rfc-editor.org/rfc/rfc2349
[8]:  https://www.rfc-editor.org/rfc/rfc7440
[9]:  https://wiki.debian.org/TFTP
[10]: https://wiki.archlinux.org/title/TFTP
[11]: https://github.com/csclabs/atftpd
[12]: https://linuxguideandhints.com/el/pxeboot.html
[13]: https://github.com/netbootxyz/netboot.xyz
[14]: https://wiki.archlinux.org/title/dnsmasq#PXE_server
