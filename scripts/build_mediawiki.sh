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
		cd buildcache
		rm -rf mediawiki
		git clone $GITCLONE_OPTS https://gerrit.wikimedia.org/r/p/mediawiki/core.git mediawiki

		cd mediawiki

		( cd extensions
		for EXT in $EXTRA_EXTENSIONS; do
			clonebranch https://gerrit.wikimedia.org/r/mediawiki/extensions/$EXT.git $EXT
		done
		)

		( cd skins
		for SKIN in $EXTRA_SKINS; do
			clonebranch https://gerrit.wikimedia.org/r/mediawiki/skins/$SKIN.git $SKIN
		done
		)

		find . -name .git | xargs rm -rf

		composer install --no-interaction
		touch COMPLETE # Mark this buildcache as usable
	)
fi

cp -r buildcache/mediawiki ./
