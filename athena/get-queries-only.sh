cmd[0]="aws athena list-named-queries"
pref[0]="NamedQueryIds"
tft[0]="aws_glue_crawler"
cmd[1]="aws athena get-named-query --named-query-id"
pref[1]="NamedQuery"
tft[1]="aws_athena_named_query"

# get number of query ids
for c in `seq 0 0`; do
    cm=${cmd[$c]}
    ttft=${tft[(${c})]}
    echo $cm
    awsout=`eval $cm`
    #echo $awsout
    count=`echo $awsout | jq ".${pref[(${c})]} | length"`
    echo $count
done


c2=1
#if [ "$count" -gt "0" ]; then
#    count=`expr $count - 1`
#    #loop through query id's
#    for i in `seq 0 $count`; do
#        qid=`echo $awsout | jq ".${pref[(${c})]}[(${i})]" | tr -d '"'`
#        echo $qid
#    done
#fi

#exit

c2=1
if [ "$count" -gt "0" ]; then
    count=`expr $count - 1`
    #loop through query id's
    for i in `seq 0 $count`; do
        qid=`echo $awsout | jq ".${pref[(${c})]}[(${i})]" | tr -d '"'`
        #echo "quid=$qid"
        cm="${cmd[$c2]} $qid"
        
        #cm=`printf "%s %s" "$cm" "$quid"`
        
        ttft=${tft[(${c2})]}
        echo "command= $cm"
        awsout2=`eval $cm`
        #echo $awsout
        cname=`echo $awsout2 | jq ".${pref[(${c2})]}" | jq .Name | tr -d '"'`
        echo "name=$cname"        
       
        
    done
fi





exit


awsout=`aws athena list-named-queries`
count=`echo $awsout | jq ".${pref[(${c})]} | length"`
echo $qrys | jq '.NamedQueryIds'


