#!/bin/bash

gen_conf()
{
	#设备完整名称
	local device="$1"

	#调整cpu_type
	local cpu_type
	if [ $# -eq 2 ] ; then
		cpu_type="$2"
	fi

	local target2="$(echo "$device" | sed 's/_DEVICE_.*$//g')"
	local target1="$(echo "$target2" | sed 's/_.*$//g')"

	local device_short="$(echo "$device" | sed 's/^.*_DEVICE_//g')"

	echo "Processing: device $device_short"

	mkdir -p  ./conf
	# 文件不删空有可能导致配置错误
	rm -rf  tmp/ .config .config.old
	# LEDE源码有坑，以下这行是处理LEDE源码坑，避免make defconfig的时候出错。
	make -C scripts/config clean >/dev/null 2>&1

	cat > .config <<EOF
CONFIG_TARGET_${target1}=y
CONFIG_TARGET_${target2}=y
CONFIG_TARGET_${device}=y
EOF

	make defconfig > /dev/null

	local line_str
	local line_str_rep

	if [ -n "$cpu_type" ] ; then
		line_str="$(grep '^CONFIG_TARGET_OPTIMIZATION=' .config)"
		line_str_rep="$(echo "$line_str" | sed "s/-mtune=[^[[:space:]\"]*/-mtune=${cpu_type}/g")"
		sed -i "s/$line_str/$line_str_rep/g" .config
	fi
	cp -f .config "conf/.config.$device_short"
	rm -f .config .config.old
	echo ""
	echo "Complete: written to conf/.config.$device_short"
	echo ""
}


process_devices()
{
	devices=$1
	local cpu_type=$2
	local n=${#devices[@]}
	for i in `seq 0 $(expr $n - 1)`; do
		gen_conf "${devices[i]}" $cpu_type
	done
}

###################################################
rm -f conf/.config.*
###################################################

### ar71xx 24kc without USB
export _CONF_ROUTER_WITHOUT_USB_PORT_=1

devices=(
	"ar71xx_generic_DEVICE_tl-wr841-v3"
	"ar71xx_generic_DEVICE_tl-wr841-v5"
	"ar71xx_generic_DEVICE_tl-wr841-v7"
	"ar71xx_generic_DEVICE_tl-wr941nd-v3"
	"ar71xx_generic_DEVICE_tl-wr941nd-v4"
	"ar71xx_generic_DEVICE_tl-wr941nd-v5"
	"ar71xx_generic_DEVICE_tl-wr740n-v1"
	"ar71xx_generic_DEVICE_tl-wr740n-v3"
	"ar71xx_generic_DEVICE_tl-wr740n-v4"
	"ar71xx_generic_DEVICE_tl-wr740n-v5"
	"ar71xx_generic_DEVICE_tl-wr740n-v6"
)
process_devices $devices

export -n _CONF_ROUTER_WITHOUT_USB_PORT_

./def_config.sh

###################################################

# ar71xx 24kc with USB  
devices=(
	"ar71xx_generic_DEVICE_tl-wr842n-v1"
	"ar71xx_generic_DEVICE_tl-mr3420-v1"
	"ar71xx_generic_DEVICE_tl-mr3420-v2"
)
process_devices $devices


