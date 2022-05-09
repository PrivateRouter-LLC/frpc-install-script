# Private Router FRPC Install Script

This script allows you to easily install the FRP Client onto Linux.

It is an 'all-in-one' utility, which basically means you feed it information and it does the jobs for you.

This script can install the Docker Version of FRPC (and install Docker needed) or standalone which runs as a system service.

FRP is a reverse proxy client and server that you can read more about on their [GitHUB](https://github.com/fatedier/frp).

You can host your own FRP server or have a privacy protected reverse proxy from [PrivateRouter](https://privaterouter.com/reverse-proxy/).
# Script Help

Below are the flags that you may pass to the script.

```
== frpc-install-script.sh Flags (* Indicates Required) ==
* [-s 123.456.789.012]* sets the FRP Server Address
* [-p 7000] sets the FRP Server Port
* [-t abcd12345]* sets the FRP Server Token
* [-d] Flags this as docker container install
* [-c] Cleans the history after install
* Example: frpc-install-script.sh -s 123.456.789.012 -t abcd12345
```


To install as a Docker container:

**`frpc-install-script.sh -d -s [Server-IP] -t [Server-Token]`**


To install as a system service:

**`frpc-install-script.sh -s [Server-IP] -t [Server-Token]`**


As an added bonus you can run this script without downloading it like this:

**`curl https://raw.githubusercontent.com/PrivateRouter-LLC/frpc-install-script/main/frpc-install-script.sh | bash -s -- -s 123.456.789.120 -t token123`**


***Note: You may use the hidden -f flag to force the install such as FRPC already installed.***