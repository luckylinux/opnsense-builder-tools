#!/bin/tcsh

# Useful Reference: https://forum.opnsense.org/index.php?topic=21739.0

# Automatic Generation of OPNSENSE_RELEASE
# Only Consider the MAJOR.minor Version and ignore further sub-versions
#setenv OPNSENSE_RELEASE `opnsense-version | sed -E -e "s/[a-zA-Z]+ ([0-9]+).([0-9]+).*/\1.\2/"`
#setenv OPNSENSE_RELEASE `opnsense-version -x`
setenv OPNSENSE_RELEASE `opnsense-version -a`

# Automatic Generation OPNSENSE_FREEBSD_BASE
# Only consider the Major Version
setenv OPNSENSE_FREEBSD_BASE `freebsd-version | sed -E -e "s/^([0-9]+)\.([0-9]+).*/\1/"`
#setenv OPNSENSE_FREEBSD_BASE `uname -r | sed -E -e "s/^([0-9]+)\.([0-9]+).*/\1/"`

# Automatic Generation of BUILD_JAIL_VERSION **WITHOUT** Commas
setenv BUILD_JAIL_VERSION_RAW "${OPNSENSE_RELEASE}"
setenv BUILD_JAIL_VERSION_STRING `echo ${OPNSENSE_RELEASE} | sed -E -e "s/([0-9]+)\.([0-9]+).*/\1\2/"`

# Automatic Generation of BUILD_JAIL_NAME
setenv BUILD_JAIL_NAME "opnsense${BUILD_JAIL_VERSION_STRING}"

# Define Constant/Fixed Parameters
setenv POUDIERE_PORTS_TREE_NAME "opnports"
setenv POUDIERE_PACKAGE_SET_NAME "customsense"
