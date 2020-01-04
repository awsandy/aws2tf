ismain=`aws ec2 describe-route-tables | jq .RouteTables[4].Associations[0].Main`
if [ $ismain == false ]; then
echo "isfalse"
else
echo "istrue"
fi
