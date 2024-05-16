#!/bin/tcsh

# Useful Reference: https://forum.opnsense.org/index.php?topic=21739.0

# Manually Defined Versions
setenv OPNSENSE_RELEASE "24.1"
setenv OPNSENSE_FREEBSD_BASE "13"

# Automatically Calculated
setenv BUILD_JAIL_VERSION_RAW "${setenv OPNSENSE_RELEASE}"
setenv BUILD_JAIL_VERSION_STRING `echo ${OPNSENSE_RELEASE} | sed -E -e "s/([0-9]+)\.([0-9]+).*/\1\2/"`
setenv BUILD_JAIL_NAME "opnsense${BUILD_JAIL_VERSION_STRING}"

# Fixed / Static
setenv POUDIERE_PORTS_TREE_NAME "opnports"
setenv POUDIERE_PACKAGE_SET_NAME "customsense"
