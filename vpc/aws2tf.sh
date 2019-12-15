usage()
{ echo "Usage: $0 -a <Account ID> [-g <Resource Group>] [-r azurerm_<resource_type>] [-x <yes|no(default)>] [-p <yes|no(default)>] [-f <yes|no(default)>] " 1>&2; exit 1;
}
x="no"
p="no"
f="no"
v="no"
#while getopts ":s:g:r:x:p:f:" o; do
while getopts ":r:x:f:v:" o; do
    case "${o}" in
    #    a)
    #        s=${OPTARG}
    #    ;;
    #    g)
    #        g=${OPTARG}
    #    ;;
        r)
            r=${OPTARG}
        ;;
        x)
            x="yes"
        ;;
        p)
            p="yes"
        ;;
        f)
            f="yes"
        ;;
        v)
            v="yes"
        ;;
        
        *)
            usage
        ;;
    esac
done
shift $((OPTIND-1))

#if [ -z "${s}" ]; then
#    usage
#fi



export az2tfmess="# File generated by aws2tf see https://github.com/andyt530/aws2tf"

#if [ "$s" != "" ]; then
#    mysub=$s
#else
#    echo -n "Enter id of Account [$mysub] > "
#    read response
#    if [ -n "$response" ]; then
#        mysub=$response
#    fi
#fi

#echo "Checking Account $mysub exists ..."
#isok="no"
#subs=`az account list --query '[].id' -o json | jq '.[]' | tr -d '"'`
#for i in `echo $subs`
#do
#    if [ "$i" = "$mysub" ] ; then
#        echo "Found subscription $mysub proceeding ..."
#        isok="yes"
#    fi
#done
#if [ "$isok" != "yes" ]; then
#    echo "Could not find subscription with ID $mysub"
#    exit
#fi

#myrg=$g
#export ARM_SUBSCRIPTION_ID="$mysub"
#az account set -s $mysub


mysub=`aws sts get-caller-identity | jq .Account | tr -d '"'`

if [ "$mysub" == "null" ]; then
    echo "Account is null exiting"
    exit
fi

mkdir -p generated/tf.$mysub

s=`echo $mysub`
cd generated/tf.$mysub
rm -rf .terraform
if [ "$f" = "no" ]; then
    rm -f import.log resources*.txt
    rm -f processed.txt
else
    sort -u processed.txt > pt.txt
    cp pt.txt processed.txt
fi
#if [ "$f" = "no" ]; then
#    ../../scripts/resources.sh 2>&1 | tee -a import.log
#fi
echo " "
echo "Account ID = ${s}"
echo "Azure Resource Group Filter = ${g}"
echo "Terraform Resource Type Filter = ${r}"
echo "Get Subscription Policies & RBAC = ${p}"
echo "Extract Key Vault Secrets to .tf files (insecure) = ${x}"
echo "Fast Forward = ${f}"
echo " "


#pfx[1]="az group list"
#res[1]="azurerm_resource_group"
#pfx[2]="az lock list"
#res[2]="azurerm_management_lock"

#res[52]="azurerm_role_assignment"
#res[51]="azurerm_role_definition"
#res[53]="azurerm_policy_definition"
#res[54]="azurerm_policy_assignment"

#
# uncomment following line if you want to use an SPN login
#../../setup-env.sh

#if [ "$g" != "" ]; then
#    lcg=`echo $g | awk '{print tolower($0)}'`
#    # check provided resource group exists in subscription
#    exists=`az group exists -g $g -o json`
#    if  ! $exists ; then
#        echo "Resource Group $g does not exists in subscription $mysub  Exit ....."
#        exit
#    fi
#    echo "Filtering by Azure RG $g"
#    grep $g resources2.txt > tmp.txt
#    rm -f resources2.txt
#    cp tmp.txt resources2.txt
    
#fi

#if [ "$r" != "" ]; then
#    lcr=`echo $r | awk '{print tolower($0)}'`
#    echo "Filtering by Terraform resource $lcr"
#    grep $lcr resources2.txt > tmp2.txt
#    rm -f resources2.txt
#    cp tmp2.txt resources2.txt
#fi


# cleanup from any previous runs
rm -f terraform*.backup
#rm -f terraform.tfstate
rm -f tf*.sh
cp ../../stub/*.tf .
echo "terraform init"
terraform init 2>&1 | tee -a import.log


# subscription level stuff - roles & policies
if [ "$p" = "yes" ]; then
    for j in `seq 51 54`; do
        docomm="../../scripts/${res[$j]}.sh $mysub"
        #echo $docomm
        #eval $docomm 2>&1 | tee -a import.log
        if grep -q Error: import.log ; then
            echo "Error in log file exiting ...."
            exit
        fi
    done
fi


#echo $myrg
#../scripts/193_azurerm_application_gateway.sh $myrg

date



date


echo "loop through providers"
pwd
for com in `ls ../../scripts/*-get-*.sh | cut -d'/' -f4 | sort -g`; do    
        echo "$com"
        docomm="../../scripts/$com"
        if [ "$f" = "no" ]; then
            eval $docomm 2>&1 | tee -a import.log
        else
            grep "$docomm" processed.txt
            if [ $? -eq 0 ]; then
                echo "skipping $docomm"
            else
                eval $docom 2>&1 | tee -a import.log
            fi
        fi

        lc=`expr $lc + 1`
        if grep Error: import.log; then
            echo "Error in log file exiting ...."
            exit
        else
        echo "$docom" >> processed.txt
        fi
    
    rm -f terraform*.backup
done
date

#if [ "$x" = "yes" ]; then
#    echo "Attempting to extract secrets"
#    ../../scripts/350_key_vault_secret.sh
#fi


#

echo "---------------------------------------------------------------------------"
echo "az2tf output files are in generated/tf.$mysub"
echo "---------------------------------------------------------------------------"
exit
echo "Terraform fmt ..."
terraform fmt
echo "Terraform validate ..."
terraform validate .
if [ "$v" = "yes" ]; then
    exit
fi

echo "Terraform Plan ..."
terraform plan .

