cmd[0]="aws s3 ls | awk '{print \$3'}"
pref[0]="Crawlers"
tft[0]="aws_s3_bucket"
cmd[1]="aws s3api get-bucket-policy --bucket "
pref[1]="Jobs"
tft[1]="aws_s3_bucket_policy"

for c in `seq 0 0`; do
    cm=${cmd[$c]}
	ttft=${tft[(${c})]}
	#echo $cm
    eval $cm > tmp.txt
    count=`cat tmp.txt | wc -l | awk '{print $1}'`
    echo $count
ttft=${tft[0]}
done
echo $ttft

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
        while IFS= read line
        do
			skip=0
            # display $line or do something with $line
            t1=`echo "$line"` 
                
            if [[ ${t1} == *"arn"*"="* ]];then			
				skip=1
			fi
				
            if [[ ${t1} == *"id"*"="* ]];then
                skip=1
            fi
				
            if [[ ${t1} == *"role_arn"*"="* ]];then skip=0;fi
            if [[ ${t1} == *"bucket_domain_name"*"="* ]];then skip=1;fi
            if [[ ${t1} == *"bucket_regional_domain_name"*"="* ]];then skip=1;fi
			if [[ ${t1} == *"allocated_capacity"*"="* ]];then skip=1;fi

			if [ "$skip" == "0" ]; then
				#echo $skip $t1
				echo $t1 >> $ttft-$cname.tf
			fi
        done <"$file"         

# bucket policies:

        cm=${cmd[1]}
	    ttft=${tft[1]}
        cm=`echo $cm $cname "| jq ."`
        echo $cm
        echo $ttft
        c=`eval $cm`
        echo "c=" $c
        if [[ $c == *"{"* ]];then 
            echo "yep here"
            printf "resource \"%s\" \"%s\" {" $ttft $cname > $cname.tf
            printf "}" $cname >> $cname.tf
            terraform import $ttft.$cname $cname
            terraform state show $ttft.$cname > t2.txt
            rm $cname.tf
            cat t2.txt | perl -pe 's/\x1b.*?[mGKH]//g' > t1.txt
            more t1.txt
            file="t1.txt"
            while IFS= read line
            do
                skip=0
                # display $line or do something with $line
                t1=`echo "$line"` 
                    
                if [[ ${t1} == *"arn"*"="* ]];then			
                    skip=1
                fi
                    
                if [[ ${t1} == *"id"*"="* ]];then
                    skip=1
                fi
                    
                if [[ ${t1} == *"role_arn"*"="* ]];then skip=0;fi
                if [[ ${t1} == *"bucket_domain_name"*"="* ]];then skip=1;fi
                if [[ ${t1} == *"bucket_regional_domain_name"*"="* ]];then skip=1;fi
                if [[ ${t1} == *"allocated_capacity"*"="* ]];then skip=1;fi

                if [ "$skip" == "0" ]; then
                    #echo $skip $t1
                    echo $t1 >> $ttft-$cname.tf
                fi
            done <"$file"         

        fi
    
    done
fi
rm t*.txt
exit

