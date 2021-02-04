#!/bin/bash
if [ "$DEBUG" == "true" ]; then
    set -x
fi

helpFunction()
{
   echo ""
   echo "Usage: docker build -t foo . && docker run -it  -v /path-to-projects:/projects -r {swagger_folder}"
   exit 1 # Exit script after printing help
}

while getopts "r:" opt
do
   echo @@@ "$opt"
   case "$opt" in
      "r" ) export readme_file_path="$OPTARG" ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

# Print helpFunction in case parameters are empty
if [ -z "$readme_file_path" ]
then
   echo "please input swagger folder name path by -r";
   helpFunction
else
    echo "swagger folder: $readme_file_path"
fi

export readme_file_path="/projects/azure-rest-api-specs/specification/$readme_file_path/resource-manager"

dir $readme_file_path
# generate code
autorest --az --use=/projects/autorest.az $readme_file_path/readme.md --azure-cli-extension-folder=/projects/azure-cli-extensions --debug

if [ "$?" != "0" ]; then
    echo -e "\e[31m[$(date -u)] ERROR: codegen failed"
    exit 1
fi

. /opt/venv/bin/activate
azdev setup --cli /projects/azure-cli --repo /projects/azure-cli-extensions


az login --service-principal --username [PLACEHOLDER] --password [PLACEHOLDER] --tenant [PLACEHOLDER]
export extension_name=`cat $readme_file_path/readme.az.md | grep extensions | awk '{print $NF}' | tr -d '\r'`
echo "testing $extension_name"
azdev extension add $extension_name
azdev test $extension_name --live --discover
exit 0


