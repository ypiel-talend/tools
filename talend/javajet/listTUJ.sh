#!/bin/bash

usage() 
{
	echo "Usage :"
	echo "listTUJ name"
	echo "List available TUJ by their name and copy them to a folder to make easy their import in studio."
	echo "-c clean output dir before copy"
	echo "-t copy template too"
	exit 0
}


[ -z "$tdi_tuj_dir" ] 		&& tdi_tuj_dir="/c/Devx/Github/Talend/tuj/tuj/java/"
[ -z "$output_tuj_dir" ] 	&& output_tuj_dir="/c/temp/tujs/"

[ -f ~/.copycompo2studio ] && echo "Loading " ~/.copycompo2studio && source ~/.copycompo2studio

echo "Environment :"
echo "    - TUJs folder: " $tdi_tuj_dir
echo "    - Output folder: " $output_tuj_dir
echo ""

if [ $# -eq 0 ]; then 
	usage
	exit 1	
fi

if [ $# -eq 0 ]; then 
	usage
	exit 1	
fi

COPY_TEMPLATE=0
while getopts hct option 
do
	case $option in
		c) echo "Clean output folder..." && rm -rf ${output_tuj_dir}/*  ;;
		t) COPY_TEMPLATE=1 ;;
		h) usage ;;
	esac
done

shift $(($OPTIND - 1))

echo "Search for '$1' TUJs..."
LIST_TUJS=$(find ${tdi_tuj_dir} -maxdepth 1 -type d -iname $1)
for t in ${LIST_TUJS}; do
	echo "	- " ${t}
done
read -p "Copy all found TUJs ? [y/n] " resp
[ "${resp}" != "y" ] && echo "aborded..." && exit 1

for t in ${LIST_TUJS}; do
	cp -R ${t} ${output_tuj_dir}/
done

echo "TUJs copied into ${output_tuj_dir}."

if [ $COPY_TEMPLATE -eq 1 ]
then
	[ -d "${tuj_template}" ] && cp -R ${tuj_template} ${output_tuj_dir}/ && echo "Template copied too."
fi
