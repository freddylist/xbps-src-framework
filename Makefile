# Directory containing this makefile.
ROOT := $(dir $(realpath $(firstword $(MAKEFILE_LIST))))
HOSTDIR := $(ROOT)/hostdir

export XBPS_DISTDIR := $(ROOT)/void-packages
XBPS_GIT = git -C $(XBPS_DISTDIR)
REMOTE := https://github.com/void-linux/void-packages.git

XBPS_SRC_FLAGS = -H $(HOSTDIR) -E
XBPS_SRC = $(XBPS_DISTDIR)/xbps-src $(XBPS_SRC_FLAGS)

PRIVKEY := privkey.pem

include conf.mak

.PHONY: install uninstall sync pkgs clean

all: build

# Install repository configuration.
install: $(REPO_CONF)

$(REPO_CONF):
	echo "# local repositories" > $@
	echo "repository=$(HOSTDIR)/binpkgs" >> $@
	echo "repository=$(HOSTDIR)/binpkgs/nonfree" >> $@

# Uninstall repository configuration
uninstall:
	$(RM) $(REPO_CONF)

# Build and sign packages in `srcpkgs` directory.
pkgs: sync $(PRIVKEY) $(XBPS_DISTDIR)/etc/conf
	# Templates are copied to distdir in sync target
	# so just build everything listed in srcpkgs.
	find srcpkgs -mindepth 1 -maxdepth 1 -printf '%f\0' \
		| xargs -0 -n1 $(XBPS_SRC) pkg
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
sync: $(XBPS_DISTDIR) $(XBPS_DISTDIR)/etc/conf
	$(XBPS_GIT) fetch --depth=1
	$(XBPS_GIT) reset --hard origin/master
	$(XBPS_SRC) binary-bootstrap
	$(XBPS_SRC) bootstrap-update
	./ensure-templates.sh srcpkgs/*

# Set up xbps-src configuration.
$(XBPS_DISTDIR)/etc/conf: $(XBPS_DISTDIR) xbps-src.conf
	cat xbps-src.conf > $@

# Initialize void-packages.
$(XBPS_DISTDIR):
	git clone --depth=1 $(REMOTE) $(XBPS_DISTDIR)

# Make sure these files exist.
xbps-src.conf:
	touch $@

# Ensure xtools is installed.
xtools:
	@if [ -z "$$(command -v xgensum)" ]; then \
		echo "Please install xtools!"; \
		echo "# xbps-install -S xtools"; \
		exit 1; \
	fi

clean:
	$(RM) -r $(XBPS_DISTDIR) $(HOSTDIR) $(PRIVKEY)
