# Directory containing this makefile.
ROOT := $(dir $(realpath $(firstword $(MAKEFILE_LIST))))
HOSTDIR := $(ROOT)/hostdir

export PATH := $(ROOT)/xtools-extra:${PATH}
export XBPS_DISTDIR := $(ROOT)/void-packages
XBPS_GIT = git -C $(XBPS_DISTDIR)
REMOTE := https://github.com/void-linux/void-packages.git

XBPS_SRC_FLAGS = -H $(HOSTDIR)
XBPS_SRC = $(XBPS_DISTDIR)/xbps-src $(XBPS_SRC_FLAGS)

PRIVKEY := privkey.pem
REPO_CONF := /etc/xbps.d/00-repository-local.conf
TARGET_PKGS := $(notdir $(realpath $(wildcard srcpkgs/*)))

.PHONY: all install sync pkgs sign clean

all: pkgs

# Install repository configuration.
install: $(REPO_CONF)

$(REPO_CONF):
	echo "# local repositories" > $@
	echo "repository=$(HOSTDIR)/binpkgs" >> $@
	echo "repository=$(HOSTDIR)/binpkgs/nonfree" >> $@
	echo "repository=$(HOSTDIR)/binpkgs/multilib" >> $@
	echo "repository=$(HOSTDIR)/binpkgs/multilib/nonfree" >> $@
	echo "repository=$(HOSTDIR)/binpkgs/debug" >> $@

pkgs: XBPS_SRC_FLAGS += -E

# Build all packages in `srcpkgs` directory.
pkgs: $(TARGET_PKGS)

$(TARGET_PKGS): sync $(XBPS_DISTDIR)/etc/conf
	$(XBPS_SRC) pkg $@

sign: $(PRIVKEY)
	# Sign directories with repository data.
	find $(HOSTDIR)/binpkgs -type f -name '*-repodata' -printf '%h\0' \
		| xargs -0 -n1 xbps-rindex --sign --signedby 'antivoid-packages' --privkey $(PRIVKEY)
	# Sign all packages.
	find $(HOSTDIR)/binpkgs -type f -name '*.xbps' -print0 \
		| xargs -0 xbps-rindex --sign-pkg --privkey $(PRIVKEY)

# Generate private key for repository signing.
$(PRIVKEY):
	openssl genrsa -out $@ 4096 || ssh-keygen -b 4096 -t rsa -m PEM -N '' -f $@

# Update void-packages and masterdir
sync: xtools-extra $(XBPS_DISTDIR) $(XBPS_DISTDIR)/etc/conf
	$(XBPS_GIT) fetch --depth=1
	$(XBPS_GIT) reset --hard origin/master
	$(XBPS_SRC) binary-bootstrap
	$(XBPS_SRC) bootstrap-update
	xpunt srcpkgs/*

# Set up xbps-src configuration.
$(XBPS_DISTDIR)/etc/conf: $(XBPS_DISTDIR) xbps-src.conf
	cat xbps-src.conf > $@

# Initialize void-packages.
$(XBPS_DISTDIR):
	git clone --depth=1 $(REMOTE) $(XBPS_DISTDIR)

xtools-extra:
	command -v xpunt >/dev/null || ./fetch-xtools-extra.sh

clean:
	$(RM) -r $(XBPS_DISTDIR) $(HOSTDIR) $(PRIVKEY) xtools-extra{,.tar.gz}
