#!/usr/bin/env bash
# FRPC Installer Script for PrivateRouter FRPC
# Coded by Jason Hawks <jason@fixedbit.com>

# Exit on error
set -e

# Functions
frpc_system()
{
    # Install our required packages
    apt update; apt install -y jq curl

    # Find the newest tag and set it, along with other required variables
    FRPC_VERSION=`curl --silent "https://api.github.com/repos/fatedier/frp/releases/latest" | jq -r .tag_name`
    FRPC_FILENAME=frp_${FRPC_VERSION#v}_linux_${FRPC_ARCH}.tar.gz
    FRPC_DIRECTORY=frp_${FRPC_VERSION#v}_linux_${FRPC_ARCH}
    FRPC_URL=https://github.com/fatedier/frp/releases/download/${FRPC_VERSION}/${FRPC_FILENAME}

    # Set /tmp as active directory and do our tasks
    pushd /tmp
    wget "${FRPC_URL}"
    tar xfz "${FRPC_FILENAME}"

    # Install FRPC Config
    frpc_config

    # If frpc is not already installed, install it
    [ -f /usr/bin/frpc ] || cp "${FRPC_DIRECTORY}"/frpc /usr/bin/frpc

    # If the frpc service is not active, install it and start it, otherwise restart it
    [ "$(systemctl show -p ActiveState frpc | sed 's/ActiveState=//g')" != "active" ] && {
        cp "${FRPC_DIRECTORY}"/systemd/frpc.service /etc/systemd/system/frpc.service
        systemctl daemon-reload;
        systemctl enable frpc;
        systemctl start frpc;
    } || {
        systemctl restart frpc;
    }

    # Cleanup and pop out of /tmp
    rm -rf "${FRPC_DIRECTORY}" "${FRPC_FILENAME}"
    popd
}

frpc_docker()
{
    # Check if docker is installed, if not install it
    [ -x "$(command -v docker)" ] && echo "* Docker is already installed" || {
        echo "* Installing Docker"
        # Install our required packages
        apt update; apt install -y curl

        # Pull docker install script and run it
        curl -fsSL https://get.docker.com | sh
    }
    
    # Start our docker container for FRPC
    docker run --restart=always --network host -d \
      -e FRPC_IP="${FRP_SERVER}" \
      -e FRPC_PORT="${FRP_PORT}" \
      -e FRPC_TOKEN="${FRP_TOKEN}" \
      -e FRPC_SERVICES='http,tcp,80 https,tcp,443' \
      --name frpc privaterouterllc/frpc
}

frpc_config()
{
[ -d /etc/frp ] || mkdir -p /etc/frp
cat > /etc/frp/frpc.ini <<-EOF
[common]
server_addr = ${FRP_SERVER}
server_port = ${FRP_PORT}
token = ${FRP_TOKEN}

[http]
type = tcp
local_ip = 127.0.0.1
local_port = 80
remote_port = 80

[https]
type = tcp
local_ip = 127.0.0.1
local_port = 443
remote_port = 443
EOF
}

# Display our pretty banner
echo "                                                                      "
echo " ███████████             ███                         █████            "
echo "░░███░░░░░███           ░░░                         ░░███             "
echo " ░███    ░███ ████████  ████  █████ █████  ██████   ███████    ██████ "
echo " ░██████████ ░░███░░███░░███ ░░███ ░░███  ░░░░░███ ░░░███░    ███░░███"
echo " ░███░░░░░░   ░███ ░░░  ░███  ░███  ░███   ███████   ░███    ░███████ "
echo " ░███         ░███      ░███  ░░███ ███   ███░░███   ░███ ███░███░░░  "
echo " █████        █████     █████  ░░█████   ░░████████  ░░█████ ░░██████ "
echo "░░░░░        ░░░░░     ░░░░░    ░░░░░     ░░░░░░░░    ░░░░░   ░░░░░░  "
echo "                                                                      "
echo "                                                                      "
echo " ███████████                        █████                             "
echo "░░███░░░░░███                      ░░███                              "
echo " ░███    ░███   ██████  █████ ████ ███████    ██████  ████████        "
echo " ░██████████   ███░░███░░███ ░███ ░░░███░    ███░░███░░███░░███       "
echo " ░███░░░░░███ ░███ ░███ ░███ ░███   ░███    ░███████  ░███ ░░░        "
echo " ░███    ░███ ░███ ░███ ░███ ░███   ░███ ███░███░░░   ░███            "
echo " █████   █████░░██████  ░░████████  ░░█████ ░░██████  █████           "
echo "░░░░░   ░░░░░  ░░░░░░    ░░░░░░░░    ░░░░░   ░░░░░░  ░░░░░            "
echo "                                                                      "
echo "                                                                      "                                                                   
echo " ███████████ ███████████   ███████████    █████████                   "
echo "░░███░░░░░░█░░███░░░░░███ ░░███░░░░░███  ███░░░░░███                  "
echo " ░███   █ ░  ░███    ░███  ░███    ░███ ███     ░░░                   "
echo " ░███████    ░██████████   ░██████████ ░███                           "
echo " ░███░░░█    ░███░░░░░███  ░███░░░░░░  ░███                           "
echo " ░███  ░     ░███    ░███  ░███        ░░███     ███                  "
echo " █████       █████   █████ █████        ░░█████████                   "
echo "░░░░░       ░░░░░   ░░░░░ ░░░░░          ░░░░░░░░░                    "
echo "                                                                      " 

# Check if we are root
[ "$EUID" -ne 0 ] && { echo "Please run as root"; exit 1; }

#  Read our script name
SCRIPT_NAME="$(basename "$(test -L "$0" && readlink "$0" || echo "$0")")"

# Helper Sub
show_help()
{    
    echo "== ${SCRIPT_NAME} Flags (* Indicates Required) =="
    echo "* [-s 123.456.789.012]* sets the FRP Server Address"
    echo "* [-p 7000] sets the FRP Server Port"
    echo "* [-t abcd12345]* sets the FRP Server Token"
    echo "* [-d] Flags this as docker container install"
    echo "* [-c] Cleans the history after install"
    echo "* Example: ${SCRIPT_NAME} -s 123.456.789.012 -t abcd12345"
}

# Check if we have passed any arguments
[ $# -eq 0 ] && show_help && exit 1

# Iterate over arguments and process them
while (( "${#}" )); do
    case "${1}" in
        -h|--help)
            show_help
            exit 0
            ;;
        -s|--server)
            [[ ${2} != -* && ! -z ${2} ]] && { FRP_SERVER="${2}"; echo "Using FRP Server: ${2}"; } || { ERRORS+=("Invalid FRP Server passed to -s"); }
            shift
            ;;
        -p|--port)
            [[ ${2} != -* && ! -z ${2} ]] && { FRP_PORT="${2}"; echo "Using FRP Port: ${2}"; } || { ERRORS+=("Invalid FRP Port passed to -p"); }
            shift
            ;;
        -t|--token)
            [[ ${2} != -* && ! -z ${2} ]] && { FRP_TOKEN="${2}"; echo "Using FRP Token: ${2}"; } || { ERRORS+=("Invalid FRP Token passed to -t"); }
            shift
            ;;
        -f|--force)
            echo "Force Install Enabled"
            FORCE=1
            ;;
        -d|--docker)
            echo "Docker Install Flag Detected"
            DOCKER=1
            ;;
        -c|--clean)
            echo "Clean History Flag Detected"
            CLEAN=1
            ;;
        *)
            ERRORS+=("${1} is not a valid argument for ${SCRIPT_NAME}")
            ;;
    esac
    shift
