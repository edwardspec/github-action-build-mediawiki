#!/bin/bash -e
###############################################################################
# Unpack the MediaWiki tarball, run install.php if needed.
#
# Usage: ./install_mediawiki
#
# All parameters are passed via BUILDMW_* environmental variables, for example:
# BUILDMW_BRANCH="REL1_39"
# BUILDMW_EXTRA_EXTENSIONS="PageForms Cargo"
# BUILDMW_EXTRA_SKINS="MinervaNeue"
# BUILDMW_EXTRA_LOCALSETTINGS="tests/TestOnlySettings.php"
###############################################################################

extraSettingsPath=
if [ ! -z "${BUILDMW_EXTRA_LOCALSETTINGS}" ]; then
	extraSettingsPath=$(realpath ${BUILDMW_EXTRA_LOCALSETTINGS})
fi

# Step 1: run build_mediawiki.sh, which will create subdirectory "mediawiki"
# and populate it with downloaded sources of MediaWiki core and extensions.
$(dirname $0)/build_mediawiki.sh "${BUILDMW_BRANCH}"
cd mediawiki

# Step 2: run install.php unless asked not to (BUILDMW_NOINSTALL is not empty).
if [ -z "${BUILDMW_NOINSTALL}" ]; then
	php maintenance/install.php ghactionmediawiki admin \
		--pass $(dd if=/dev/urandom count=1 bs=20 2>/dev/null | base64) \
		--dbtype "${BUILDMW_DBTYPE}" \
		--dbserver "${BUILDMW_DBSERVER}" \
		--dbname "${BUILDMW_DBNAME}" \
		--dbuser "${BUILDMW_DBUSER}" \
		--dbpass "${BUILDMW_DBPASS}" \
		--scriptpath "/w"
fi

# Step 3: prepare LocalSettings.php, then lint it.

# Enable DevelopmentSettings.php unless asked not to (BUILDMW_NO_DEVSETTING is not empty),
# which is wanted in 99% of usecases outside production use.
if [ -z "${BUILDMW_NO_DEVSETTING}" ]; then
	echo -en "\n\nrequire_once __DIR__ . '/includes/DevelopmentSettings.php';\n" >> ./LocalSettings.php
fi

# Load an extra configuration file at the end of LocalSettings.php.
if [ ! -z "$extraSettingsPath" ]; then
	echo -en "\n\nrequire_once '$extraSettingsPath';\n" >> ./LocalSettings.php
fi

# Check the resulting LocalSettings.php with linter to catch any syntax errors early.
php -l ./LocalSettings.php
