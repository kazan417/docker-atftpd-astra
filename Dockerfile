
FROM registry.astralinux.ru/astra/ubi18

RUN <<-EOT sh
	set -eu
	apt-get update
	env DEBIAN_FRONTEND=noninteractive \
		apt-get install -y --no-install-recommends atftpd curl \
		syslinux-common grub-theme-breeze \
		grub-pc-bin grub-efi-ia32-bin grub-efi-amd64-bin grub-efi-arm64-bin \
		-o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"
	apt-get clean && rm -rf /var/lib/apt/lists/* /var/lib/apt/lists/*

	grub-mknetdir --net-directory=/data --subdir=grub --themes=breeze && \
		chown nobody:nogroup /data
	cp /usr/lib/syslinux/memdisk /data/grub
EOT

COPY rootfs/ /

EXPOSE 69/udp

VOLUME /data/disks

HEALTHCHECK --interval=1m --timeout=3s \
  CMD timeout 2 curl -sfo /dev/null 'tftp://127.0.0.1/grub/grub.cfg'

ENTRYPOINT ["/usr/sbin/atftpd"]
CMD ["--daemon", "--no-fork", "--user", "nobody.nogroup", "--logfile", "/dev/stdout", "--port", "69", "/data"]
