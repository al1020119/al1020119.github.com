---
layout: post
title: "自动打包上传代码"
date: 2016-12-06 18:16:05 +0800
comments: true
categories: 
---


##封装


####使用前：

1. 安装pip
2. sudo easy_install pip
3. 安装json-query
4. pip install json-query
5. 安装 gym
6. pip install gym


<!--more-->



####新建一个.sh文件，好了开始撸，，哒哒哒哒哒。。。。
	
	#!/bin/sh
	#LEPgyerApiKey 在Info.plist中配置蒲公英apiKey
	#LEPgyerUKey 在Info.plist中配置蒲公英ukey
	
	result=''
	uploadToPgyer()
	{
		echo "params" 
		echo "ipa路径:  " $1
		echo "UserKey: " $2
		echo "ApiKey:  " $3
		echo "Password:" $4
		result=$(curl -F "file=@$1" -F "uKey=$2" -F "_api_key=$3" -F "publishRange=2" -F "isPublishToPublic=2" -F "password=$4" 'https://www.pgyer.com/apiv1/app/upload' | json-query data.appShortcutUrl)
	}
	
	tempPath="$(pwd)" 
	if [ ! -f pkgtopgy_path.config ] ; then 
		touch pkgtopgy_path.config
	fi
	
	lines=`sed -n '$=' pkgtopgy_path.config` 
	
	if [[ $lines == '' ]]; then
		lines=0
	fi  
	
	echo "请选择你需要打包的目录："
	for i in `cat pkgtopgy_path.config `
	do
		echo  $((++no)) ":" $i
	done
	echo  $((++no)) ":" "${tempPath}"
		
	echo "若没有符合需求的路径，请直接回车"
	read -p "你的选择是：" pathselection
	if [[ $pathselection >0 ]] && [[ $pathselection -le `expr $lines+1` ]] ; then
		if [[ $pathselection -le $lines ]] ; then
			project_path=`sed -n ${pathselection}p pkgtopgy_path.config` 
		else 
			echo "已选目录：${tempPath}" 
			read -p "请确认上述已选目录：(y/n)" checkPath
			if [[ $checkPath = "y" ]] ; then
				project_path=$tempPath
			fi
		fi 
	else
		echo "未找到合适的路径"
	fi	
	
	if [[ $project_path == '' ]]; then 
		read -p "请手动输入打包工程的绝对路径:" inputPath
		project_path=$inputPath
		if [[ $project_path != '' ]]; then 
			echo $project_path >> pkgtopgy_path.config
			cat pkgtopgy_path.config
		fi
	fi
	
	
	if [[ -d "$project_path" ]]; then
		echo "当前路径为：" $project_path
	else
		echo "路径："$project_path
		echo "当前路径有误，已终止!!!\n"
		exit
	fi
	SECONDS=0
	#取当前时间字符串添加到文件结尾
	now=$(date +"%Y_%m_%d_%H_%M_%S")
	#工程名
	cd ${project_path}
	project=$(ls | grep xcodeproj | awk -F.xcodeproj '{print $1}')
	#指定项目地址
	workspace_path="$project_path/${project}.xcworkspace"
	if [[ ! -d "$workspace_path" ]]; then
		echo "路径："$workspace_path
		echo "未找到.xcworkspace文件，已终止!!!"
		exit
	fi
	#工程配置文件路径
	echo "检查蒲公英设置"
	project_infoplist_path=${project_path}/${project}/Info.plist
	pgyerApiKey=''
	pgyerUKey=''
	pgyerApiKey=$(/usr/libexec/PlistBuddy -c "print LEPgyerApiKey" ${project_infoplist_path})
	pgyerUKey=$(/usr/libexec/PlistBuddy -c "print LEPgyerUKey" ${project_infoplist_path})
	pgyPassword=$(/usr/libexec/PlistBuddy -c "print LEPgyerPassword" ${project_infoplist_path})
	if [[ $pgyerUKey = '' ]] || [[ $pgyerApiKey = '' ]]; then
		read -p "发现尚未配置蒲公英上传的apiKey及ukey,是否配置?(y/n)" checkConfig
		if [[ $checkConfig = "y" ]] ; then
			read -p "请输入蒲公英上传的apiKey:" apikey
			pgyerApiKey=$apikey
			read -p "请输入蒲公英上传的ukey:" ukey
			pgyerUKey=$ukey
		else
			if [[ $pgyPassword = '' ]]; then
				echo '发现蒲公英下载密码，未在工程项目的Info.plist配置，配置名称为LEPgyerPassword'
			fi
			read -p "是否继续打包?(y/n)" checkPkg
			if [[ $checkPkg = "n" ]] ; then
				exit
			fi
		fi
	fi
	 
	#指定项目的scheme名称
	scheme=$project
	#指定要打包的配置名
	configuration="Release"
	#指定打包所使用的输出方式，目前支持app-store, package, ad-hoc, enterprise, development, 和developer-id，即xcodebuild的method参数
	export_method='development'
	#export_method='app-store'
	
	#指定输出路径
	mkdir "${HOME}/Desktop/${project}_${now}"
	output_path="${HOME}/Desktop/${project}_${now}"
	echo $output_path
	#指定输出归档文件地址
	archive_path="$output_path/${project}_${now}.xcarchive"
	#指定输出ipa地址
	ipa_path="$output_path/${project}_${now}.ipa"
	#指定输出ipa名称
	ipa_name="${project}_${now}.ipa"
	#获取执行命令时的commit message
	commit_msg="$1"
	#输出设定的变量值
	echo "=================AutoPackageBuilder==============="
	echo "begin package at ${now}"
	echo "workspace path: ${workspace_path}"
	echo "archive path: ${archive_path}"
	echo "ipa path: ${ipa_path}"
	echo "export method: ${export_method}"
	echo "commit msg: $1"
	#pod update
	#pod update --no-repo-update
	#先清空前一次build
	#gym --workspace ${workspace_path} --scheme ${scheme} --clean --configuration ${configuration} --archive_path ${archive_path} --export_method ${export_method} --output_directory ${output_path} --output_name ${ipa_name}
	gym --workspace ${workspace_path} --scheme ${scheme} --clean --configuration ${configuration} --export_method ${export_method} --output_directory ${output_path} --output_name ${ipa_name}
	#输出总用时
	echo "==================>Finished. Total time: ${SECONDS}s" 
	
	if [[ $pgyerUKey = '' ]] || [[ $pgyerApiKey = '' ]]; then
		echo "未在工程项目的Info.plist文件中配置LEPgyerApiKey（蒲公英apiKey）及LEPgyerUKey（蒲公英userKey），因此无法上传项目至蒲公英平台"
	else 
		if [[ -f "$ipa_path" ]]; then
			uploadToPgyer $ipa_path $pgyerUKey $pgyerApiKey $pgyPassword 
			while [[ $result == '' ]]
			do
				read -p "上传失败，是否重新上传到蒲公英?(y/n)" reUploadToPgyer
				if [[ $reUploadToPgyer = "y" ]] ; then
					uploadToPgyer $ipa_path $pgyerUKey $pgyerApiKey $pgyPassword
				else
					echo "本次打包完成，ipa位置: ${ipa_path}" 
					exit
				fi
			done
			if [[ $result != '' ]]; then
				echo "请前往此处下载最新的app" http://www.pgyer.com/$result
				open http://www.pgyer.com/$result
			fi 
		fi
	fi
	echo "本次打包完成"
	exit

##测试使用（DEV环境）

1. 下载pkgtopgy.sh至任意目录 
2. 终端新建窗口 输入sh （sh+空格），
3. 然后拖入文件 pkgtopgy.sh 回车 （也可以右击-显示简介-打开方式设置为终端，然后双击打开） 



===





    Q Q：2211523682/790806573

    微信：18370997821/13148454507
    
    微博WB:http://weibo.com/u/3288975567?is_hot=1
    
	git博文：http://al1020119.github.io/
	
	github：https://github.com/al1020119


{% img /images/iCocosCoder.jpg Caption %}  

{% img /images/iCocosPublic.jpg Caption %}  