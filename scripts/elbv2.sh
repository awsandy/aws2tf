#!/bin/bash
if [ "$1" != "" ]; then
    cmd[0]="$AWS elbv2 describe-load-balancers --query \"LoadBalancers[?Type=='application']|[?VpcId=='$1']\""
else
    cmd[0]="$AWS elbv2 describe-load-balancers --query \"LoadBalancers[?Type=='application']\""
fi
c=0
cm=${cmd[$c]}
echo $cm

pref[0]=""
tft[0]="aws_lb"
idfilt[0]="LoadBalancerArn"
rm -f ${tft[(${c})]}.*.tf

for c in `seq 0 0`; do
 
    cm=${cmd[$c]}
	ttft=${tft[(${c})]}
	#echo $cm
    awsout=`eval $cm`
    count=`echo $awsout | jq ".${pref[(${c})]} | length"`
    
    if [[ "$count" -gt "0" && "$count"!="" ]]; then
        count=`expr $count - 1`
        for i in `seq 0 $count`; do
            #echo $i
            
            cname=`echo $awsout | jq ".${pref[(${c})]}[(${i})].${idfilt[(${c})]}" | tr -d '"'`
            #echo $cname
            lbarn=`echo $cname`
            attribs=`$AWS elbv2 describe-load-balancer-attributes --load-balancer-arn ${lbarn}`
            
            #echo $attribs | jq ".Attributes"
            #echo "$ttft $cname"
            rname=${cname//:/_}
            rname=${rname//\//_}
            echo $rname
            fn=`printf "%s__%s.tf" $ttft $rname`
            

            printf "resource \"%s\" \"%s\" {\n" $ttft $rname > $fn
            printf "}"  >> $fn
            
            terraform import $ttft.$rname "$cname"
            terraform state show $ttft.$rname > t2.txt
            
            rm $fn
            cat t2.txt | perl -pe 's/\x1b.*?[mGKH]//g' > t1.txt
            #	for k in `cat t1.txt`; do
            #		echo $k
            #	done
            file="t1.txt"
            
         
            #echo "#" > $fn
            while IFS= read line
            do
				skip=0
                # display $line or do something with $line
                t1=`echo "$line"` 
                if [[ ${t1} == *"="* ]];then
                    tt1=`echo "$line" | cut -f1 -d'=' | tr -d ' '` 
                    tt2=`echo "$line" | cut -f2- -d'='`
                    if [[ ${tt1} == "arn" ]];then
                        if [[ ${tt2} == *"loadbalancer"* ]];then
                            lbarn=`echo ${tt2}`
                            printf "#%s\n" $lbarn >> $fn
                            skip=1
                        else
                            skip=0; 
                        fi
                    fi                
                    if [[ ${tt1} == "id" ]];then skip=1; fi          
                    if [[ ${tt1} == "role_arn" ]];then skip=1;fi
                    if [[ ${tt1} == "owner_id" ]];then skip=1;fi
                    if [[ ${tt1} == "association_id" ]];then skip=1;fi

                    if [[ ${tt1} == "dns_name" ]];then skip=1;fi
                    if [[ ${tt1} == "vpc_id" ]];then skip=1;fi
                    if [[ ${tt1} == "default_version" ]];then skip=1;fi
                    if [[ ${tt1} == "latest_version" ]];then skip=1;fi
                    if [[ ${tt1} == "security_group_names" ]];then skip=1;fi
                    if [[ ${tt1} == "zone_id" ]];then skip=1;fi
                    if [[ ${tt1} == "arn_suffix" ]];then skip=1;fi
                    #if [[ ${tt1} == "ipv6_cidr_block" ]];then skip=1;fi
                    if [[ ${tt1} == "subnet_id" ]]; then
                        tt2=`echo $tt2 | tr -d '"'`
                        t1=`printf "%s = aws_subnet.%s.id" $tt1 $tt2`
                    fi


                #else
                #    if [[ "$t1" == *"sg-"* ]]; then
                #        t1=`echo $t1 | tr -d '"|,'`
                #        t1=`printf "aws_security_group.%s.id," $t1`
                #    fi
                fi
                
                if [ "$skip" == "0" ]; then
                    #echo $skip $t1
                    echo $t1 >> $fn
                fi
                
            done <"$file"
            echo "Listener ......."
            ../../scripts/elbv2_listener.sh $lbarn
            echo "Target Group ......."
            ../../scripts/elbv2-target-groups.sh $lbarn

        done
        
    fi
done
terraform fmt
terraform validate
#rm -f t*.txt

