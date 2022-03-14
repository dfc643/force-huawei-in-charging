#!/system/bin/sh
# Please don't hardcode /magisk/modname/... ; instead, please use $MODDIR/...
# This will make your scripts compatible even if Magisk change its mount point in the future
MODDIR=${0%/*}

# This script will be executed in late_start service mode
# More info in the main Magisk thread

##################################
##  Force Huawei Device Charging
##  - Author: @dfc643
##################################
#__charger_type_defines__
HW_CHARGER_USB=0
HW_CHARGER_SUPPLY=3
HW_CHARGER_NONE=4
#__interfaces__
HW_CHARGE_SW="/sys/class/hw_power/charger/charge_data/enable_charger"
HW_CHARGE_TYPE="/sys/class/hw_power/charger/charge_data/chargerType"
HW_BATT_LEVEL="/sys/devices/battery.0/power_supply/Battery/capacity"

healthd_pause() {
    PID=$(/system/bin/pidof -s /sbin/healthd)
    if [ $PID -ne 1 ] && [ "$(getprop sys.boot_completed)" = "1" ]
    then
        /system/bin/kill -STOP $PID
    fi
}
healthd_resume() {
    PID=$(/system/bin/pidof -s /sbin/healthd)
    if [ $PID -ne 1 ]; then
        /system/bin/kill -CONT $PID
    fi
}

#__main_loop__
while [ true ]
do
    #__check_charger_in_present_or_not__
    if [ $(cat ${HW_CHARGE_TYPE}) -eq ${HW_CHARGER_NONE} ]
    then
        healthd_resume
        continue
    fi
    #__battery_level_less_than_100_force_charging__
    CUR_BATT_LEVEL=$(cat ${HW_BATT_LEVEL})
    if [ $CUR_BATT_LEVEL -lt 100 ]
    then
        echo 1 > ${HW_CHARGE_SW}
        sleep 0.3
        healthd_pause
    fi
    #__sleep_3000ms__
    sleep 3
done
