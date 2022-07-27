# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7
CROS_WORKON_REPO="https://github.com/FydeOS-for-You-overlays"
CROS_WORKON_COMMIT="0c4bf81db8316f1fcf617c146231e8fe94960ae0"
CROS_WORKON_EGIT_BRANCH="rock-pi4"

CROS_WORKON_PROJECT="kernel-rockchip"
CROS_WORKON_LOCALNAME="/kernel/rockchip-kernel"
CROS_WORKON_INCREMENTAL_BUILD="1"

DEPEND="!sys-kernel/chromeos-kernel-4_4"
RDEPEND="${DEPEND}"

# AFDO_PROFILE_VERSION is the build on which the profile is collected.
# This is required by kernel_afdo.
#
# TODO: Allow different versions for different CHROMEOS_KERNEL_SPLITCONFIGs

# Auto-generated by PFQ, don't modify.
#AFDO_PROFILE_VERSION="R77-12236.0-1559554500"

# Set AFDO_FROZEN_PROFILE_VERSION to freeze the afdo profiles.
# If non-empty, it overrides the value set by AFDO_PROFILE_VERSION.
# Note: Run "ebuild-<board> /path/to/ebuild manifest" afterwards to create new
# Manifest file.
#AFDO_FROZEN_PROFILE_VERSION=""

# This must be inherited *after* EGIT/CROS_WORKON variables defined
inherit cros-workon cros-kernel2

HOMEPAGE="https://github.com/ayufan-rock64/linux-kernel/"
DESCRIPTION="Rockchip Linux Kernel 4.4"
KEYWORDS="*"

#src_compile() {
#	tc-export ${CHOST}-pkg-config
#	cros-kernel2_src_compile PKG_CONFIG="$(tc-getPKG_CONFIG)"
#}

src_install() {
  cros-kernel2_src_install
  local kernel_dir=$(cros-workon_get_build_dir)
  local kernel_arch=${CHROMEOS_KERNEL_ARCH:-$(tc-arch-kernel)}
  local kernel_release=$(kernelrelease)
  local kernel_version=$(kmake -s kernelversion)

  info "Install /boot/dtbs/"
	kmake INSTALL_DTBS_PATH="${D}/boot/dtbs/$(kernelrelease)" dtbs_install

  info "Install ${D}/boot/extlinux.conf"
  cat > "${kernel_dir}/extlinux.conf" <<EOF
menu title Boot Menu
timeout 20
default rockchip-${kernel_release}-debug

label rockchip-${kernel_release}-debug
    kernel /boot/Image-${kernel_release}
    devicetreedir /boot/dtbs/${kernel_release}
    append earlyprintk console=ttyS2,1500000n8 ro root=/dev/\${bootdevice}p\${bootdevice_part} rootfstype=ext4 init=/sbin/init rootwait cros_debug loglevel=7 dm_verity.error_behavior=3 dm_verity.max_bios=-1 dm_verity.dev_wait=0 dm="1 vroot none ro 1, 0 2539520 verity payload=/dev/\${bootdevice}p\${bootdevice_part} hashtree=HASH_DEV hashstart=2539520 alg=sha1 root_hexdigest=a1910fbe4a24a30d19a49b85d2889776251e54e3 salt=c520b38f1057e5bef0aa64c00cd0d2e50662e22bf19771278921f90a35fd616d" vt.global_cursor_default=0 ethaddr=\${ethaddr} serial=\${serial#} cgroup.memory=nokmem cros_legacy panic=0 cma=1524M

label rockchip-${kernel_release}
    kernel /boot/Image-${kernel_release}
    devicetreedir /boot/dtbs/${kernel_release}
    append earlyprintk console=ttyS2,1500000n8 ro root=/dev/\${bootdevice}p\${bootdevice_part} rootfstype=ext4 init=/sbin/init rootwait loglevel=7 dm_verity.error_behavior=3 dm_verity.max_bios=-1 dm_verity.dev_wait=0 dm="1 vroot none ro 1,0 2539520 verity payload=/dev/\${bootdevice}p\${bootdevice_part} hashtree=HASH_DEV hashstart=2539520 alg=sha1 root_hexdigest=a1910fbe4a24a30d19a49b85d2889776251e54e3 salt=c520b38f1057e5bef0aa64c00cd0d2e50662e22bf19771278921f90a35fd616d" vt.global_cursor_default=0 ethaddr=\${ethaddr} serial=\${serial#} cgroup.memory=nokmem cros_legacy panic=0 cma=1024M
EOF

  insinto "/boot/extlinux"
  doins "${kernel_dir}/extlinux.conf"
}
