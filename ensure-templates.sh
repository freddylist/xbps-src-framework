#!/bin/bash

set -e

XBPS_DISTDIR="$(readlink -f "$(xdistdir)")" || exit 1
XBPS_SRCPKGS="${XBPS_DISTDIR}/srcpkgs"

for pkg; do
	pkgdir="$(readlink -f "$pkg")"

	# Template already in distdir?
	[[ -n "$(find "${XBPS_SRCPKGS}" -samefile "$pkgdir" -print -quit)" ]] && continue

	# Copy template to distdir for fetching
	rm -rf "${XBPS_SRCPKGS:?}/${pkgdir##*/}"
	cp -r "$pkgdir" "${XBPS_SRCPKGS}"
done
