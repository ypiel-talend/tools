#!/bin/bash

usage() 
{
	echo "Usage :"
	echo "copyComponent2studio [options]... [component]... [-- libraries...]"
	echo "deploy a list of components to talend studio from source files"
	echo "-d Duplicate a component. It accepts only on component name. It duplicates it with a suffix, so you can copy an old version of your component in your studio."
	echo "-c clean osgi cache"
	echo "-l list components with given pattern"
	echo "-L list and copy components with given pattern"
	echo "-s start the studio after deploy"
	echo "-h this message"
}


[ -z "$tdi_compos_dir" ] 		&& tdi_compos_dir="/c/Users/akhabali/dev/github/tdi-studio-ee/main/plugins/org.talend.designer.components.tisprovider/components"
[ -z "$studio_dir" ] 			&& studio_dir="/c/Users/akhabali/dev/TalendStudio/6.5.0/Talend-Studio-20170929_2250-V6.5.0SNAPSHOT"
[ -z "$studio_tdi_compo_dir" ] 	&& studio_tdi_compo_dir=${studio_dir}"/plugins/org.talend.designer.components.tisprovider_6.5.0.20170929_2250-SNAPSHOT/components"  
[ -z "$studio_tdi_conf_dir" ] 	&& studio_tdi_conf_dir=${studio_dir}"/configuration"

[ -f ~/.copycompo2studio ] && echo "Loading " ~/.copycompo2studio && source ~/.copycompo2studio

echo "Environment :"
echo "    - Components folder: " $tdi_compos_dir
echo "    - Studio tdi compo folder: " $studio_tdi_compo_dir
echo "    - Studio tdi conf folder: " $studio_tdi_conf_dir
echo ""

if [ $# -eq 0 ]; then 
	usage
	exit 1	
fi

duplicate_suffix=""
studio_exe="Talend-Studio-win-x86_64.exe"
studio_options="-console"

REMOVE_CACHE=0
START_STUDIO=0
LIST_COMPO=0
COPY_LIST=0
DUPLICATE=0
while getopts dhsclL option 
do
	case $option in
		c) REMOVE_CACHE=1 ;;
		s) START_STUDIO=1 ;;
		l) LIST_COMPO=1 ;;
		L) COPY_LIST=1 && LIST_COMPO=1 ;;
		d) DUPLICATE=1 && duplicate_suffix="dup";;
		h) usage ;;
	esac
done

shift $(($OPTIND - 1))

if [ $# -eq 0 ]; then 
	usage
	exit 1	
fi

# Duplicate a component to the studio
if [ $DUPLICATE -eq 1 ]
then
	echo "Duplicate is over all other command..."
	if [ "$#" -ne 1 ]; then
		echo "There should be only one parameter for duplicate, the component name" && exit 1
	fi
	LIST_COMPO=0
	COPY_LIST=0
fi


LIST_COMPOS=""
if [ $LIST_COMPO -eq 1 ]
then
	echo "List components with given pattern '$1' :"
	LIST_COMPO=$(find ${tdi_compos_dir} -maxdepth 1 -type d -iname "$1" -exec basename {} \;)
	for c in ${LIST_COMPO}; do
		echo "	- " ${c}
	done
	[ $COPY_LIST -eq 0 ] && exit 0
fi

libs=0

# Copy component to the studio
if [ $COPY_LIST -eq 0 ]; then
	LIST_COMPO=$@
else
	read -p "Copy all found components ? [y/n]" resp
	[ "${resp}" != "y" ] && echo "aborded..." && exit 1
fi

REFRESH=0
for component in ${LIST_COMPO}
do
	[ "${component}" == "--" ] && libs=1 && break # if -- then after they are libraries to copy into studio
	compo_dir=${tdi_compos_dir}/${component}
	! [ -d "${compo_dir}" ] && echo "Compo dir doesn't exit : ${compo_dir}" && exit 1
	! [ -d "${studio_tdi_compo_dir}/${component}/" ] && echo "Destination compo dir doesn't exit : ${studio_tdi_compo_dir}/${component}/" && exit 1
	[ $DUPLICATE -eq 1 ] && mkdir -p ${studio_tdi_compo_dir}/${component}${duplicate_suffix}/ && rm -rf  ${studio_tdi_compo_dir}/${component}${duplicate_suffix}/*
	cp ${compo_dir}/* ${studio_tdi_compo_dir}/${component}${duplicate_suffix}/
	if [ $DUPLICATE -eq 1 ]
	then
		pushd $(pwd)
		cd ${studio_tdi_compo_dir}/${component}${duplicate_suffix}/ 
		echo "Rename all files fo duplciation in $(pwd)"
		find . -name "${component}*" | sed -e "s,./\(${component}\)\(.*\),mv \1\2 \1${duplicate_suffix}\2," | while read cmd; do $cmd; done
		echo "Component ${component} duplicated to ${studio_tdi_compo_dir} with suffix '${duplicate_suffix}'"
		popd
	else
		echo "Component ${component} to ${studio_tdi_compo_dir} copied"
	fi
	REFRESH=1
done

if [ ${libs} -eq 1 ]; then
	echo "Copy libs"
	echo "TO DO...."
fi

# Remove the eclipse cache of the studio
if [ $REMOVE_CACHE -eq 1 ]
then
	echo "Remove eclipse configuration cache..."
	cd $studio_tdi_conf_dir
	rm -rf org.eclipse*
fi

# Execute the studio
if [ $START_STUDIO -eq 1 ]
then
	echo "Execute : ${studio_dir}/${studio_exe} ${studio_options}"
	cd $studio_dir
	./${studio_exe} ${studio_options}
else
	[ $REFRESH -eq 1 ] && echo "" && echo "Please, refresh studio with CTRL+SHIFT+F3"
fi
