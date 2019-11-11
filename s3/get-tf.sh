cmd[0]="aws s3 ls | awk '{print \$3'}"
pref[0]="Crawlers"
tft[0]="aws_s3_bucket"
#cmd[1]="aws glue get-jobs"
#pref[1]="Jobs"
#tft[1]="aws_glue_job"

for c in `seq 0 0`; do
    cm=${cmd[$c]}
	ttft=${tft[(${c})]}
	echo $cm
    eval $cm > tmp.txt
    cat tmp.txt
    count=`cat tmp.txt | wc -l | awk '{print $1}'`
    echo $count
ttft=tft[0]
done
if [ "$count" -gt "0" ]; then
    count=`expr $count - 1`
    for cname in `cat tmp.txt`; do
        echo $cname

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
				echo "in arn"
				skip=1
			fi
				
            if [[ ${t1} == *"id"*"="* ]];then
                skip=1
            fi
				
            if [[ ${t1} == *"role_arn"*"="* ]];then skip=0;fi
			if [[ ${t1} == *"allocated_capacity"*"="* ]];then skip=1;fi

			if [ "$skip" == "0" ]; then
				#echo $skip $t1
				echo $t1 >> $cname.tf
			fi
        done <"$file"           
            
    done
fi







    done
fi

exit
            echo $i
            cname=`echo $awsout | jq ".${pref[(${c})]}[(${i})].Name" | tr -d '"'`
            
    fi
done
rm t*.txt

