#!/bin/sh

VERSION=1.0.1

TAR=tar
command -v bsdtar >/dev/null && TAR=bsdtar
URL="https://github.com/freddylist/xtools-extra/archive/refs/tags/v${VERSION}.tar.gz"
FILE="xtools-extra.tar.gz"

mkdir -p xtools-extra

if command -v wget >/dev/null; then
	wget -q -O "$FILE" "$URL" || exit 1
else
	xbps-fetch -o "$FILE" "$URL" || exit 1
fi

$TAR xf "$FILE" -C xtools-extra --strip-components=1 || exit 1
