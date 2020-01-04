#1/bin/bash
cmd[0]="aws ec2 describe-instances"
pref[0]="Reservations"
tft[0]="aws_instance"


for c in `seq 0 0`; do
    
    cm=${cmd[$c]}
	ttft=${tft[(${c})]}
	echo $cm
    awsout=`eval $cm`
    echo $awsout | jq ".${pref[(${c})]}"
    count=`echo $awsout | jq ".${pref[(${c})]} | length"`
    echo "count= $count"
    if [ "$count" != "0" ]; then
        count=`expr $count - 1`
        echo $count	
        for i in `seq 0 $count`; do
            echo "i=$i"
            echo $awsout | jq ".${pref[(${c})]}[(${i})].Instances[].InstanceId"
	done
    fi
done
