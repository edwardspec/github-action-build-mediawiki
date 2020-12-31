#!/bin/bash
###############################################################################
# Assemble the directory with MediaWiki
# Usage: ./build_mediawiki REL1_31
###############################################################################

branch=$1
GITCLONE_OPTS="--depth 1 --recurse-submodules -j 5 -b $branch"

mkdir -p buildcache/mediawiki

if [ ! -f buildcache/mediawiki/COMPLETE ]; then
	(
		# Downgrade PHP to 7.4 (GitHub Actions environment has PHP 8.0 preinstalled? not compatible with MW for now)
		# TODO: should be able to select PHP version as parameter of GitHub action.
		sudo apt update && DEBIAN_FRONTEND=noninteractive sudo apt-get install -y php7.4

		cd buildcache
		rm -rf mediawiki
		git clone $GITCLONE_OPTS https://gerrit.wikimedia.org/r/p/mediawiki/core.git mediawiki

		cd mediawiki

		find . -name .git | xargs rm -rf

		sudo composer self-update --1 # wikimedia/composer-merge-plugin is not yet compatible with Composer 2.
		composer install --no-interaction
		touch COMPLETE # Mark this buildcache as usable
	)
fi

cp -r buildcache/mediawiki ./
