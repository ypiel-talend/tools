#!/bin/bash
echo "Copy a dev java jet component into an installated studio."
echo "This is to not execute studio from eclipse RCP."

tdi_compos_dir="/c/Dev/github2/tdi-studio-se/main/plugins/org.talend.designer.components.localprovider/components"
studio_dir="/c/Dev/Talend/Studio/6.5/Talend-Studio-20170804_1931-V6.5.0SNAPSHOT"
studio_tdi_compo_dir=${studio_dir}"/plugins/org.talend.designer.components.localprovider_6.5.0.20170804_1931-SNAPSHOT/components"
studio_tdi_conf_dir=${studio_dir}"/configuration"

export studio_exe="Talend-Studio-win-x86_64.exe"
export studio_options="-console"

compo="undefined"
[ "$1" != "" ] && compo="$1"
compo_dir=${tdi_compos_dir}/${compo}

# Copy component to the studio
while ! [ -d $compo_dir ]
do
	[ "${compo}" != "" ] && echo "${compo} is not a valid component..."
	read -p "Component name : " compo
	compo_dir=${tdi_compos_dir}/${compo}
done

echo "Copy ${compo} to ${studio_tdi_compo_dir}"
cp ${compo_dir}/* ${studio_tdi_compo_dir}/${compo}/


remove_cache=""

while [ "${remove_cache}" != "y" ] && [ "${remove_cache}" != "n" ]
do
	read -p "Remove eclipse cache ? [y/n] " remove_cache
done

# Remove the eclipse cache of the studio
if [ "${remove_cache}" = "y" ]
then
	echo "Remove eclipse configuration cache..."
	pushd $(pwd)
	cd studio_tdi_conf_dir
	rm -rf org.eclipse*
	popd
fi

std_exec=""

# Execute the studio
while [ "${std_exec}" != "y" ] && [ "${std_exec}" != "n" ]
do
	read -p "Execute the studio ? [y/n] " std_exec
done

if [ "${std_exec}" = "y" ]
then
	echo "Execute : ${studio_dir}/${studio_exe} ${studio_options}"
	pushd $(pwd)
	cd ${studio_dir}
	./${studio_exe} ${studio_options}
	popd
fi

echo "Done."