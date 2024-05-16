# Introduction
OPNSense Builder Tools / Scripts / Configuration.

This assumes that you have:
a. One (or more) OPNSense Production Instances
b. One (or more) OPNSense Dedicated Builders Instances

**IMPORTANT**: I highly reccomend to setup the building Process on a Dedicated Builder Machine, in order to limit the Installation of Development Packages on the main / Production OPNSense Instance !!

# Credits
This Guide / Tools are based on the Excellent Guide from the [OPNSense Forum](https://forum.opnsense.org/index.php?topic=21739.0).

# Purpose
For me, the main Purpose of this Builder was to create Packages for `sysutils/py-salt` (Salt, formerly known as Saltstack) to manage my OPNSense Router.

# Scheduled Task

## Introduction
The Custom Actions are stored in the `/usr/local/opnsense/service/conf/actions.d/` Folder.

## File Names, Action Names, Tag Names and Content
### Custom Actions (Generic)

Filename: `/usr/local/opnsense/service/conf/actions.d/actions_<action-name>.conf`

Contents:
```
[tag-name]
command: my-command
parameters: --my-arg1 value1 --my-arg2 value2 ...
type:script
message: Custom Message Describing what's going on
description: Custom Message Describing what's going on
```

**IMPORTANT**: without the description: line, this Custom Action will NOT be available in OPNsense Web GUI !

### Custom Actions (Test)
Filename: `/usr/local/opnsense/service/conf/actions.d/actions_test.conf`

Contents:
```
[whoami]
command:whoami
parameters:
type:script_output
message:Who am I?
```

### Custom Actions (Production)
Filename: `/usr/local/opnsense/service/conf/actions.d/actions_builder_update.conf`

Contents:
```
command: /usr/local/bin/builder-update
parameters:
type:script
message: Automatically (re)Build and Update Selected Packages
description: Automatically (re)Build and Update Selected Package
```

**IMPORTANT**: I'm NOT sure that the TAG name must be [restart]. I tried with [reconfigure] and I was still getting an Error.

## Create Custom Action (General)
### Procedure (Generic)
1. Create Custom Action: `nano /usr/local/opnsense/service/conf/actions.d/actions_<action-name>.conf`
2. Update Actions List: `service configd restart`
3. Test that it works correctly from the Command Line: `configctl <action-name> <tag-name>`

### Procedure (Test)
1. Create Custom Action: `nano /usr/local/opnsense/service/conf/actions.d/actions_test.conf`
2. Update Actions List: `service configd restart`
3. Test that it works correctly from the Command Line: `configctl test whoami`
4. Returned value: `root`


## Create a new Scheduled Task
On your OPNSense Builder Instance

1. Create a file in `/usr/local/opnsense/service/conf/actions.d/actions_builder_update.conf`.

```
[restart]
command: /usr/local/bin/builder-update
parameters:
type:script
message: Automatically (re)Build and Update Selected Packages
description: Automatically (re)Build and Update Selected Package
```

2. Update Actions List: `service configd restart`

3. Test that it works correctly from the Command Line: `configctl builder_update restart`

4. Check that the Returned value from the Command is: `OK`

## Adding a new Scheduled Task in OPNSense Web UI
Setup a CRON Job in OPNSense Web GUI.

1.  Navigate to System -> Settings -> Cron
2.  Click "+" to add a new Item
3.  Hours/Minutes: Select the Time you wish the Scheduled Task to run (choose a time close-by to make sure that it's working the first time, e.g. 5 minutes from now)
4.  Day of the month/Months/Days of the week: leave it set to ANY (*) so that new Packages will be (re)built and updated automatically every Day
5.  Command: Select `Automatically (re)Build and Update Selected Packages`
6.  Description: fill in a User-Friendly Description (I use `Automatically (re)Build and Update Selected Packages`)
7.  Click: Apply
8.  Click: Apply (AGAIN) !
9.  Monitor the Logs in System -> Log Files. **Be sure to use the Multiselect and select ALL types of Messages**
10. Verify if the Custom Action works correctly (`Exit Code 0`, `returned OK`) or if there are some Errors (e.g. `Exit Code 1`, ... `returned Error (1)` and `returned exit status 1`)

NOTE: I'm NOT sure if it's really needed to click "Apply" twice. I prefer to do so, in case the first time didn't really trigger.

## Refreshing a Scheduled Task in OPNSense Web UI if the Custom Action File was changed
IMPORTANT: if you changed the Custom Action in ANY way:

- Filename was changed (e.g. `/usr/local/opnsense/service/conf/actions.d/actions_name1.conf` was moved/renamed to `/usr/local/opnsense/service/conf/actions.d/actions_name2.conf`)
- Tag Name was changed (e.g. `tag1` -> `tag2`)
- Command to be Executed was changed
- Arguments were changed
- Description was changed
- Message was changed

Then you will **MOST LIKELY NEED TO PERFORM THESE ADDITIONAL PROCEDURES**.

I also found that the CRON Job setup in the Web GUI tends to fail with `Exit Code 1` or ... `returned Error (1)` or `returned exit status 1` even though it was working correctly from the CLI.

This might be due to the fact that the Filename and Action/Tag are set when you "click" on the Action Description in the Web GUI.

But these are not/might not be refreshed if you modified e.g. the Tag or Filename, **even if** you issued the `service configd restart` Command correctly.

If you use the "Inspect Element" Feature on Chromium / Firefox Web Browser, you will see that the Action Name **and** the Tag Name are **BOTH** included in the Scheduled Task Setting (value="[action-name] [tag-name]" in the HTML) when you click on an Item in the Command Select Box:

<option value="builder_update restart" selected="selected">Automatically (re)Build and Update Selected Package</option>

In order to workaround this issue some additionnal steps (TEMPORARILY change the Command to be executed) might be/are required:

1. Update Actions List: `service configd restart`
2. Test that it works correctly from the Command Line: `configctl builder_update restart`
3. Edit CRON Job in OPNSense Web GUI with a TEMPORARY FIX
4. Set TEMPORARILY the command to one of the Other OPNSense Commands (e.g. Automatic Firmware Update)
5. Click Save
6. Click Apply
7. Click Apply (AGAIN) !
8. Edit the CRON Job in OPNSense Web GUI for the REAL TIME now
9. Reselect the Appropriate Command "Automatically (re)Build and Update Selected Packages"
10. Click Save
11. Click Apply
12. Click Apply (AGAIN) !
13. Monitor the Logs in System -> Log Files. **Be sure to use the Multiselect and select ALL types of Messages**
14. Verify if the Custom Action works correctly (`Exit Code 0`, `returned OK`) or if there are some Errors (e.g. `Exit Code 1`, ... `returned Error (1)` and `returned exit status 1`)

NOTE: I'm NOT sure if it's really needed to click "Apply" twice. I prefer to do so, in case the first time didn't really trigger.

# Notes
- Update Actions List: `service configd restart`
- Debug Issues: `configctl <action-name> <tag-name>`
- Debugging Issues for the action name with tag: `configctl test whoami`
- Debugging Issues for the <builder_update> action name with tag: `configctl builder_update restart``

# Install Salt on Production OPNSense
## Configure Repository
See `./production/usr/local/bin/setup-custom-repository`.

```
#!/bin/tcsh

# Define Parameters
setenv OPNSENSE_RELEASE "24.1"
setenv OPNSENSE_FREEBSD_BASE "13"
setenv BUILD_JAIL_NAME "opnsense241"
setenv POUDIERE_PORTS_TREE_NAME "opnports"
setenv POUDIERE_PACKAGE_SET_NAME "customsense"
setenv OPNSENSE_BUILDER_HOSTNAME "opnsensebuilder1.MYDOMAIN.TLD"

# Automatically Performed
cat <<EOF > /usr/local/etc/pkg/repos/custom.conf
Custom: {
  url      : https://${OPNSENSE_BUILDER_HOSTNAME}:8443/${BUILD_JAIL_NAME}/${POUDIERE_PACKAGE_SET_NAME},
  priority : 5,
  enabled  : yes
}
EOF
```

## Setup proper SSL/TLS Certificates Environment
On a Desktop convert CERTIFICATES to the same Format as the other Certificates used by FreeBSD
```
openssl x509 -in opnsensebuilder1/OPNSenseBuilder1-CA.crt -text -fingerprint -outform PEM -out opnsensebuilder1/OPNSenseBuilder1-CA.pem
```

Combine CA + CERT into one
```
cat opnsensebuilder1/OPNSenseBuilder1-CA.pem opnsensebuilder1/OPNSenseBuilder1-CERT.pem > opnsensebuilder1/OPNSenseBuilder1-COMBINED.pem
```

Upload the CERTIFICATES (for TLS / HTTPS) generated on the Builder Servers
- `/usr/local/etc/ssl/` Folder does NOT seem to be scanned by "certctl rehash"
- `/usr/local/share/certs` Folder IS scanned by "certctl rehash"

```
scp <myfiles> root@MY_OPNSENSE_PRODUCTION_IP:/usr/local/share/certs
```

**IMPORTANT**: If a `cert.pem` File exists, all other Certificates are ignored when performing `pkg update`, which will result (in the case of a self-generated Certificate) an SSL/TLS Error and PKG Update Failure !!!

See for Instance these Thread for more Information:
- https://forums.freebsd.org/threads/pkg-private-certificate-authority.87833/#post-596096
- https://forums.freebsd.org/threads/local-pkg-repo-w-tls-via-poudriere-nginx-and-a-smallstep-ca-step-cli-step-certificates.79159/

For this reason we remove (backup FIRST) the file that prevents custom Certificates from being used
```
setenv timestamp `date +"%Y%m%d"`
mv /etc/ssl/cert.pem /etc/ssl/cert.pem.backup.${timestamp}
mv /usr/local/etc/ssl/cert.pem /usr/local/etc/ssl/cert.pem.backup.${timestamp}
```

More Information is available in: `./production/usr/local/bin/custom-repository-enable-custom-certificates`.

## Install Salt

Install the `salt-minion` Package:
```
pkg install sysconfig/py-salt
```

Enable the `salt-minion` Service:
```
# Open /etc/rc.conf with your preferred Text Editor
nano /etc/rc.conf

# Add the following
sysrc salt_minion_enable="YES"
salt_minion_enable="YES"
```

Manually (Re)start Salt Service for the First Time:
```
service salt_minion restart
```

# Restart Salt Service
This is needed in order to ensure that the new Version of `salt-minion` is loaded.

## Create a new Scheduled Task
On your OPNSense Builder Instance

1. Create a file in `/usr/local/opnsense/service/conf/actions.d/actions_salt_minion.conf`.

```
[restart]
command: service salt_minion restart
parameters:
type:script
message: Restart salt-minion Service
description: Restart salt-minion Service
```

2. Update Actions List: `service configd restart`

3. Test that it works correctly from the Command Line: `configctl salt_minion restart`

4. Check that the Returned value from the Command is: `OK`

## Adding a new Scheduled Task in OPNSense Web UI
Setup a CRON Job in OPNSense Web GUI.

1.  Navigate to System -> Settings -> Cron
2.  Click "+" to add a new Item
3.  Hours/Minutes: Select the Time you wish the Scheduled Task to run (choose a time close-by to make sure that it's working the first time, e.g. 5 minutes from now)
4.  Day of the month/Months/Days of the week: leave it set to ANY (*) so that new Packages will be (re)built and updated automatically every Day
5.  Command: Select `Restart salt-minion Service`
6.  Description: fill in a User-Friendly Description (I use `Restart salt-minion Service`)
7.  Click: Apply
8.  Click: Apply (AGAIN) !
9.  Monitor the Logs in System -> Log Files. **Be sure to use the Multiselect and select ALL types of Messages**
10. Verify if the Custom Action works correctly (`Exit Code 0`, `returned OK`) or if there are some Errors (e.g. `Exit Code 1`, ... `returned Error (1)` and `returned exit status 1`)

NOTE: I'm NOT sure if it's really needed to click "Apply" twice. I prefer to do so, in case the first time didn't really trigger.

# Lock Packages
By default, Packages built using Poudriere will also bring in an Updated Version of `pkg` Package.

In order to prevent automatic upgrade of the `pkg` Package on Production Systems, it is reccomended to issue a:
```
pkg annotate -A pkg repository OPNsense

pkg lock pkg
```

# Debugging
By default, there can be several Issues that arise.

Certificate Validation being one of them when `pkg` tries to establish connection to the Builder HTTPs Website ...

## Certificates SSL/TLS used together with `pkg`
- Reinstall ROOT Certificates: `pkg install ca_root_nss`
- Renegerate Certificates: `certctl rehash`
- List all Certificates: `certctl list`
- Check if a Certificate that we use for the OPNSense Builder Host is installed in the Database: `certctl list | grep -i OPNSenseBuilder`
- Debug SSL Issues with `openssl`
  - Without SNI: `openssl s_client -verify_return_error -connect opnsensebuilder1.MYDOMAIN.TLD:8443`
  - With SNI: `openssl s_client -servername opnsensebuilder1.MYDOMAIN.TLD -connect opnsensebuilder1.MYDOMAIN.TLD:8443 | openssl x509 -text`

- Debug SSL Issues with `fetch`: `fetch https://opnsensebuilder1.MYDOMAIN.TLD`

## Debugging other PKG Issues
- Check Status of all Packages installed: ```pkg check -a -d -v```
- Remove unused Packages: `pkg autoremove; pkg clean`
- Upgrade while trying to respect where the Package was initially Installed From: `pkg -o CONSERVATIVE_UPGRADE=true upgrade`
