#!/bin/sh -e
#
# build.sh - builds Remmina's VNC plugin with the scroll multiplier patch and
# installs it for the current user (~/.config/remmina/plugins, which Remmina
# loads before the system plugins; no root needed).
#
#   ./build.sh [remmina version]	default: the installed one
#
# Needs: gcc, pkg-config, curl, patch, libgtk-3-dev, libvncserver-dev
#
VERSION=${1:-$(dpkg-query -W -f='${Version}' remmina 2>/dev/null | sed 's/[+-].*//')}
VERSION=${VERSION:-1.4.43}
HERE=$(cd "$(dirname "$0")" && pwd)
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

curl -fsSL "https://gitlab.com/Remmina/Remmina/-/archive/v$VERSION/Remmina-v$VERSION.tar.gz" | tar xz -C "$WORK" --strip-components=1
patch -d "$WORK" -p0 < "$HERE/remmina-vnc-scroll-multiplier.patch"

VNC=$(pkg-config --modversion libvncclient)
cat > "$WORK/config.h" <<END
#define HAVE_SYS_SOCKET_H
#define HAVE_ARPA_INET_H
#define HAVE_NETINET_IN_H
#define HAVE_NETINET_TCP_H
#define HAVE_NETDB_H
#define HAVE_FCNTL_H
#define HAVE_UNISTD_H
#define HAVE_SYS_UN_H
#define HAVE_ERRNO_H
#define VERSION "$VERSION"
#define remmina "remmina"
#define GETTEXT_PACKAGE remmina
#define REMMINA_RUNTIME_LOCALEDIR "/usr/share/locale"
END

gcc -O2 -fPIC -shared -Wall -Wno-deprecated-declarations \
	-DLIBVNC_INT_MAJOR=$(echo $VNC | cut -d. -f1) -DLIBVNC_INT_MINOR=$(echo $VNC | cut -d. -f2) -DLIBVNC_INT_PATCH=$(echo $VNC | cut -d. -f3) \
	-I"$WORK" -I"$WORK/plugins/common" -I"$WORK/plugins" -I"$WORK/src/include" -I"$WORK/src" \
	$(pkg-config --cflags gtk+-3.0 gmodule-2.0 libvncclient) \
	-o "$WORK/remmina-plugin-vnc.so" "$WORK/plugins/vnc/vnc_plugin.c" \
	$(pkg-config --libs gtk+-3.0 gmodule-2.0 libvncclient) -lpthread

mkdir -p "$HOME/.config/remmina/plugins"
cp "$WORK/remmina-plugin-vnc.so" "$HOME/.config/remmina/plugins/"
echo "installed $HOME/.config/remmina/plugins/remmina-plugin-vnc.so (Remmina $VERSION); restart Remmina"
