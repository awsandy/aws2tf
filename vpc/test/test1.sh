terraform state list | grep aws_default_security_group > tfd.tmp
for i in `cat tfd.tmp` ; do
j=`echo $i | cut -d'.' -f2`
k=`printf "aws_security_group.%s" $j`
echo $k
grep $k *.tf
done
