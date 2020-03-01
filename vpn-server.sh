#!/bin/sh

function __vpn_server_help() {
  echo "vpn-server [create|run|--generate|--get-client-config] [DOMAIN]";
  echo "";
  echo -e "\t create \t\t create the server - provide a domain name";
  echo -e "\t run | start \t\t start the server";
  echo -e "\t --gen \t\t\t generate a paswordless client cert";
  echo -e "\t --get \t\t\t retrieve the client config with embedded cert";
}

function __vpn_server() {
  [[ -z $1 ]] && echo `tput setaf 1`!! You must provide a directive`tput sgr0` && echo -e "" && __vpn_server_help && return 1;

  export DOCKER_OVPN_VOL="ovpn-server-data";

  case "$1" in
    "create")
      [[ -z $2 ]] && echo `tput setaf 1`!! You must provide a domain name`tput sgr0` && echo -e "" && __vpn_server_help && return 1;
      docker volume create --name ${DOCKER_OVPN_VOL};
      docker run -v ${DOCKER_OVPN_VOL}:/etc/openvpn --log-driver=none --rm kylemanna/openvpn ovpn_genconfig -u udp://${2};
      docker run -v ${DOCKER_OVPN_VOL}:/etc/openvpn --log-driver=none --rm -it kylemanna/openvpn ovpn_initpki;
    ;;
    "run"|"start")
      docker run --rm -v ${DOCKER_OVPN_VOL}:/etc/openvpn -d -p 1194:1194/udp --cap-add=NET_ADMIN kylemanna/openvpn;
    ;;
    "--gen")
      [[ -z $2 ]] && echo `tput setaf 1`!! You must provide a client name`tput sgr0` && echo -e "" && __vpn_server_help && return 1;
      docker run -v ${DOCKER_OVPN_VOL}:/etc/openvpn --log-driver=none --rm -it kylemanna/openvpn easyrsa build-client-full $2 nopass;
    ;;
    "--get")
      [[ -z $2 ]] && echo `tput setaf 1`!! You must provide a client name`tput sgr0` && echo -e "" && __vpn_server_help && return 1;
      docker run -v ${DOCKER_OVPN_VOL}:/etc/openvpn --log-driver=none --rm kylemanna/openvpn ovpn_getclient $2 > ${2}.ovpn;
    ;;
    *)
      __vpn_server_help;
    ;;
  esac
}

alias vpn-server="__vpn_server";