cmd[0]="aws s3 ls  | awk '{print \$3'}"
pref[0]="Crawlers"
tft[0]="aws_s3_bucket"
#
# policies
#
cmd[1]="aws s3api get-bucket-policy --bucket "
pref[1]="Jobs"
tft[1]="aws_s3_bucket_policy"

for c in `seq 0 0`; do
    cm=${cmd[$c]}
	ttft=${tft[(${c})]}
	#echo $cm
    eval $cm > tmp.txt
    count=`cat tmp.txt | wc -l | awk '{print $1}'`
    echo "number buckets =$count"
ttft=${tft[0]}
done




if [ "$count" -gt "0" ]; then
    count=`expr $count - 1`
    for cname in `cat tmp.txt`; do
        echo $cname
        cm=${cmd[0]}
	    ttft=${tft[0]}
        

        printf "resource \"%s\" \"%s\" {" $ttft $cname > $cname.tf
        printf "}" $cname >> $cname.tf
        terraform import $ttft.$cname $cname
        terraform state show $ttft.$cname > t2.txt
        rm $cname.tf
        cat t2.txt | perl -pe 's/\x1b.*?[mGKH]//g' > t1.txt
        #	for k in `cat t1.txt`; do
        #		echo $k
        #	done
        file="t1.txt"
        fn=`printf "%s__%s.tf" $ttft $cname`
        flines=`wc -l $file | awk '{ print $1 }'`
        #echo "lines in file t1.txt= $flines"
        if [[ $flines > 0 ]]; then
        flc=0
        fd=0
        acl=0
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
                if [[ ${tt1} == "bucket_domain_name" ]];then skip=1;fi
                if [[ ${tt1} == "bucket_regional_domain_name" ]];then skip=1;fi
                if [[ ${tt1} == "allocated_capacity" ]];then skip=1;fi
            fi


            ((flc=flc+1))
            if [[ $flc = $flines ]];then
                if [[ $fd = 0 ]]; then
                    echo "force_destroy=false" >> $fn
                fi
                if [[ $acl = 0 ]]; then
                    printf "acl = \"private\" \n" >> $fn
                fi
            fi
			if [ "$skip" == "0" ];then
				#echo $skip $t1 $ttft
				echo $t1 >> $fn
			fi


        done <"$file" 
        else
            terraform state rm $ttft.$cname
        fi 
        echo "Done $cname"
    done
fi


rm -f t*.txt
exit

