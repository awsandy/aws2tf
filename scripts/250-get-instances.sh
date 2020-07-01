#!/bin/bash
if [ "$1" != "" ]; then
    cmd[0]="$AWS ec2 describe-instances --filters \"Name=vpc-id,Values=$1\""
else
    cmd[0]="$AWS ec2 describe-instances"
fi


pref[0]="Reservations"
tft[0]="aws_instance"


for c in `seq 0 0`; do
    
    cm=${cmd[$c]}
	ttft=${tft[(${c})]}
	#echo $cm
    awsout=`eval $cm`
    count=`echo $awsout | jq ".${pref[(${c})]} | length"`
    #echo "count= $count"
    if [ "$count" != "0" ]; then
        count=`expr $count - 1`
        for i in `seq 0 $count`; do
            #echo "i=$i"
            cname=`echo $awsout | jq ".${pref[(${c})]}[(${i})].Instances[].InstanceId" | tr -d '"'`
            echo $cname
            # get instance user_data

            ud=`$AWS ec2 describe-instance-attribute --instance-id $cname --attribute userData | jq .UserData.Value`
            echo "user_date=$ud"
            $AWS ec2 describe-instance-attribute --instance-id $cname --attribute userData | jq .UserData.Value | tr -d '"' | base64 --decode > $cname.sh

            nets=`echo $awsout | jq ".${pref[(${c})]}[(${i})].Instances[].NetworkInterfaces"`
            nl=`echo $nets | jq ". | length"`
            echo "netifs= $nl"
            if [ "$nl" != "0" ]; then
                nl=`expr $nl - 1`
                for ni in `seq 0 $nl`; do
                    nif=`echo $nets | jq ".[(${ni})].NetworkInterfaceId" | tr -d '"'`
                    echo $nif
                    ../../scripts/get-eni.sh $netif
                done
            fi
            fn=`printf "%s__%s.tf" $ttft $cname`
            echo $aws2tfmess > $fn
            printf "resource \"%s\" \"%s\" {" $ttft $cname > $ttft.$cname.tf
            printf "}" $cname >> $ttft.$cname.tf
            terraform import $ttft.$cname $cname
            terraform state show $ttft.$cname > t2.txt
            rm $ttft.$cname.tf
            cat t2.txt | perl -pe 's/\x1b.*?[mGKH]//g' > t1.txt
            #	for k in `cat t1.txt`; do
            #		echo $k
            #	done
            file="t1.txt"
            fn=`printf "%s__%s.tf" $ttft $cname`
            echo $aws2tfmess > $fn
            while IFS= read line
            do
				skip=0
                # display $line or do something with $line
                t1=`echo "$line"` 
                if [[ ${t1} == *"="* ]];then
                    tt1=`echo "$line" | cut -f1 -d'=' | tr -d ' '` 
                    tt2=`echo "$line" | cut -f2- -d'='`
                    if [[ ${tt1} == "arn" ]];then skip=1; fi                
                    if [[ ${tt1} == "id" ]];then skip=1; fi
                         
                    if [[ ${tt1} == "user_data" ]];then 
                        skip=0
                        t1=`printf "user_data_base64 = %s" $ud`
                    fi          
                    if [[ ${tt1} == "role_arn" ]];then skip=1;fi
                    if [[ ${tt1} == "primary_network_interface_id" ]];then skip=1;fi
                    if [[ ${tt1} == "instance_state" ]];then skip=1;fi
                    if [[ ${tt1} == "private_dns" ]];then skip=1;fi

                    if [[ ${tt1} == "volume_id" ]];then skip=1;fi
                    #if [[ ${tt1} == "user_data" ]];then 
                    #    t1=`printf "%s = file(\"%s.sh\")" $tt1 $cname`
                    #fi
                    if [[ ${tt1} == "public_ip" ]];then skip=1;fi
                    if [[ ${tt1} == "public_dns" ]];then skip=1;fi
                    if [[ ${tt1} == "device_name" ]];then skip=1;fi
                    #if [[ ${tt1} == "ipv6_association_id" ]];then skip=1;fi
                    #if [[ ${tt1} == "ipv6_cidr_block" ]];then skip=1;fi    
                    if [[ ${tt1} == "subnet_id" ]]; then
                        tt2=`echo $tt2 | tr -d '"'`
                        t1=`printf "%s = aws_subnet.%s.id" $tt1 $tt2`
                    fi    
                else
                    if [[ "$t1" == *"subnet-"* ]]; then
                        t1=`echo $t1 | tr -d '"|,'`
                        t1=`printf "aws_subnet.%s.id," $t1`
                    fi
                    if [[ "$t1" == *"sg-"* ]]; then
                        t1=`echo $t1 | tr -d '"|,'`
                        t1=`printf "aws_security_group.%s.id," $t1`
                    fi
                fi
                if [ "$skip" == "0" ]; then
                    #echo $skip $t1
                    echo $t1 >> $fn
                fi
                
            done <"$file"
            
        done
    fi
done
terraform fmt
terraform validate
rm -f t*.txt

