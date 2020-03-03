# This script needs to run in the bashjson folder
az rest --method post --uri https://management.azure.com/subscriptions/#{subscription-id}#/resourceGroups/rg-is-demo/providers/Microsoft.Logic/workflows/la-is-demo-receive/triggers/manual/listCallbackUrl?api-version=2016-10-01 > la-is-demo-receive.json
la-url=./bashjson.sh la-is-demo-receive.json basePath
la-sig=./bashjson.sh la-is-demo-receive.json queries sig
la-url-trim=${la-url%/manual/paths/invoke}
echo "##vso[task.setvariable=SERVICEURL]$la-url-trim"
echo "##vso[task.setvariable=SIG]$la-sig"