done


# If we are running docker install, skip this
[ -z "${DOCKER}" ] && { 
    # If force is not set and FRPC is already installed, exit
    [[ -z "${FORCE}" && "$(systemctl show -p ActiveState frpc | sed 's/ActiveState=//g')" == "active" ]] && { 
        echo "* FRPC is already installed (use -f to override this)"
        exit 1
    }
}

# Check if our required arguments are set
[ -z "${FRP_SERVER}" ] && { ERRORS+=("FRP Server is required"); }
[ -z "${FRP_PORT}" ] && { FRP_PORT=7000; }
[ -z "${FRP_TOKEN}" ] && { ERRORS+=("FRP Token is required"); }

# Print out our errors if we have any
if [ ! -z "${ERRORS}" ]; then
    printf "\n== The following Errors Were Found ==\n"
    for error in "${ERRORS[@]}"; do
        printf "\n= ${error}\n"
    done
    exit 1
fi


# Determine our OS Architecture
case "$(uname -m)" in
    x86_64) FRPC_ARCH='amd64';;
    aarch64) FRPC_ARCH='arm64';;
    armv7l) FRPC_ARCH='arm';;
    *) echo "== !! unsupported architecture $(uname -m)"; exit 1 ;;
esac



# If docker is flagged install docker frpc, otherwise install system version of frpc
[ -z "${DOCKER}" ] && frpc_system || frpc_docker

[ -z "${CLEAN}" ] || {
    echo "Cleaning History"
    history -w
    cat /dev/null > ~/.bash_history
    history -c
}
