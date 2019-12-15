#1/bin/bash
kcount=`aws eks list-clusters --region eu-west-1 | jq ".clusters | length"`
if [ "$kcount" -gt "0" ]; then
    kcount=`expr $kcount - 1`
    for k in `seq 0 $kcount`; do
        cln=`aws eks list-clusters --region eu-west-1 | jq ".clusters[(${k})]" | tr -d '"'`
        echo cluster name $cln
        
        
        cmd[0]=`echo "aws eks describe-cluster --region eu-west-1 --name $cln"`
        #echo $cmd[0]
        
        pref[0]="cluster"
        tft[0]="aws_eks_cluster"
        rm -f ${tft[0]}_*.tf
        
        for c in `seq 0 0`; do
            rm -f ${tft[0]}*.tf
            cm=${cmd[$c]}
            ttft=${tft[(${c})]}
            echo $cm
            awsout=`eval $cm`
            count=`echo $awsout | jq ".${pref[(${c})]} | length"`
            count=1 # one cluster at a time !
            if [ "$count" -gt "0" ]; then
                count=`expr $count - 1`
                for i in `seq 0 $count`; do
                    echo $i
                    cname=`echo $awsout | jq ".${pref[(${c})]}.name" | tr -d '"'`
                    ocname=`echo $cname`
                    cname=${cname//./_}
                    echo cname = $cname
                    
                    printf "resource \"%s\" \"%s\" {" $ttft $cname > $ttft.$cname.tf
                    printf "}" >> $ttft.$cname.tf
                    terraform import $ttft.$cname $ocname
                    terraform state show $ttft.$cname > t2.txt
                    rm $ttft.$cname.tf
                    cat t2.txt | perl -pe 's/\x1b.*?[mGKH]//g' > t1.txt
                    #	for k in `cat t1.txt`; do
                    #		echo $k
                    #	done
                    file="t1.txt"
                    fn=`printf "%s__%s.tf" $ttft $cname`
                    while IFS= read line
                    do
                        skip=0
                        # display $line or do something with $line
                        t1=`echo "$line"`
                        if [[ ${t1} == *"="* ]];then
                            tt1=`echo "$line" | cut -f1 -d'=' | tr -d ' '`
                            tt2=`echo "$line" | cut -f2- -d'='`
                            if [[ ${tt1} == *":"* ]];then
                                t1=`printf "\"%s\"=%s" $tt1 $tt2`
                            fi
                            if [[ ${tt1} == "arn" ]];then skip=1; fi
                            if [[ ${tt1} == "id" ]];then skip=1; fi
                            if [[ ${tt1} == "role_arn" ]];then skip=1;fi
                            if [[ ${tt1} == "owner_id" ]];then skip=1;fi
                            if [[ ${tt1} == "association_id" ]];then skip=1;fi
                            if [[ ${tt1} == "unique_id" ]];then skip=1;fi
                            if [[ ${tt1} == "create_date" ]];then skip=1;fi
                            #if [[ ${tt1} == "public_ip" ]];then skip=1;fi
                            if [[ ${tt1} == "private_ip" ]];then skip=1;fi
                            if [[ ${tt1} == "accept_status" ]];then skip=1;fi
                            #if [[ ${tt1} == "default_network_acl_id" ]];then skip=1;fi
                            #if [[ ${tt1} == "ipv6_association_id" ]];then skip=1;fi
                            #if [[ ${tt1} == "ipv6_cidr_block" ]];then skip=1;fi
                        fi
                        if [ "$skip" == "0" ]; then
                            #echo $skip $t1
                            echo $t1 >> $fn
                        fi
                        
                    done <"$file"   # done while
                    
                done # done for i
            fi
        done
        
    done
fi
exit


echo "fmt"
terraform fmt
echo "validate"
terraform validate
rm -f t*.txt

