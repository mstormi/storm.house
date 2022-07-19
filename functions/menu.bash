#!/usr/bin/env bash

show_about() {
  if openhab3_is_installed; then OHPKG="openhab"; else OHPKG="openhab2"; fi
  whiptail --title "About storm.house and this tool" --msgbox "storm.house Configuration Tool $(get_git_revision)
openHAB $(sed -n 's/openhab-distro\s*: //p' "/var/lib/${OHPKG}/etc/version.properties") - $(sed -n 's/build-no\s*: //p' "/var/lib/${OHPKG}/etc/version.properties")
\\nThis Energy Management System is based on openHAB 3.3.0 (Release) and supports EVCC.\\n
Menu 40 to select the standard release, milestone or very latest development version of openHAB and
Menu 02 will upgrade all of your OS and applications to the latest versions, including openHAB.
Menu 10 provides a number of system tweaks. These are already active after a standard installation while
Menu 30 allows for changing system configuration to match your hardware.
Note that the raspi-config tool was intentionally removed to not interfere with this config tool.
Menu 50 provides options to backup and restore either your openHAB configuration or the whole system.
\\nVisit these sites for more information:
  - Documentation: https://www.openhab.org/docs/installation/openhabian.html
  - Discussion: https://community.openhab.org/t/13379" 25 116
  RET=$?
  if [ $RET -eq 255 ]; then
    # <Esc> key pressed.
    return 0
  fi
}

show_main_menu() {
  local choice
  local version

  choice=$(whiptail --title "storm.house Configuration Tool $(get_git_revision)" --menu "Setup Options" 20 116 13 --cancel-button Exit --ok-button Execute \
  "00 | About smart-house"       "Information about this tool ($(basename "$0"))" \
  "" "" \
  "02 | Upgrade System"          "Upgrade all installed software packages (incl. openHAB) to their latest version" \
  "03 | Update EMS"              "Update EMS to latest version" \
  "04 | Import config"           "Import an openHAB 3 configuration from file or URL" \
  "05 | Setup storm.house EMS"   "Setup storm.house Energy Management System" \
  "" "" \
  "10 | Apply Improvements"      "Apply the latest improvements to the basic setup ►" \
  "20 | Optional Components"     "Choose from a set of optional software components ►" \
  "30 | System Settings"         "A range of system and hardware related configuration steps ►" \
  "40 | openHAB Related"         "Switch the installed openHAB version or apply tweaks ►" \
  "50 | Backup/Restore"          "Manage backups and restore your system ►" \
  3>&1 1>&2 2>&3)
  RET=$?
  if [ $RET -eq 1 ] || [ $RET -eq 255 ]; then
    # "Exit" button selected or <Esc> key pressed two times
    return 255
  fi

  if [[ "$choice" == "" ]]; then
    true

  elif [[ "$choice" == "00"* ]]; then
    show_about

  elif [[ "$choice" == "01"* ]]; then
    openhabian_update

  elif [[ "$choice" == "02"* ]]; then
    wait_for_apt_to_finish_update
    system_upgrade
    update_ems
    replace_logo

  elif [[ "$choice" == "03"* ]]; then
    update_ems
    replace_logo

  elif [[ "$choice" == "04"* ]]; then
    import_openhab_config

  elif [[ "$choice" == "05"* ]]; then
    setup_pv_config
    setup_wb_config

  elif [[ "$choice" == "06"* ]]; then
    update_ems

  elif [[ "$choice" == "10"* ]]; then
<<<<<<< HEAD
    choice2=$(whiptail --title "openHABian Configuration Tool — $(get_git_revision)" --menu "Apply Improvements" 24 118 16 --cancel-button Back --ok-button Execute \
=======
    choice2=$(whiptail --title "storm.house Configuration Tool $(get_git_revision)" --menu "Apply Improvements" 13 116 6 --cancel-button Back --ok-button Execute \
>>>>>>> 3da582e0 (openhabian-config -> smart-house-config)
    "11 | Packages"               "Install needed and recommended system packages" \
    "12 | Bash&Vim Settings"      "Update customized settings for bash, vim and nano" \
    "13 | System Tweaks"          "Add /srv mounts and update settings typical for openHAB" \
    "14 | Fix Permissions"        "Update file permissions of commonly used files and folders" \
    "15 | FireMotD"               "Upgrade the program behind the system overview on SSH login" \
    "16 | Samba"                  "Install the Samba file sharing service and set up openHAB shares" \
    3>&1 1>&2 2>&3)
    if [ $? -eq 1 ] || [ $? -eq 255 ]; then return 0; fi
    wait_for_apt_to_finish_update
    case "$choice2" in
      11\ *) basic_packages && needed_packages ;;
      12\ *) bashrc_copy && vimrc_copy && vim_openhab_syntax && nano_openhab_syntax && multitail_openhab_scheme ;;
      13\ *) srv_bind_mounts && misc_system_settings ;;
      14\ *) permissions_corrections ;;
      15\ *) firemotd_setup ;;
      16\ *) samba_setup ;;
      "") return 0 ;;
      *) whiptail --msgbox "An unsupported option was selected (probably a programming error):\\n  \"$choice2\"" 8 80 ;;
    esac

  elif [[ "$choice" == "20"* ]]; then
