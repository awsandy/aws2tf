#!/bin/bash

if [ "$1" != "" ]; then
    cmd[0]="$AWS ec2 describe-network-interfaces --filters \"Name=vpc-id,Values=$1\""
else
    cmd[0]="$AWS ec2 describe-network-interfaces"
fi

pref[0]="NetworkInterfaces"
tft[0]="aws_network_interface_attachment"

for c in `seq 0 0`; do
    
    cm=${cmd[$c]}
	ttft=${tft[(${c})]}
	#echo $cm
    awsout=`eval $cm`
    count=`echo $awsout | jq ".${pref[(${c})]} | length"`
    if [ "$count" -gt "0" ]; then
        count=`expr $count - 1`
        for i in `seq 0 $count`; do
            #echo $i
            cname=`echo $awsout | jq ".${pref[(${c})]}[(${i})].NetworkInterfaceId" | tr -d '"'`
            echo $cname
            fn=`printf "%s__%s.tf" $ttft $cname`
            devind=`echo $awsout | jq ".${pref[(${c})]}[(${i})].Attachment.DeviceIndex" | tr -d '"'`
            insid=`echo $awsout | jq ".${pref[(${c})]}[(${i})].Attachment.InstanceId" | tr -d '"'`
            if [ "$insid" != "null" ]; then
                printf "resource \"aws_network_interface_attachment\" \"%s\" {\n" $cname > $fn
                printf "instance_id = aws_instance.%s.id\n" $insid >> $fn
                printf "network_interface_id = aws_network_interface.%s.id\n" $cname >> $fn
                printf "device_index = %s\n" $devind >> $fn
                printf "}\n" $cname >> $fn
            fi
            
        done
    fi
done
#terraform fmt
#terraform validate
rm -f t*.txt

