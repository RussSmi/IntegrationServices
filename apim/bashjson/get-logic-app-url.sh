# This script needs to run in the bashjson folder
az rest --method post --uri https://management.azure.com/subscriptions/#{subscription-id}#/resourceGroups/rg-is-demo/providers/Microsoft.Logic/workflows/la-is-demo-receive/triggers/manual/listCallbackUrl?api-version=2016-10-01 > la-is-demo-receive.json
LAURL=$(./bashjson.sh la-is-demo-receive.json basePath)
LASIG=$(./bashjson.sh la-is-demo-receive.json queries sig)
LAURLTRIM=${LAURL%/manual/paths/invoke}
echo "##vso[task.setvariable=SERVICEURL]$LAURLTRIM"
echo "##vso[task.setvariable=SIG]$LASIG"