#!/usr/bin/env bash

## #1=bat & #2=hybrid -> pv=#1 & bat=#1, ansonsten was definiert wurde
## #1=meter & #2=inverter -> meter=#1, ansonsten was definiert wurde

## Generate/copy openHAB config for a PV inverter
##
## valid arguments:
## #1 = pv | bat | meter
## #2 = device type #1=pv:    e3dc | fronius | huawei | kostal | senec | sma | solaredge | solax | sungrow (default) | victron | custom
##                  #1=bat:   hybrid (default) |
##                            e3dc | fronius | huawei | kostal | senec | sma | solaredge | solax | sungrow | victron | custom
##                  #1=meter: inverter (default) | sma | smashm | custom
## #3 = device ip
## #4 = modbus ID of device
## #5 (optional when #2/#3 = "bat hybrid|meter|inverter"): inverter (see #1=pv)
## #5 (optional) cardinal number of inverter
## #5 (optional) Modbus ID of logger
##
##    setup_pv_config(String element,String device type,String device IP,Number modbus ID,Number inverter number)
##
setup_pv_config() {
  local includesDir="${BASEDIR:-/opt/openhabian}/includes"
  local inverterPNG="${OPENHAB_CONF:-/etc/openhab}/icons/classic/inverter.png"
  local srcfile
  local destfile
  local device
  local default
  local ip
  local mbid
  local model
  local muser
  local mpass
  local serial


  if [[ -n "$UNATTENDED" ]]; then
    echo -n "$(timestamp) [storm.house] PV ${1} installation... "
    if [[ -z "${2:-$invertertype}" ]]; then echo "SKIPPED (no device defined)"; return 1; fi
  fi

  for configdomain in things items rules; do
    device="${1:-pv}"
    # shellcheck disable=SC2154
    case "${device}" in
      pv) default=${2:-$invertertype}; ip=${3:-inverterip}; mbid=${4:-${invertermodbusid}};
	  if [[ ${default} == "solarman" ]]; then model=${4:-${pvmodel}}; serial=${5:-${pvserial}}; fi
	  ;;
      bat) default=${batterytype}; ip=${3:-batteryip}; mbid=${4:-${batterymodbusid}};;
      meter) default=${metertype}; ip=${3:-meterip}; mbid=${4:-${metermodbusid}}; serial=${6:-${meterserial}}; muser=${7:-${meteruserid}}; mpass=${8:-${meterpassid}};;
    esac


    file="${2:-${default}}"
    if [[ "${device}" == "bat" && "${2:-$batterytype}" == "hybrid" ]]; then
        file="inv/${5:-${2:-$invertertype}}"
    fi
    if [[ "${device}" == "meter" ]]; then
      if [[ "${2:-${metertype}}" == "inverter" ]]; then
        file="inv/${5:-${2:-$invertertype}}"
      fi
    fi

    srcfile="${OPENHAB_CONF:-/etc/openhab}/${configdomain}/STORE/${device}/${file:-${default}}.${configdomain}"
    destfile="${OPENHAB_CONF:-/etc/openhab}/${configdomain}/${device}.${configdomain}"
    if [[ ${2:-${default}} != "custom" ]]; then rm -f "$destfile"; fi

    if [[ -f ${srcfile} ]]; then
      if [[ ! -f ${destfile} ]]; then
        cp -p "${srcfile}" "${destfile}"
      fi
      if [[ $(whoami) == "root" ]]; then
        chown "${username:-openhabian}:openhab" "${OPENHAB_CONF:-/etc/openhab}/${configdomain}/${device}.${configdomain}"
        chmod 664 "${OPENHAB_CONF:-/etc/openhab}/${configdomain}/${device}.${configdomain}"
      fi

      if [[ "${device}" == "pv" && "${2:-$invertertype}" == "huaweilogger" ]]; then
        # %HUAWEI1 bzw. 2 = 51000 + 25 * (MBID - 1) + 5 bzw 9 berechnen
        Erzeugung=$((51000 + 25 * (mbid - 1) + 5))
        PVStatus=$((Erzeugung + 4))
        sed -i "s|%HUAWEI1|${Erzeugung}|;s|%HUAWEI2|${PVStatus}|" "${destfile}"
        mbid="${5:-${loggermodbusid}}"  # diese ID muss angesprochen werden
      fi

      sed -i "s|%IP|${ip}|;s|%MBID|${mbid}|" "${destfile}"
      if [[ "${device}" == "meter" && $# -ge 6 ]]; then
        if [[ $serial == "NULL" ]]; then serial=""; fi
        if [[ $muser == "NULL" ]]; then muser=""; fi
        if [[ $mpass == "NULL" ]]; then mpass=""; fi
        sed -i "s|%SERIAL|${serial}|;s|%USER|${muser}|;s|%PASS|${mpass}|" "${destfile}"
      fi

      if [[ "${device}" == "pv" && "${default}" == "sofarsolar" ]]; then
        sed -i "s|%IP|${ip}|;s|%MODEL|${model}|;s|%SERIAL|${serial}|" "${destfile}"
      fi
    fi
  done


  if [[ "${device}" == "pv" ]]; then
    srcfile="${OPENHAB_CONF:-/etc/openhab}/icons/STORE/inverter/${2:-${invertertype}}.png"
    if [[ -f $srcfile ]]; then
      cp "$srcfile" "$inverterPNG"
    fi
    if [[ $(whoami) == "root" ]]; then
      chown "${username:-openhabian}:openhab" "$inverterPNG"
      chmod 664 "$inverterPNG"
    fi
  fi

  echo "OK"
  if [[ -n "$INTERACTIVE" ]]; then
    whiptail --title "Installation erfolgreich" --msgbox "Das Energie Management System nutzt jetzt eine ${2:-${invertertype}} Konfiguration." 8 80
  fi
}


## Generate/copy openHAB config for generic charger
## valid arguments:
## #1 IP address of charger actuator
## #2 user name to access Shelly actuator
## #3 password to access Shelly actuator
##
##    setup_charger(String charger actuator IP,String actuator user name,String actuator password)
##


# TBV: wie leere user/pass abfangen ?
setup_charger() {
  local thing=generisch.things
  local dir="${OPENHAB_CONF:-/etc/openhab}/things/"
  local srcfile="${dir}/STORE/${thing}"
  local destfile="${dir}/${thing}"
  local cuser
  local cpass


  cuser=${2:-${chargeractuatoruser}}
  if [[ $cuser == "NULL" ]]; then cuser=""; fi
  cpass=${3:-${chargeractuatorpass}}
  if [[ $cpass == "NULL" ]]; then cpass=""; fi

  #sed -e "s|%IP|${1:-${chargeractuatorip}}|;s|%USER|${2:-${chargeractuatoruser}}|;s|%PASS|${3:-${chargeractuatorpass}}|" "${srcfile}" > "${destfile}"
  sed -e "s|%IP|${1:-${chargeractuatorip}}|;s|%USER|${cuser}}|;s|%PASS|${cpass}|" "${srcfile}" > "${destfile}"
}


## Generate/copy openHAB config for whitegood appliances
## valid arguments:
## #1 Shelly actuator type (common to all white good actuators)
## #2 IP address of washing machine actuator
## #3 IP address of dish washer actuator
## #4 IP address of fridge actuator
## #5 IP address of freezer actuator
## #6 user name to access Shelly actuators (common to all white good actuators)
## #7 password to access Shelly actuators (common to all white good actuators)
##
##    setup_whitegood_config(String washing machine IP,String dish washer IP,String actuator user name,String actuator password)
##


# TBV: wie leere user/pass abfangen ?
setup_whitegood_config() {
  local dir
  local srcfile
  local destfile
  local wuser
  local wpass


  for component in things items rules; do
    dir="${OPENHAB_CONF:-/etc/openhab}/${component}/"
    srcfile="${dir}/STORE/weisseWare.${component}"
    destfile="${dir}/weisseWare.${component}"
    if [[ ${1:-${whitegoodactuator}} == "custom" && -f ${destfile} ]]; then
      break
    fi

    wuser=${6:-${whitegooduser}}
    if [[ $wuser == "NULL" ]]; then wuser=""; fi
    wpass=${7:-${whitegoodpass}}
    if [[ $wpass == "NULL" ]]; then wpass=""; fi

    # wird auch für weisseWare.rules ausgeführt
    sed -e "s|%ACTUATOR|${1:-${whitegoodactuator}}|;s|%IPW|${2:-${washingmachineip}}|;s|%IPS|${3:-${dishwasherip}}|;s|%IPK|${4:-${fridgeip}}|;s|%IPT|${5:-${freezerip}}|;s|%USER|${wuser}|;s|%PASS|${wpass}|" "${srcfile}" > "${destfile}"
  done
}



## Generate/copy openHAB config for a wallbox
## valid arguments:
##
## #1 wallbox type (from EVCC)
## abl cfos easee eebus evsewifi go-e go-e-v3 heidelberg keba mcc nrgkick-bluetooth nrgkick-connect
## openwb phoenix-em-eth phoenix-ev-eth phoenix-ev-ser simpleevse wallbe warp
## #2 IP address of wallbox
## #3 Wallbox Auth user
## #4 Wallbox Auth password
## #5 Wallbox ID z.B. SKI
## #6 EVCC token
## #7 car 1 type (from EVCC)
## audi bmw carwings citroen ds opel peugeot fiat ford kia hyundai mini nissan niu tesla
## renault ovms porsche seat skoda enyaq vw id volvo tronity
## #8 car 1 name
## #9 car 1 capacity
## #10 car 1 VIN Vehicle Identification Number
## #11 car 1 username in car manufacturer's online portal
## #12 car 1 password for account in car manufacturer's online portal
## #13 car 2 type (from EVCC)
## audi bmw carwings citroen ds opel peugeot fiat ford kia hyundai mini nissan niu tesla
## renault ovms porsche seat skoda enyaq vw id volvo tronity
## #14 car 2 name
## #15 car 2 capacity
## #16 car 2 VIN Vehicle Identification Number
## #17 car 2 username in car manufacturer's online portal
## #18 car 2 password for account in car manufacturer's online portal
## #19 grid usage cost per kWh in EUR ("0.40")
## #20 grid feedin compensation cost per kWh in EUR
## #21 excess power required to start charging 
## #22 max power to get from grid while charging 
##
##    setup_wb_config(String wallbox typ, .... )  - all arguments are of type String
##
setup_wb_config() {
  local temp
  local includesDir="${BASEDIR:-/opt/openhabian}/includes"
  local wallboxPNG="${OPENHAB_CONF:-/etc/openhab}/icons/classic/wallbox.png"
  local srcfile
  local destfile
  # shellcheck disable=SC2155
  local evccuser="$(systemctl show -pUser evcc | cut -d= -f2)"
  # shellcheck disable=SC2155
  local evccdir=$(eval echo "~${evccuser:-${username:-openhabian}}")
  local evccConfig="${evccdir}/evcc.yaml"


  function uncomment {
    if ! sed -e "/$1/s/^$1//g" -i "$2"; then echo "FAILED (uncomment)"; return 1; fi
  }


  if [[ -n "$UNATTENDED" ]]; then
    echo -n "$(timestamp) [storm.house] wallbox installation... "
    if [[ -z "${1:-$wallboxtype}" ]]; then echo "SKIPPED (no wallbox defined)"; return 1; fi
  fi

  if [[ -n "$INTERACTIVE" ]]; then
    if [[ -z "${1:-$wallboxtype}" ]]; then
      if ! wallboxtype="$(whiptail --title "Wallbox Auswahl" --cancel-button Cancel --ok-button Select --menu "\\nWählen Sie den Wallboxtyp aus" 12 80 0 "abl" "ABL eMH1" "go-e" "go-E Charger" "keba" "KEBA KeContact P20/P30 und BMW Wallboxen" "wbcustom" "manuelle Konfiguration" "demo" "Demo-Konfiguration mit zwei fake E-Autos" 3>&1 1>&2 2>&3)"; then unset wallboxtype wallboxip cartype1 carname1; return 1; fi
    fi
    if ! wallboxip=$(whiptail --title "Wallbox IP" --inputbox "Welche IP-Adresse hat die Wallbox ?" 10 60 "${wallboxip:-192.168.178.200}" 3>&1 1>&2 2>&3); then unset wallboxtype wallboxip cartype1 carname1; return 1; fi
    if ! cartype1="$(whiptail --title "Auswahl Autohersteller" --cancel-button Cancel --ok-button Select --menu "\\nWählen Sie den Hersteller Ihres Fahrzeugs aus" 12 80 0 "audi" "Audi" "bmw" "BMW" "carwings" "Nissan z.B. Leaf vor 2019" "citroen" "Citroen" "dacia" "Dacia" "ds" "DS" "opel" "Opel" "peugeot" "Peugeot" "fiat" "Fiat, Alfa Romeo" "ford" "Ford" "kia" "Kia Motors" "hyundai" "Hyundai" "mini" "Mini" "nissan" "neue Nissan Modelle ab 2019" "niu" "NIU" "tesla" "Tesla Motors" "renault" "Renault" "porsche" "Porsche" "seat" "Seat" "skoda" "Skoda Auto" "enyaq" "Skoda Enyac" "vw" "Volkswagen ausser ID-Modelle" "id" "Volkswagen ID-Modelle" "volvo" "Volvo" 3>&1 1>&2 2>&3)"; then unset wallboxtype wallboxip cartype1 carname1; return 1; fi
    if ! carname1=$(whiptail --title "Auto Modell" --inputbox "Automodell" 10 60 "${carname1:-tesla}" 3>&1 1>&2 2>&3); then unset wallboxtype wallboxip cartype1 carname1; return 1; fi
  fi

  for component in things items rules; do
    rm -f "${OPENHAB_CONF:-/etc/openhab}/${component}/wb.${component}"
    srcfile="${OPENHAB_CONF:-/etc/openhab}/${component}/STORE/${1:-${wallboxtype}}.${component}"
    destfile="${OPENHAB_CONF:-/etc/openhab}/${component}/wb.${component}"
    if [[ ${1:-${wallboxtype}} == "wbcustom" && -f ${destfile} ]]; then
      break
    fi
    if ! [[ -f ${srcfile} ]]; then
      srcfile="${OPENHAB_CONF:-/etc/openhab}/${component}/STORE/evcc.${component}"
    fi
    if [[ -f ${srcfile} ]]; then  # evcc.rules existiert ggfs. nicht
      cp "${srcfile}" "${destfile}"
      if [[ $(whoami) == "root" ]]; then
        chown "${username:-openhabian}:openhab" "${OPENHAB_CONF:-/etc/openhab}/${component}/wb.${component}"
        chmod 664 "${OPENHAB_CONF:-/etc/openhab}/${component}/wb.${component}"
      fi
    fi
  done

  srcfile="${OPENHAB_CONF:-/etc/openhab}/icons/STORE/wallbox/${1:-${wallboxtype}}.png"
  if [[ -f $srcfile ]]; then
    cp "$srcfile" "$wallboxPNG"
  fi
  if [[ $(whoami) == "root" ]]; then
    chown "${username:-openhabian}:openhab" "$wallboxPNG"
    chmod 664 "$wallboxPNG"
  fi

  token=${6:-${evcctoken}}
  if [[ $token = "NULL" ]]; then
    token=${evcctoken}
  fi
  temp="$(mktemp "${TMPDIR:-/tmp}"/evcc.XXXXX)"
  cp "${includesDir}/EVCC/evcc.yaml-template" "$temp"
  sed -e "s|%WBTYPE|${1:-${wallboxtype:-demo}}|;s|%IP|${2:-${wallboxip:-192.168.178.200}}|;s|%WBUSER|${3:-${wallboxuser}}|;s|%WBPASS|${4:-${wallboxpass}}|;s|%WBID|${5:-${wallboxid}}|;s|%TOKEN|${token}|;s|%CARTYPE1|${7:-${cartype1:-offline}}|;s|%CARNAME1|${8:-${carname1:-meinEAuto1}}|;s|%VIN1|${9:-${vin1:-0000000000}}|;s|%CARCAPACITY1|${10:-${carcapacity1:-50}}|;s|%CARUSER1|${11:-${caruser1:-user}}|;s|%CARPASS1|${12:-${carpass1:-pass}}|;s|%CARTYPE2|${13:-${cartype2:-offline}}|;s|%CARNAME2|${14:-${carname2:-meinEAuto2}}|;s|%VIN2|${15:-${vin2:-0000000000}}|;s|%CARCAPACITY2|${16:-${carcapacity2:-50}}|;s|%CARUSER2|${17:-${caruser2:-user}}|;s|%CARPASS2|${18:-${carpass2:-pass}}|;s|%GRIDCOST|${19:-${gridcost:-40}}|;s|%FEEDINCOMPENSATION|${20:-${feedincompensation:-8.2}}|;s|%CHARGEMINEXCESS|${21:-${chargeminexcess:-2000}}|;s|%CHARGEMAXGRID|${21:-${chargemaxgrid:-2000}}|" "$temp" | grep -Evi ': NULL$' > "$evccConfig"
  rm -f "${temp}"

  if ! grep -Eq "[[:space:]]certificate" "${evccConfig}"; then
    evcc eebus-cert -c "${evccConfig}" | tail +6 >> "$evccConfig"
  fi
  if [[ ${5:-${wallboxid}} != "" && ${5:-${wallboxid}} != "1234567890abcdef" ]] || [[ ${1:-${wallboxtype}} == "eebus" || ${1:-${wallboxtype}} == "elliconnect" || ${1:-${wallboxtype}} == "ellipro" ]]; then
    uncomment "#SKI" "${evccConfig}"
  fi
  if [[ ${3:-${wallboxuser}} != "" && ${3:-${wallboxuser}} != "NULL" ]]; then
    uncomment "#AUTHUSER" "${evccConfig}"
  fi
  if [[ ${4:-${wallboxpass}} != "" && ${4:-${wallboxpass}} != "NULL" ]]; then
    uncomment "#AUTHPASS" "${evccConfig}"
  fi
  if [[ ${1:-${wallboxtype}} == "demo" ]]; then
    rm -f "$evccConfig"
  fi

  echo "OK"
  if [[ -n "$INTERACTIVE" ]]; then
    whiptail --title "Installation erfolgreich" --msgbox "Das Energie Management System steuert jetzt eine ${1:-${wallboxtype}} Wallbox." 8 80
  fi
}


## setup OH config for electricity provider
##
## Valid Arguments:
##
## #1 tariff type: flat tibber awattar
## #2 base tariff (to add to dyn. price)
## #3 tariff homeID
## #4 tariff token
##
##    setup_power_config()
##
setup_power_config() {
  local temp
  local includesDir="${BASEDIR:-/opt/openhabian}/includes"
  local srcfile


  if [[ -n "$UNATTENDED" ]]; then
    echo -n "$(timestamp) [storm.house] power tariff setup ... "
    if [[ -z "${1:-$tarifftype}" ]]; then echo "SKIPPED (no power provider defined)"; return 1; fi
  fi
  if [[ -n "$INTERACTIVE" ]]; then
    if [[ -z "${1:-$tarifftype}" ]]; then
      if ! tarifftype="$(whiptail --title "Stromtarif Auswahl" --cancel-button Cancel --ok-button Select --menu "\\nWählen Sie den Stromtarif aus" 5 80 0 "flat" "normaler Stromtarif (flat)" "awattar" "aWATTar" "tibber" "Tibber" 3>&1 1>&2 2>&3)"; then unset tarifftype; return 1; fi
    fi
  fi

  for component in things items rules; do
    rm -f "${OPENHAB_CONF:-/etc/openhab}/${component}/netz.${component}"
    srcfile="${OPENHAB_CONF:-/etc/openhab}/${component}/STORE/tariffs/${1:-${tarifftype}}.${component}"
    destfile="${OPENHAB_CONF:-/etc/openhab}/${component}/netz.${component}"
    if [[ -f ${srcfile} ]]; then
      cp -p "${srcfile}" "${destfile}"
      if [[ $(whoami) == "root" ]]; then
        chown "${username:-openhabian}:openhab" "${OPENHAB_CONF:-/etc/openhab}/${component}/netz.${component}"
        chmod 664 "${OPENHAB_CONF:-/etc/openhab}/${component}/netz.${component}"
      fi
    fi
  done

  case "${1:-$tarifftype}" in
      tibber) sed -i "s|%HOMEID|${3:-${tariffhomeid}}|;s|%TOKEN|${4:-${tarifftoken}}|" "${OPENHAB_CONF:-/etc/openhab}/things/netz.things";;
      awattar) sed -i "s|%BASEPRICE|${2:-${basetariff}}|" "${OPENHAB_CONF:-/etc/openhab}/things/netz.things";;
  esac
  
  if [[ -n "$INTERACTIVE" ]]; then
    whiptail --title "Setup erfolgreich" --msgbox "Das Energie Management System nutzt jetzt einen ${2:-${tarifftype}} Stromtarif." 8 80
  fi
}


