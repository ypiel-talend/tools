#!/bin/bash

usage() 
{
	echo "Usage :"
	echo "copyComponent2studio [options]... [component]... [-- libraries...]"
	echo "deploy a list of components to talend studio from source files"
	echo "-c clean osgi cache"
	echo "-l list components with given pattern"
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

studio_exe="Talend-Studio-win-x86_64.exe"
studio_options="-console"

REMOVE_CACHE=0
START_STUDIO=0
LIST_COMPO=0
while getopts hscl option 
do
	case $option in
		c) REMOVE_CACHE=1 ;;
		s) START_STUDIO=1 ;;
		l) LIST_COMPO=1 ;;
		h) usage ;;
	esac
done

shift $(($OPTIND - 1))

if [ $# -eq 0 ]; then 
	usage
	exit 1	
fi

if [ $LIST_COMPO -eq 1 ]
then
	echo "List components with given pattern '$1' :"
	find ${tdi_compos_dir} -maxdepth 1 -type d -name "$1" -exec basename {} \;
	exit 0
fi

libs=0

# Copy component to the studio
for component in $@
do
	[ "${component}" == "--" ] && libs=1 && break # if -- then after they are libraries to copy into studio
	compo_dir=${tdi_compos_dir}/${component}
	! [ -d "${compo_dir}" ] && echo "Compo dir doesn't exit : ${compo_dir}" && exit 1
	! [ -d "${studio_tdi_compo_dir}/${component}/" ] && echo "Destination compo dir doesn't exit : ${studio_tdi_compo_dir}/${component}/" && exit 1
	cp ${compo_dir}/* ${studio_tdi_compo_dir}/${component}/
	echo "Component ${component} to ${studio_tdi_compo_dir} copied"
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
fi