<<<<<<< HEAD
    choice2=$(whiptail --title "openHABian Configuration Tool — $(get_git_revision)" --menu "Optional Components" 24 118 16 --cancel-button Back --ok-button Execute \
=======
    choice2=$(whiptail --title "storm.house Configuration Tool $(get_git_revision)" --menu "Optional Components" 25 118 18 --cancel-button Back --ok-button Execute \
>>>>>>> 3da582e0 (openhabian-config -> smart-house-config)
    "21 | Log Viewer"             "openHAB Log Viewer webapp (frontail)" \
    "   | Add log to viewer"      "Add a custom log to openHAB Log Viewer (frontail)" \
    "   | Remove log from viewer" "Remove a custom log from openHAB Log Viewer (frontail)" \
    "22 | miflora-mqtt-daemon"    "Xiaomi Mi Flora Plant Sensor MQTT Client/Daemon" \
    "23 | Mosquitto"              "MQTT broker Eclipse Mosquitto" \
    "24 | InfluxDB+Grafana"       "A powerful persistence and graphing solution" \
    "25 | Node-RED"               "Flow-based programming for the Internet of Things" \
    "26 | Homegear"               "Homematic specific, the CCU2 emulation software Homegear" \
    "27 | knxd"                   "KNX specific, the KNX router/gateway daemon knxd" \
    "28 | 1wire"                  "1wire specific, owserver and related packages" \
    "29 | deCONZ"                 "deCONZ / Phoscon companion app for Conbee/Raspbee controller" \
    "2A | Zigbee2MQTT"            "Install or Update Zigbee2MQTT" \
    "   | Remove Zigbee2MQTT"     "Remove Zigbee2MQTT from this system" \
    "2B | FIND 3"                 "Framework for Internal Navigation and Discovery" \
    "   | Monitor Mode"           "Patch firmware to enable monitor mode (ALPHA/DANGEROUS)" \
    "2C | Install HABApp"         "Python 3 integration and rule engine for openHAB" \
    "   | Remove HABApp"          "Remove HABApp from this system" \
    "2D | Install EVCC"           "Deploy Electric Vehicle Charge Controller" \
    "   | Remove EVCC"            "Uninstall EVCC" \
    "   | Setup EVCC"             "Setup EVCC from command line (German only)" \
    3>&1 1>&2 2>&3)
    if [ $? -eq 1 ] || [ $? -eq 255 ]; then return 0; fi
    wait_for_apt_to_finish_update
    case "$choice2" in
      21\ *) frontail_setup;;
      *Add\ log\ to\ viewer*) custom_frontail_log "add";;
      *Remove\ log\ from\ viewer*) custom_frontail_log "remove";;
      22\ *) miflora_setup ;;
      23\ *) mqtt_setup ;;
      24\ *) influxdb_grafana_setup ;;
      25\ *) nodered_setup ;;
      26\ *) homegear_setup ;;
      27\ *) knxd_setup ;;
      28\ *) 1wire_setup ;;
      29\ *) deconz_setup ;;
      2A\ *) zigbee2mqtt_setup "install";;
      *Remove\ Zigbee2MQTT*) zigbee2mqtt_setup "remove";;      
      2B\ *) find3_setup ;; 
      *Monitor\ Mode) setup_monitor_mode ;;
      2C\ *) habapp_setup "install";;
      *Remove\ HABApp*) habapp_setup "remove";;
      2D\ *) install_evcc "install";;
      *Remove\ EVCC*) install_evcc "remove";;
      *Setup\ EVCC*) setup_evcc;;
      "") return 0 ;;
      *) whiptail --msgbox "An unsupported option was selected (probably a programming error):\\n  \"$choice2\"" 8 80 ;;
    esac

  elif [[ "$choice" == "30"* ]]; then
