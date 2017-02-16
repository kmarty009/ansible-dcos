#!/bin/bash

# Create Ansible Config File

config_src="./ansible/ansible.cfg.template"
config_dest="./ansible.cfg"

cp -R $config_src $config_dest

echo "Path to .pem file, e.g. ~/.ssh/test_identity.pem"
read pempath

sed -i '' "s|pemfile|$pempath|g" $config_dest

# Create setup config

setup_directory="./group_vars/all"
setup_dest="$setup_directory/setup.yaml"

if [ -f $setup_dest ]; then
	echo "Setup file exists. Delete $setup_dest and rerun the script"
else
	mkdir -p $setup_directory

	echo "Please name your cluster (e.g. dcos-ansible-test) no pipes (|)"
	read cluster_name
	echo "cluster_name: \"$cluster_name\"" >> $setup_dest

	echo "Enterprise DC/OS or OSS DC/OS"
	echo "Please select your choice: "
	options=("Enterprise DC/OS" "OSS DC/OS")
	select opt in "${options[@]}"
	do
		case $opt in
			"Enterprise DC/OS")
				echo "Enterprise DC/OS Selected"

				echo "enterprise_dcos: true" >> $setup_dest

				echo "Please input download URL starting with http://downloads..."
				read download_url
				echo "dcos_download: $download_url" >> $setup_dest

				echo "Please input customer key provided by Mesosphere like ########-####-####-####-############"
				read customer_key
				echo "customer_key: \"$customer_key\"" >> $setup_dest

				echo "Please select a security mode (permissive is default)"
				security_mode_opt=("strict" "permissive" "disabled")
				select security_mode in "${security_mode_opt[@]}"
				do
					echo "security: $security_mode" >> $setup_dest && break
				done

				echo "Select RexRay Config Method (default empty)"
				rexray_config_method_opt=("file" "empty")
				select rexray_config_method in "${rexray_config_method_opt[@]}"
				do
					echo "rexray_config_method: $rexray_config_method" >> $setup_dest
					#if [ $rexray_config_method = "file" ]; then
						#echo "Please input the file path and name of the rexray config"
						#read rexray_config_filename
						#sed -i '' "s|rexray-config-filename|$rexray_config_filename|g" $setup_dest
					#fi
					break
				done
				break
				;;
			"OSS DC/OS")
				echo "OSS DC/OS Selected"

				echo "enterprise_dcos: false" >> $setup_dest

				echo "Please input download URL starting with http://downloads..."
				read download_url
				echo "dcos_download: $download_url" >> $setup_dest

				break
				;;
			*) echo invalid option;;
		esac
	done
	echo "Exhibitor backend (aws_s3, zookeeper, shared_filesystem, static) - if unsure select static"
	echo "Please select your choice: "
	options=("aws_s3" "zookeeper" "shared_filesystem" "static")
	select opt in "${options[@]}"
	do
		case $opt in
			"aws_s3")

				echo "exhibitor: $opt" >> $setup_dest

				echo "aws_access_key_id:"
				read key_id
				echo "aws_access_key_id: \"$key_id\"" >> $setup_dest

				echo "aws_secret_access_key:"
				read key_secret
				echo "aws_secret_access_key: \"$key_secret\"" >> $setup_dest

				echo "aws_region:"
				read s3_region
				echo "aws_region: \"$s3_region\"" >> $setup_dest

				echo "s3_bucket:"
				read s3_bucket
				echo "s3_bucket: \"$s3_bucket\"" >> $setup_dest

				echo "s3_prefix:"
				read s3_prefix
				echo "s3_prefix: \"$s3_prefix\"" >> $setup_dest

				break
				;;
			"zookeeper")
				echo "exhibitor: $opt" >> $setup_dest
				echo "Zookeeper is hosted from workstation node, not recommended for production use without modification"
				break
				;;
			"shared_filesystem")
				echo "exhibitor: $opt" >> $setup_dest
				echo "Shared Filesystem is hosted from workstation node, not recommended for production use without modification"
				break
				;;
			"static")
				echo "exhibitor: $opt" >> $setup_dest
				break
				;;
			*) echo invalid option;;
		esac
	done
fi
