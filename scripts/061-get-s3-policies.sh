ttft="aws_s3_bucket_policy"
for i in `terraform state list | grep aws_s3_bucket_policy`; do
    terraform state show  $i > t2.txt
    terraform show  -json | jq --arg myt $i '.values.root_module.resources[]| select(.address==$myt)' > $i.json
    cname=`echo $i | cut -f2 -d'.'`
    echo $cname
    cat t2.txt | perl -pe 's/\x1b.*?[mGKH]//g' > t1.txt
    file="t1.txt"
    fn=`printf "%s__%s.tf" $ttft $cname`

    while IFS= read line
    do
        skip=0
        # display $line or do something with $line
        t1=`echo "$line"`

        if [[ ${t1} == *"="* ]];then
            tt1=`echo "$line" | cut -f1 -d'=' | tr -d ' '` 
                                    
            if [[ ${tt1} == "arn" ]];then	
                #printf "acl = \"private\" \n" >> $fn
                #printf "force_destroy = false \n" >> $fn
                skip=1
            fi
                                    
            if [[ ${tt1} == "id" ]];then
                #printf "acl = \"private\"\n" >> $fn
                #printf "force_destroy = false \n" >> $fn
                skip=1
            fi
                                    
            if [[ ${tt1} == "role_arn" ]];then 
                printf "provider = \"aws.regional\"\n" >> $fn
                skip=0;
            fi
            if [[ ${tt1} == "force_destroy" ]];then
                skip=0
                fd=1
            fi
            
            if [[ ${tt1} == "acl" ]];then
                skip=0
                acl=1
            fi
        fi
                            
        if [ "$skip" == "0" ];then
        #echo $skip $t1 $ttft
        echo $t1 >> $fn
        fi
                                   
    done <"$file" 
done

terraform fmt
terraform validate
rm -f t*.txt
exit