<<<<<<< HEAD
    choice2=$(whiptail --title "openHABian Configuration Tool — $(get_git_revision)" --menu "System Settings" 24 118 16 --cancel-button Back --ok-button Execute \
=======
    choice2=$(whiptail --title "storm.house Configuration Tool $(get_git_revision)" --menu "System Settings" 24 118 17 --cancel-button Back --ok-button Execute \
>>>>>>> 3da582e0 (openhabian-config -> smart-house-config)
    "31 | Change hostname"        "Change the name of this system, currently '$(hostname)'" \
    "32 | Set system locale"      "Change system language, currently '$(env | grep "^[[:space:]]*LANG=" | sed 's|LANG=||g')'" \
    "33 | Set system timezone"    "Change your timezone, execute if it's not '$(printf "%(%H:%M)T\\n" "-1")' now" \
    "   | Enable NTP"             "Enable time synchronization via systemd-timesyncd to NTP servers" \
    "   | Disable NTP"            "Disable time synchronization via systemd-timesyncd to NTP servers" \
    "34 | Change passwords"       "Change passwords for Samba, openHAB Console or the system user" \
    "35 | Serial port"            "Prepare serial ports for peripherals like RaZberry, ZigBee adapters etc" \
    "36 | Disable framebuffer"    "Disable framebuffer on RPi to minimize memory usage" \
    "   | Enable framebuffer"     "Enable framebuffer (standard setting)" \
    "37 | WiFi setup"             "Configure wireless network connection" \
    "   | Disable WiFi"           "Disable wireless network connection" \
    "38 | Use zram"               "Use compressed RAM/disk sync for active directories to avoid SD card corruption" \
    "   | Update zram"            "Update a currently installed zram instance" \
    "   | Uninstall zram"         "Don't use compressed memory (back to standard Raspberry Pi OS filesystem layout)" \
    "39 | Move root to USB"       "Move the system root from the SD card to a USB device (SSD or stick)" \
    "3A | Setup Exim Mail Relay"  "Install Exim4 to relay mails via public email provider" \
    "3B | Setup Tailscale VPN"    "Establish or join a WireGuard based VPN using the Tailscale service" \
    "   | Remove Tailscale VPN"   "Remove the Tailscale VPN service" \
    "   | Install WireGuard"      "Setup WireGuard to enable secure remote access to this system" \
    "   | Remove WireGuard"       "Remove WireGuard VPN from this system" \
    "3C | Setup UPS (nut)"        "Setup a Uninterruptable Power Supply for this system using Network UPS Tools" \
    3>&1 1>&2 2>&3)
    if [ $? -eq 1 ] || [ $? -eq 255 ]; then return 0; fi
    wait_for_apt_to_finish_update
    case "$choice2" in
      31\ *) hostname_change ;;
      32\ *) locale_setting ;;
      33\ *) timezone_setting ;;
      *Enable\ NTP) setup_ntp "enable" ;;
      *Disable\ NTP) setup_ntp "disable" ;;
      34\ *) change_password ;;
      35\ *) prepare_serial_port ;;
      36\ *) use_framebuffer "disable" ;;
      *Enable\ framebuffer) use_framebuffer "enable" ;;
      37\ *) configure_wifi setup ;;
      *Disable\ WiFi) configure_wifi "disable" ;;
      38\ *) init_zram_mounts "install" ;;
      *Update\ zram) init_zram_mounts ;;
      *Uninstall\ zram) init_zram_mounts "uninstall" ;;
      39\ *) move_root2usb ;;
      3A\ *) exim_setup ;;
      3B\ *) if install_tailscale install; then setup_tailscale; fi;;
      *Remove\ Tailscale*) install_tailscale remove;;
      *Install\ WireGuard*) if install_wireguard install; then setup_wireguard; fi;;
      *Remove\ WireGuard*) install_wireguard remove;;
      3C\ *) nut_setup ;;
      "") return 0 ;;
      *) whiptail --msgbox "An unsupported option was selected (probably a programming error):\\n  \"$choice2\"" 8 80 ;;
    esac

  elif [[ "$choice" == "40"* ]]; then
    choice2=$(whiptail --title "openHABian Configuration Tool — $(get_git_revision)" --menu "openHAB Related" 24 118 16 --cancel-button Back --ok-button Execute \
    "41 | openHAB Release"                "Install or switch to the latest openHAB Release" \
    "   | openHAB Milestone"              "Install or switch to the latest openHAB Milestone Build" \
    "   | openHAB Snapshot"               "Install or switch to the latest openHAB Snapshot Build" \
    "42 | Upgrade to openHAB 3"           "Upgrade OS environment to openHAB 3 release" \
    "   | Downgrade to openHAB 2"         "Downgrade OS environment from openHAB 3 back to openHAB 2 (DANGEROUS)" \
    "43 | Remote Console"                 "Bind the openHAB SSH console to all external interfaces" \
    "44 | Nginx Proxy"                    "Setup reverse and forward web proxy" \
    "45 | OpenJDK 11"                     "Install and activate OpenJDK 11 as Java provider (default)" \
    "   | OpenJDK 17"                     "Install and activate OpenJDK 17 as Java provider" \
    "   | Zulu 11 OpenJDK 32-bit"         "Install Zulu 11 32-bit OpenJDK as Java provider" \
    "   | Zulu 11 OpenJDK 64-bit"         "Install Zulu 11 64-bit OpenJDK as Java provider" \
    "46 | Install openhab-js"             "JS Scripting: Upgrade to latest version of openHAB JavaScript library (advanced)" \
    "   | Uninstall openhab-js"           "JS Scripting: Switch back to included version of openHAB JavaScript library" \
    "47 | Install openhab_rules_tools"    "JS Scripting: Manually install openhab_rules_tools (auto-installed)" \
    "   | Uninstall openhab_rules_tools"  "JS Scripting: Uninstall openhab_rules_tools" \
    3>&1 1>&2 2>&3)
    if [ $? -eq 1 ] || [ $? -eq 255 ]; then return 0; fi
    wait_for_apt_to_finish_update
    version="$(openhab3_is_installed && echo "openHAB3" || echo "openHAB2")"
    # shellcheck disable=SC2154
    case "$choice2" in
      41\ *) openhab_setup "$version" "stable"; replace_logo;;
      *openHAB\ Milestone) openhab_setup "$version" "testing"; replace_logo;;
      *openHAB\ Snapshot) openhab_setup "$version" "unstable"; replace_logo;;
      42\ *) migrate_installation "openHAB3" && openhabian_update "openHAB3";;
      *Downgrade\ to\ openHAB\ 2) migrate_installation "openHAB2" && openhabian_update "stable";;
      43\ *) openhab_shell_interfaces;;
      44\ *) nginx_setup;;
      *OpenJDK\ 11) update_config_java "11" && java_install "11";;
      *OpenJDK\ 17) update_config_java "17" && java_install "17";;
      *Zulu\ 11\ OpenJDK\ 32-bit) update_config_java "Zulu11-32" && java_install_or_update "Zulu11-32";;
      *Zulu\ 11\ OpenJDK\ 64-bit) update_config_java "Zulu11-64" && java_install_or_update "Zulu11-64";;
      46\ *) jsscripting_npm_install "openhab";;
      *Uninstall\ openhab-js) jsscripting_npm_install "openhab" "uninstall";;
      47\ *) jsscripting_npm_install "openhab_rules_tools";;
      *Uninstall\ openhab_rules_tools) jsscripting_npm_install "openhab_rules_tools" "uninstall";;
      "") return 0 ;;
      *) whiptail --msgbox "An unsupported option was selected (probably a programming error):\\n  \"$choice2\"" 8 80 ;;
    esac

  elif [[ "$choice" == "50"* ]]; then
    choice2=$(whiptail --title "openHABian Configuration Tool — $(get_git_revision)" --menu "Backup/Restore" 24 118 16 --cancel-button Back --ok-button Execute \
    "50 | Backup openHAB config"      "Backup (export) the current active openHAB configuration" \
    "51 | Restore an openHAB config"  "Restore an openHAB configuration from backup zipfile" \
    "   | Restore text only config"   "Restore text only configuration without restarting" \
    "52 | Amanda System Backup"       "Set up Amanda to comprehensively backup your complete openHABian box" \
    "53 | Setup SD mirroring"         "Setup mirroring of internal to external SD card" \
    "   | Remove SD mirroring"        "Disable mirroring of SD cards" \
    "54 | Raw copy SD"                "Raw copy internal SD to external disk / SD card" \
    "55 | Sync SD"                    "Rsync internal SD to external disk / SD card" \
    3>&1 1>&2 2>&3)
    if [ $? -eq 1 ] || [ $? -eq 255 ]; then return 0; fi
    case "$choice2" in
      50\ *) backup_openhab_config ;;
      51\ *) restore_openhab_config ;;
      *Restore\ text\ only*) restore_openhab_config "${initialconfig:-/boot/initial.zip}" "textonly" ;;
      52\ *) wait_for_apt_to_finish_update && amanda_setup ;;
      53\ *) setup_mirror_SD "install" ;;
      *Remove\ SD\ mirroring*) setup_mirror_SD "remove" ;;
      54\ *) mirror_SD "raw" ;;
      55\ *) mirror_SD "diff" ;;
      "") return 0 ;;
      *) whiptail --msgbox "An unsupported option was selected (probably a programming error):\\n  \"$choice2\"" 8 80 ;;
    esac
  else
    whiptail --msgbox "Error: unrecognized option \"$choice\"" 10 60
  fi

  # shellcheck disable=SC2154,SC2181
  if [ $? -ne 0 ]; then whiptail --msgbox "There was an error or interruption during the execution of:\\n  \"$choice\"\\n\\nPlease try again. If the error persists, please read /opt/openhabian/docs/openhabian-DEBUG.md or https://github.com/openhab/openhabian/blob/main/docs/openhabian-DEBUG.md how to proceed." 14 80; return 0; fi
}
