#!/usr/bin/env bash
# shellcheck disable=SC2034,2154

# openHABian - hassle-free openHAB installation and configuration tool
# for the Raspberry Pi and other Linux systems
#
# Documentation: https://www.openhab.org/docs/installation/openhabian.html
# Development: http://github.com/openhab/openhabian
# Discussion: https://community.openhab.org/t/13379
#


# für storm.house immer diese package-Versionen installieren
# überschreibt Eintrag in openhabian.conf

openhabForcePkg=	# 4.2.2-1	# default in build-image/openhabian.conf
evccForcePkg=		# 0.130.7	# default in build-image/openhabian.conf


configFile="/etc/openhabian.conf"
if ! [[ -f $configFile ]]; then
  cp /opt/openhabian/build-image/openhabian.conf "$configFile"
fi

# Find the absolute script location dir (e.g. BASEDIR=/opt/openhabian)
SOURCE="${BASH_SOURCE[0]}"
while [[ -h $SOURCE ]]; do
  BASEDIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="${BASEDIR:-/opt/openhabian}/$SOURCE"
done
BASEDIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
SCRIPTNAME="$(basename "$SOURCE")"

# Trap CTRL+C, CTRL+Z and quit singles
trap '' SIGINT SIGQUIT SIGTSTP

# Log with timestamp
timestamp() { printf "%(%F_%T_%Z)T\\n" "-1"; }

# Make sure only root can run our script
echo -n "$(timestamp) [openHABian] Checking for root privileges... "
if [[ $EUID -ne 0 ]]; then
  echo
  echo "This script must be run as root. Did you mean 'sudo openhabian-config'?" 1>&2
  echo "More info: https://www.openhab.org/docs/installation/openhabian.html"
  exit 1
else
  echo "OK"
fi


if [[ -n "${openhabForcePkg}" ]]; then
  sed -i "s|^.*openhabpkgversion.*$|openhabpkgversion=${openhabForcePkg}|g" "$configFile"
fi
if [[ -n "${evccForcePkg}" ]]; then
  sed -i "s|^.*evccpkgversion.*$|evccpkgversion=${evccForcePkg}|g" "$configFile"
fi
# shellcheck disable=SC1090
source "$configFile"

# script will be called with 'unattended' argument by openHABian images else retrieve values from openhabian.conf
if [[ $1 == "unattended" ]]; then
  APTTIMEOUT="${apttimeout:-60}"
  UNATTENDED="1"
  SILENT="1"
else
  INTERACTIVE="1"
fi

# shellcheck disable=SC2154
if [[ $debugmode == "off" ]]; then
  SILENT=1
  unset DEBUGMAX
elif [[ $debugmode == "on" ]]; then
  unset SILENT
  unset DEBUGMAX
elif [[ $debugmode == "maximum" ]]; then
  unset SILENT
  DEBUGMAX=1
  set -x
fi

export UNATTENDED SILENT DEBUGMAX INTERACTIVE

# Include all subscripts
# shellcheck source=/dev/null
for shfile in "${BASEDIR:-/opt/openhabian}"/functions/*.bash; do source "$shfile"; done

# avoid potential crash when deleting directory we started from
OLDWD="$(pwd)"
cd /opt || exit 1

CONFIGTXT=/boot/config.txt
if is_bookworm; then
  CONFIGTXT=/boot/firmware/config.txt
fi
export CONFIGTXT

# update openhabian.conf to have latest set of parameters
update_openhabian_conf

# disable ipv6 if requested in openhabian.conf (eventually reboots)
config_ipv6

if [[ -n "$UNATTENDED" ]]; then
  # apt/dpkg commands will not try interactive dialogs
  export DEBIAN_FRONTEND="noninteractive"
  wait_for_apt_to_finish_update
  load_create_config
  change_swapsize
  timezone_setting
  locale_setting
  hostname_change
  memory_split
  #enable_rpi_audio
  basic_packages
  needed_packages
  bashrc_copy
  vimrc_copy
  install_tailscale "install"
  misc_system_settings
  add_admin_ssh_key
  java_install "${java_opt:-17}"
  openhab_setup "${clonebranch:-openHAB}" "release" "${openhabpkgversion}"
  install_extras
  replace_logo
  import_openhab_config
  openhab_shell_interfaces
  setup_tailscale
  vim_openhab_syntax
  nano_openhab_syntax
  multitail_openhab_scheme
  #srv_bind_mounts
  samba_setup
  nginx_setup
  clean_config_userpw
  #frontail_setup
  zram_setup
  permissions_corrections
  setup_mirror_SD "install"
  install_evcc "install" "${evccpkgversion}"; setup_evcc
  systemctl stop openhab
  setup_pv_config pv "${invertertype:-custom}" "${inverterip:-192.168.178.100}" "${invertermodbusid:-1}"
  setup_pv_config bat "${batterytype:-keine}" "${batteryip:-192.168.178.101}" "${batterymodbusid:-3}"
  setup_pv_config meter "${metertype:-inverter}" "${meterip:-192.168.178.102}" "${metermodbusid:-99}"
  setup_wb_config "${wallboxtype:-demo}" "${wallboxip:-192.168.178.200}"
  setup_power_config flat
  install_cleanup
  systemctl restart openhab
  finalize_setup
else
  apt_update
  whiptail_check
  load_create_config
  openhabian_console_check
  openhabian_update_check
  while show_main_menu; do
    true
  done
  system_check_default_password
  echo -e "$(timestamp) [openHABian] We hope you got what you came for! See you again soon ;)"
fi
# shellcheck disable=SC2164
cd "$OLDWD"

# vim: filetype=sh
