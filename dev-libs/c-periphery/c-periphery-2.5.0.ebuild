# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="C library for GPIO, LED, PWM, SPI, I2C, MMIO and serial I/O in Linux"
HOMEPAGE="https://github.com/vsergeev/c-periphery"
SRC_URI="https://github.com/vsergeev/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0/$(ver_cut 1-2)"
KEYWORDS="~amd64 ~arm ~arm64"

# The GPIO character-device v2 ABI appeared in 5.10; with older headers
# the build silently falls back to the deprecated sysfs interface.
DEPEND=">=sys-kernel/linux-headers-5.10"

src_configure() {
	# The test programs drive real peripherals and are never installed.
	local mycmakeargs=(
		-DBUILD_TESTS=OFF
	)
	cmake_src_configure
}
