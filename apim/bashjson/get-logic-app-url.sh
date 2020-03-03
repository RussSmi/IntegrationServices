# This script needs to run in the bashjson folder
az rest --method post --uri https://management.azure.com/subscriptions/#{subscription-id}#/resourceGroups/rg-is-demo/providers/Microsoft.Logic/workflows/la-is-demo-receive/triggers/manual/listCallbackUrl?api-version=2016-10-01 > la-is-demo-receive.json
laurl=./bashjson.sh la-is-demo-receive.json basePath
lasig=./bashjson.sh la-is-demo-receive.json queries sig
laurltrim=${la-url%/manual/paths/invoke}
echo "##vso[task.setvariable=SERVICEURL]$(laurltrim)"
echo "##vso[task.setvariable=SIG]$(lasig)"


