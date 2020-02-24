# aws2tf supports Terraform v0.12

**Work in progress - please report any issues you find.**

This utility 'AWS to Terraform' (aws2tf)
reads an AWS Account and generates all the required terraform configuration files (.tf) from each of the composite AWS resources

It also imports the terraform state using a

"terraform import ...." command

And finally runs a

"terraform plan ."  command

There should hopefully be no subsequent additions or deletions reported by the terraform plan command as all the approriate terraform configuration files will have have automatically been created.

## Requirements & Prerequisites
+ The tool is written for the bash shell script & Python3 and has been tested on macOS
+ AWS cli (V1) **version 1.17.4 or higher** needs to be installed and you need a login with at least "Read" priviledges
+ terraform **version v0.12.20 or higher** needs to be installed
+ jq **version 1.6 or higher**


## Quickstart guide to using the tool

Running the tool in your local shell (bash) required these steps:
1. Unzip or clone this git repo into an empty directory
2. login to the AWS cli  (aws configure)
3. run the tool


## Usage Guide

### The First Run
To generate the terraform files for an account and stop after a "terraform validate":
```
./aws2tf.sh -v yes
```

```
terraform validate
Success! The configuration is valid.
```

Or there may be some kind of python error. (as trying to test everyone's AWS combinations in advance isn't possible)

**If you happen to find one of these errors please open an issue here and paste in the error and it will get fixed.**

Once the validation is ok you can use the tool in anger to not only generate the terraform files (-v yes) but also import the resources and perform a terraform plan (see below)

---

<br>

To generate the terraform files for an entire AWS account, import the resourcs and perform a terraform plan:
```
./aws2tf.sh 
```


To include AWS account Policies and Roles:
```
./aws2tf.sh -p yes
```

To generate the terraform files for an EKS cluster
```
./eks2tf.sh
```



To filter the terraform resource type: (eg: just availability sets)
```
./aws2tf.sh -r vpc
```
To filter the terraform resource type: (eg: just availability sets) and fast forward - ie. build up resources one after another.:
```
./aws2tf.sh -r vpc
./aws2tf.sh -r subnet -f yes
```

To use the fast forward option correctly you'll need a good understanding of terraform resource dependancies to ensure you avoid any depenacy errors.

<br>

Be patient - lots of output is given as aws2tf:

+ Loops through each provider 
+ Creates the requited *.tf configuration files in the "generated" directory
+ Performs the necessary 'terraform import' commands
+ And finally runs a 'terraform plan'



## Supported Resource Types

The following terraform resource types are supported by this tool at this time:

Base Resources
* aws_resource_group


## Planned Additions

+ PaaS databases and other missing providers (feel free to contribute !)
+ ongoing better EKS support as EKS evolves
+ Other terraform providers as terraform supports


## Known problems

### Speed

It can take a lot of time to loop around everything in large accounts, in particular the importing of the resources.

### KMS:

Can fail if your login doesn't have acccess to KMS


### S3 Buckets

Can fail if your login/SPN doesn't have acccess to the KMS used for encryption.