## setup OH config for heat pump selection
##
## Valid Arguments:
##
## #1 heat pump model
##
##    setup_hp_config()
##
setup_hp_config() {
  local temp
  local includesDir="${BASEDIR:-/opt/openhabian}/includes"
  local srcfile
  local muser
  local mpass


  if [[ -n "$UNATTENDED" ]]; then
    echo -n "$(timestamp) [storm.house] heat pump setup ... "
    if [[ -z "${1:-$heatpumptype}" ]]; then echo "SKIPPED (no heat pump model defined)"; return 1; fi
  fi

  for component in things items rules; do
    rm -f "${OPENHAB_CONF:-/etc/openhab}/${component}/heizung.${component}"
    srcfile="${OPENHAB_CONF:-/etc/openhab}/${component}/STORE/wp/${1:-${heatpumptype}}.${component}"
    destfile="${OPENHAB_CONF:-/etc/openhab}/${component}/heizung.${component}"
    if [[ -f ${srcfile} ]]; then
      cp -p "${srcfile}" "${destfile}"
      if [[ $(whoami) == "root" ]]; then
        chown "${username:-openhabian}:openhab" "${OPENHAB_CONF:-/etc/openhab}/${component}/heizung.${component}"
        chmod 664 "${OPENHAB_CONF:-/etc/openhab}/${component}/heizung.${component}"
      fi
    fi
  done

  muser=${6:-${heatpumpuser}}
  if [[ $muser == "NULL" ]]; then muser=""; fi
  mpass=${7:-${heatpumppass}}
  if [[ $mpass == "NULL" ]]; then mpass=""; fi
  #sed -i "s|%IP|${2:-${heatpumpip}}|;s|%MBID|${3:-${heatpumpmodbusid:-1}}|;s|%RELAY|${4:-${sgractuator:-shelly25-relay}}|;s|%USER|${muser}|;s|%PASS|${mpass}|" "${OPENHAB_CONF:-/etc/openhab}/things/heizung.things"
  sed -i "s|%IP|${2:-${heatpumpip}}|;s|%PORT|${3:-${heatpumpport:-8889}}|;s|%MBID|${4:-${heatpumpmodbusid:-1}}|;s|%RELAY|${5:-${sgractuator:-shelly25-relay}}|;s|%USER|${muser}|;s|%PASS|${mpass}|" "${OPENHAB_CONF:-/etc/openhab}/things/heizung.things"
  sed -i "s|%RELAY|${5:-${sgractuator:-shelly25-relay}}|" "${OPENHAB_CONF:-/etc/openhab}/items/heizung.items"
}


