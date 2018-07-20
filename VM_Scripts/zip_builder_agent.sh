#!/bin/bash
dep_id=$2

case $1 in

create_zip)

	mkdir -p $HOME/$dep_id
	cd  $HOME/$dep_id && git clone $3 > $HOME/file_$dep_id
	if [ $? = 0 ]; then
		dir=`cat $HOME/file_$dep_id |cut -d"'" -f2`
		rm -rf $HOME/$dep_id/$dir/.git
		cd $HOME/$dep_id && zip -r $dir.zip $dir
		if [ $? = 0 ]; then
			mkdir -p $HOME/zip_$dep_id
			mv $HOME/$dep_id/$dir.zip $HOME/zip_$dep_id/$dir.zip
			rm -rf $HOME/$dep_id $HOME/file_$dep_id
			echo '{"code":5000,"success":"true","message":"Zip File Created Successfully","path":"'$HOME/zip_$dep_id/$dir.zip'"}'
		else
			rm -rf $HOME/$dep_id $HOME/file_$dep_id
			echo '{"success":"false","code":8301,"message":"Error In Creating Binary"}'
		fi
		
	else
		rm -rf $HOME/$dep_id $HOME/file_$dep_id
		echo '{"success":"false","code":8303,"message":"Error In Cloning GIT Repository"}'
	fi;;


delete)

	if [ -d $HOME/zip_$dep_id ]; then
		rm -rf $HOME/zip_$dep_id
		echo '{"code":5000,"success":"true","message":"Zip File Deleted Successfully"}'
	else
		echo '{"success":"false","code":8304,"message":"Error In Deleting Binary"}'
	fi;;
esac
