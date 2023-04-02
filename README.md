# `xbps-src` framework

Framework/glue for working with `xbps-src` to bulk build packages from custom and restricted templates.
You can aggregate templates from multiple sources, updating all of them at once (probably with a `git pull`).
See [known template collections](#known-template-collections) for a list of links to collections of templates I could find all around the interwebs.
Please open a pull request if you have more!

See also [the-maldridge/xbps-mini-builder](https://github.com/the-maldridge/xbps-mini-builder).

## Requirements

- `bash`
- GNU `make`
- `xtools`
- [`xtools-extra`](https://github.com/freddylist/xtools-extra)
	- Automatically downloaded if you have an internet connection.

### Install all requirements:
```
# xbps-install -S bash make xtools
```

## Usage

1. Clone this repository:
```
$ git clone https://github.com/freddylist/xbps-src-framework.git
```
2. Create an `xbps-src.conf` to your liking:
	- `cp xbps-src.conf.sample xbps-src.conf`
	- I recommend having the following set:
	```
	XBPS_MIRROR=https://repo-fastly.voidlinux.org/current
	XBPS_CCACHE=yes
	```
	This makes `xbps-src` use the faster Fastly CDN mirror and enables CCache. Just remember to install the `ccache` package!
	- You can also add build options here:
	```
	# Global build options
	XBPS_PKG_OPTIONS=opt,~opt2,opt3,~opt4

	# Per-package build options
	XBPS_PKG_OPTIONS_foo=opt,~opt2,opt3,~opt4
	```
3. Create directory named `srcpkgs` next to the makefile.
3. Symlink or move packages that you wish to build on `make pkgs` to the `srcpkgs` directory.
	- Don't symlink subpackages. If you need to build a subpackage, symlink the main package. Subpackages are always created with the main package, whether you want them to or not.
4. Run `make pkgs`.
5. Run `make install` to install repository configuration.
	- This allows you to use `xbps-install` without `--repository=path/to/hostdir/binpkgs`.

From there, you can have a cron/snooze job occasionally update template sources and build symlinked packages for you.

If something's borked, you can try `make clean`.

Do not be afraid to open an issue if something is unclear or doesn't work.

## Known template collections

Somewhat alive:
- [freddylist/antivoid-packages](https://github.com/freddylist/antivoid-packages)
- [ayoubelmhamdi/void-linux-templates](https://github.com/ayoubelmhamdi/void-linux-templates)
- [Elvyria/voids-package-nightmare](https://github.com/Elvyria/voids-package-nightmare)
- [sug0/voided-packages](https://github.com/sug0/voided-packages)
- [mobinmob/abyss-packages](https://codeberg.org/mobinmob/abyss-packages)
- [DAINRA/ungoogled-chromium-void](https://github.com/DAINRA/ungoogled-chromium-void)
- [Marcoapc/voidxanmodK](https://notabug.org/Marcoapc/voidxanmodK)
- [weebi/void-packages](https://github.com/weebi/void-packages)

Seem to be kinda dead:
- [fdziarmagowski/into-the-void](https://github.com/fdziarmagowski/into-the-void)
- [cadadr/void-packages](https://codeberg.org/cadadr/void-packages)
- [reback00/void-goodies](https://notabug.org/reback00/void-goodies/src/master)
- [oSoWoSo/nvoid](https://github.com/oSoWoSo/nvoid), forked from [not-void/nvoid](https://github.com/not-void/nvoid)
- [70xH/void-kernel-builds](https://github.com/70xH/void-kernel-builds)
- [gbrlsnchs/void-pkgs](https://github.com/gbrlsnchs/void-pkgs)
- [nereusx/void-extra](https://github.com/nereusx/void-extra)
- [notchtc/custom-void-packages](https://github.com/notchtc/custom-void-packages)
- [intrnl/custom-void-packages](https://codeberg.org/intrnl/custom-void-packages)