## setup OH config for heat pump selection
##
## Valid Arguments:
##
## #1 azimuth
## #2 declination
## #3 kWp
##
##    setup_forecastsolar()
##
setup_forecastsolar() {
  local thing=forecastsolar.things
  local dir="${OPENHAB_CONF:-/etc/openhab}/things/"
  local srcfile="${dir}/STORE/vorhersage/${thing}"
  local destfile="${dir}/${thing}"


  sed -e "s|%AZIMUTH|${1:-${azimuth}}|;s|%DECLINATION|${2:-${declination}}|;s|%KWP|${3:-${kwp}}|" "${srcfile}" > "${destfile}"
}


## replace OH logo
## Attention needs to work across versions, logo has to be SVG (use inkscape to embed PNG in SVG)
##
##    replace_logo()
##
replace_logo() {
  local JAR
  # shellcheck disable=SC2125
  local logoInJAR=app/images/openhab-logo.svg
  local logoNew="${BASEDIR:-/opt/openhabian}/includes"/logo.svg


  # shellcheck disable=SC2012
  JAR=$(ls -1t /usr/share/openhab/runtime/system/org/openhab/ui/bundles/org.openhab.ui/*/org.openhab.ui-*|sort -ru|head -1)
  rm -rf "$logoInJAR"
  # shellcheck disable=SC2086
  unzip -qq $JAR "$logoInJAR"
  cp "$logoNew" "$logoInJAR"
  # shellcheck disable=SC2086
  if ! cond_redirect zip -r $JAR "$logoInJAR"; then echo "FAILED (replace logo)"; fi
  rm -rf "$logoInJAR"
}


## Install non-standard bindings etc
##
##    install_extras()
##
install_extras() {
  # shellcheck disable=SC2034
  local consoleProperties="${OPENHAB_USERDATA:-/var/lib/openhab}/etc/org.apache.karaf.shell.cfg"
  local includesDir="${BASEDIR:-/opt/openhabian}/includes"
  local deckey="/etc/ssl/private/ems.key"
  local entsoeJAR=org.openhab.binding.entsoe-4.0.5-SNAPSHOT.jar
  local solarmanJAR=org.openhab.binding.solarman-0.3.2.jar
  #local entsoePKG="https://github.com/gitMiguel/openhab-addons/releases/download/EntsoE-4.1.0-SNAPTSHOT/${entsoeJAR}"
  local solarmanPKG="https://github.com/catalinsanda/org.openhab.binding.solarman/releases/download/v0.3.2/${solarmanJAR}"
  local destdir="/usr/share/openhab/addons/"
  local sudoersFile="011_ems"
  local sudoersPath="/etc/sudoers.d"
  local addonsCfg="${OPENHAB_CONF:-/etc/openhab}/services/addons.cfg"


  if [[ $(whoami) == "root" ]]; then
    if [[ ! -f /usr/local/sbin/upgrade_ems ]]; then
      if ! cond_redirect ln -fs "${includesDir}/setup_ems_hw" /usr/local/sbin/upgrade_ems; then echo "FAILED (install upgrade_ems script)"; fi
    fi
    if [[ ! -f /usr/local/sbin/setup_pv_config ]]; then
      if ! cond_redirect ln -fs "${includesDir}/setup_ems_hw" /usr/local/sbin/setup_pv_config; then echo "FAILED (install setup_pv_config script)"; return 1; fi
    fi
    if [[ ! -f /usr/local/sbin/setup_wb_config ]]; then
      if ! cond_redirect ln -fs "${includesDir}/setup_ems_hw" /usr/local/sbin/setup_wb_config; then echo "FAILED (install setup_wb_config script)"; return 1; fi
    fi
    if [[ ! -f /usr/local/sbin/setup_power_config ]]; then
      if ! cond_redirect ln -fs "${includesDir}/setup_ems_hw" /usr/local/sbin/setup_power_config; then echo "FAILED (install setup_power_config script)"; return 1; fi
    fi
    if [[ ! -f /usr/local/sbin/setup_charger ]]; then
      if ! cond_redirect ln -fs "${includesDir}/setup_ems_hw" /usr/local/sbin/setup_charger; then echo "FAILED (install setup_charger script)"; return 1; fi
    fi
    if [[ ! -f /usr/local/sbin/setup_whitegood_config ]]; then
      if ! cond_redirect ln -fs "${includesDir}/setup_ems_hw" /usr/local/sbin/setup_whitegood_config; then echo "FAILED (install setup_whitegood_config script)"; return 1; fi
    fi
    if [[ ! -f /usr/local/sbin/setup_hp_config ]]; then
      if ! cond_redirect ln -fs "${includesDir}/setup_ems_hw" /usr/local/sbin/setup_hp_config; then echo "FAILED (install setup_hp_config script)"; return 1; fi
    fi
    if [[ ! -f /usr/local/sbin/setup_forecastsolar ]]; then
      if ! cond_redirect ln -fs "${includesDir}/setup_ems_hw" /usr/local/sbin/setup_forecastsolar; then echo "FAILED (install setup_forecastsolar script)"; return 1; fi
    fi
  fi

  cond_redirect install -m 640 "${BASEDIR:-/opt/openhabian}/includes/${sudoersFile}" "${sudoersPath}/"

  if ! cond_redirect wget -nv -O "${destdir}/${solarmanJAR}" "${solarmanPKG}"; then echo "FAILED (download inofficial solarman binding)"; rm -f "${destdir}/${solarmanJAR}"; fi
  if ! cond_redirect install -m 644 --owner="${username:-admin}" --group="${groupname:-openhab}" "${BASEDIR:-/opt/openhabian}"/includes/JARs/${entsoeJAR} ${destdir}/${entsoeJAR}; then echo "FAILED (Entso-E jar)"; return 1; fi

  cond_redirect install -m 644 "${includesDir}/openhab_rsa.pub" "${OPENHAB_USERDATA:-/var/lib/openhab}/etc/"
  cond_redirect install -m 600 "${includesDir}/openhab_rsa" "${OPENHAB_USERDATA:-/var/lib/openhab}/etc/"
  cond_redirect chown "${username:-openhabian}:openhab" "${OPENHAB_USERDATA:-/var/lib/openhab}/etc/openhab_rsa*"
  cond_redirect install -m 640 "${includesDir}/generic/ems.key" $deckey

  (echo suggestionFinderIp=false; echo suggestionFinderMdns=false; echo suggestionFinderUpnp=false) >> "${addonsCfg}"
}


## Retrieve latest EMS code from website
##
##    upgrade_ems(String full)
##
## Valid Arguments:
## #1: full = OH-Konfiguration ersetzen inkl. JSONDB (UI u.a.)
##     codeonly = nur things/items/rules ersetzen
##
upgrade_ems() {
  local tempdir
  local temp
  local fullpkg=https://storm.house/download/initialConfig.zip
  local updateonly=https://storm.house/download/latestUpdate.zip
  local introText="ACHTUNG\\n\\nWenn Sie eigene Änderungen auf der Ebene von openHAB vorgenommen haben (die \"orangene\" Benutzeroberfläche),dann wählen Sie \"Änderungen beibehalten\". Dieses Update würde alle diese Änderungen ansonsten überschreiben, sie wäre verloren.\\nIhre Einstellungen und historischen Daten bleiben in beiden Fällen erhalten und vor dem Update wird ein Backup der aktuellen Konfiguration erstellt. Sollten Sie das Upgrade rückgängig machen wollen, können Sie jederzeit über den Menüpunkt 51 die Konfiguration des EMS von vor dem Update wieder einspielen."
  local TextVoll="ACHTUNG:\\nWollen Sie wirklich die Konfiguration vollständig durch die aktuelle Version des EMS ersetzen?\\nAlles, was Sie über Einstellungen in der grafische Benutzeroberfläche hinausgehend verändert haben, geht dann verloren. Das betrifft beispielsweise - aber nicht nur - alle Things, Items und Regeln, die Sie selbst angelegt haben."
  local TextTeil="ACHTUNG:\\nWollen Sie das EMS bzw. den von storm.house bereitgestellten Teil Ihres EMS wirklich durch die aktuelle Version ersetzen?"

  tempdir="$(mktemp -d "${TMPDIR:-/tmp}"/updatedir.XXXXX)"
  temp="$(mktemp "${tempdir:-/tmp}"/updatefile.XXXXX)"
  echo  backup_openhab_config

  # user credentials retten
  cp "${OPENHAB_USERDATA:-/var/lib/openhab}/jsondb/users.json" "${tempdir}/"
  # Settings retten
  cp -rp "${OPENHAB_USERDATA:-/var/lib/openhab}/persistence/mapdb" "${tempdir}/"

  # Abfrage ob Voll- oder Teilimport mit Warnung dass eigene Änderungen überschrieben werden
  mode=${1}
  if [[ -n "$INTERACTIVE" ]]; then
    if whiptail --title "EMS Update" --yes-button "komplettes Update" --no-button "Änderungen beibehalten" --yesno "$introText" 17 80; then
      if ! whiptail --title "EMS komplettes Update" --yes-button "JA, DAS WILL ICH" --cancel-button "Abbrechen" --defaultno --yesno "$TextVoll" 13 80; then echo "CANCELED"; return 1; fi
      mode=full
    else
      if ! whiptail --title "EMS Update" --yes-button "Ja" --cancel-button "Abbrechen" --defaultno --yesno "$TextTeil" 10 80; then echo "CANCELED"; return 1; fi
      mode=codeonly
    fi
  fi

  if [[ "$mode" == "full" ]]; then
    if ! cond_redirect wget -nv -O "$temp" "$fullpkg"; then echo "FAILED (download EMS package)"; rm -f "$temp"; return 1; fi
    restore_openhab_config "$temp"
  else
    if ! cond_redirect wget -nv -O "$temp" "$updateonly"; then echo "FAILED (download EMS patch)"; rm -f "$temp"; return 1; fi
    ( cd /etc/openhab || return 1
    ln -sf . conf
    unzip -o "$temp" conf/things\* conf/items\* conf/rules\* conf/transform\* conf/UI\* conf/html\* conf/scripts\*
    rm -f conf )
  fi

  # user credentials und Settings zurückspielen
  cp "${tempdir}/users.json" "${OPENHAB_USERDATA:-/var/lib/openhab}/jsondb/"
  cp -rp "${tempdir}/mapdb" "${OPENHAB_USERDATA:-/var/lib/openhab}/persistence/"
  cp "${includesDir}/inmemory.persist" "${OPENHAB_USERDATA:-/var/lib/openhab}/persistence/"
  if [[ -d /opt/zram/persistence.bind/mapdb ]]; then
    cp -rp "${tempdir}/mapdb" /opt/zram/persistence.bind/
  fi

  install_extras
  openhab_shell_interfaces
  permissions_corrections   # sicherheitshalber falls Dateien durch git nicht mehr openhab gehören

  if [[ -n "$INTERACTIVE" ]]; then
    whiptail --title "EMS update erfolgreich" --msgbox "Das storm.house Energie Management System ist jetzt auf dem neuesten Stand." 8 80
  fi

  echo "OK"
  rm -rf "${tempdir}"
}


##    finalize_setup
##
finalize_setup() {
  local serviceTargetDir="/etc/systemd/system"
  local includesDir="${BASEDIR:-/opt/openhabian}/includes"


  # shellcheck disable=SC2155
  local evccuser="$(systemctl show -pUser evcc | cut -d= -f2)"
  # shellcheck disable=SC2155
  local evccdir=$(eval echo "~${evccuser:-${username:-openhabian}}")
  local oldYaml="${OPENHAB_USERDATA:-/var/lib/openhab}/evcc.yaml"
  local passwdCommand="/usr/bin/ssh -p 8101 -o StrictHostKeyChecking=no -i /var/lib/openhab/etc/openhab_rsa openhab@localhost users changePassword admin ${userpw:-admin}"
  local passwdCommand2="/usr/bin/ssh -p 8101 -o StrictHostKeyChecking=no -i /var/lib/openhab/etc/openhab_rsa openhab@localhost users add demo demo user"


  rm -f "${oldYaml}"	# um Verwechslungen vorzubeugen
  ln -s "${evccdir}/evcc.yaml" "${oldYaml}"
  cond_redirect chmod g+w "$evccdir"

  # Pakete dürfen beim apt upgrade nicht auf die neuesten Versionen aktualisiert werden
  cond_redirect apt-mark hold openhab openhab-addons evcc

  # shellcheck disable=SC2046
  cond_redirect $(${passwdCommand})
  # shellcheck disable=SC2046
  cond_redirect $(${passwdCommand2})

  # lc Lizenzgedöns
  if ! cond_redirect install -m 644 -t "${serviceTargetDir}" "${includesDir}"/generic/lc.timer; then rm -f "$serviceTargetDir"/lc.{service,timer}; echo "FAILED (setup lc)"; return 1; fi
  if ! cond_redirect install -m 644 -t "${serviceTargetDir}" "${includesDir}"/generic/lc.service; then rm -f "$serviceTargetDir"/lc.{service,timer}; echo "FAILED (setup lc)"; return 1; fi
  if ! cond_redirect install -m 755 "${includesDir}/generic/lc" /usr/local/sbin; then echo "FAILED (install lc)"; fi
  if ! cond_redirect ln -s /usr/bin/openssl /usr/local/sbin/openssl11; then echo "FAILED (link openssl binary)"; fi
  if ! cond_redirect systemctl -q daemon-reload; then echo "FAILED (daemon-reload)"; return 1; fi
  if ! cond_redirect systemctl enable --now lc.timer lc.service; then echo "FAILED (enable timed lc start)"; fi
}


##    set_lic(String state)
##
set_lic() {
  curl -X POST --header "Content-Type: text/plain" --header "Accept: application/json" -d "$1" "http://localhost:8080/rest/items/LizenzStatus"
}


##    ems_lic(String enable)
##
## * enable|disable
##
ems_lic() {
  local licfile="/etc/openhab/services/license"
  local disablerTimer=lcban
  local disableCommand="/usr/bin/ssh -p 8101 -o StrictHostKeyChecking=no -i /var/lib/openhab/etc/openhab_rsa openhab@localhost bundle:stop org.openhab.binding.modbus"
  local enableCommand="/usr/bin/ssh -p 8101 -o StrictHostKeyChecking=no -i /var/lib/openhab/etc/openhab_rsa openhab@localhost bundle:start org.openhab.binding.modbus"
  local gracePeriod=$((30 * 86400))
  gracePeriod=60


  if [[ $1 == "enable" ]]; then
    echo "Korrekte Lizenz, aktiviere ..."
    set_lic "lizensiert"
    # shellcheck disable=SC2046
    cond_redirect $(${enableCommand})
    cond_redirect systemctl stop ${disablerTimer}
  else
    echo "Falsche Lizenz, deaktiviere ..."
    set_lic "DEAKTIVIERT - keine Lizenz"
    # shellcheck disable=SC2086
    cond_redirect systemd-run --unit ${disablerTimer} --on-active=${gracePeriod} --timer-property=AccuracySec=100ms ${disableCommand}
  fi

  # da sonst lc.service fehlschlägt, wenn der letzte Befehl fehlschlägt (passiert meist beim Stoppen von lcban.service weil der nicht immer existiert)
  return 0
}


## Retrieve licensing file from server
## valid arguments: username, password
## Webserver will return an self-encrypted script to contain file with the evcc sponsorship token
##
##    retrieve_license(String username, String password)
##
retrieve_license() {
  local licsrc="https://storm.house/licchk"
  local temp
  #local deckey="/etc/openhab/services/ems.key"
  local deckey="/etc/ssl/private/ems.key"
  local lifetimekey="lifetime"
  local licuser=${1}
  local licfile="/etc/openhab/services/license"
  local httpuser=dummyuser
  local httppass=dummypass
  local licdir


  if [[ $licuser == "" ]]; then
    licuser=$(curl -X GET  http://localhost:8080/rest/items/LizenzUser|jq '.state' | tr -d '"')
  fi
  licdir="$(mktemp -d "${TMPDIR:-/tmp}"/lic.XXXXX)"
  ( cd "$licdir" || exit; 
  if ! cond_redirect wget -nv --http-user="${httpuser}" --http-password="${httppass}" "${licsrc}/${licuser}-LIC"; then echo "FAILED (download licensing file)"; rm -f "$licuser"; return 1; fi
  if [[ -f "${licuser}-LIC" ]]; then
    # decrypten mit public Key der dazu in includes liegen muss
    # XOR mitgeliefert ist (durch rsaCrypt)
    mv "${licuser}-LIC" "${licuser}.enc.sh"
    chmod +x "${licuser}.enc.sh"
    # shellcheck disable=SC2091
    $(./"${licuser}.enc.sh" -i "$deckey")
    cp "${licuser}" "${licfile}"
  fi
  )

  if grep -qs "^sponsortoken:[[:space:]]" "$licfile"; then
    token=$(grep -E '^evcctoken' "$licfile" |cut -d' '  -f2)
    curl -X POST --header "Content-Type: text/plain" --header "Accept: application/json" -d "$token" "http://{hostname}:8080/rest/items/EVCCtoken"
  fi

  # wenn licfile im laufenden Monat heruntergeladen wird muss darin (nach Entschlüsseln) der 
  lic=$(grep -E '^emsuser' "$licfile" |cut -d' '  -f2)
  if [[ "$lic" != "$licuser" && "$lic" != "$lifetimekey" ]]; then
    ems_lic disable
  else
    ems_lic enable
  fi
}

