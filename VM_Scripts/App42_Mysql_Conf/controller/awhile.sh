
counter=0
Storage_Name=$1

while [ $counter -lt 100 ]; do

storage_ac_name=`az storage account list --resource-group hdfcrgrdsrg|jq '.['$counter'].name'|cut -d'"' -f2`

if [ $storage_ac_name == $Storage_Name ]; then
	sku=$counter
	counter=101
	storage_ty=`az storage account list --resource-group hdfcrgrdsrg|jq '.['$sku'].sku.name'|cut -d'"' -f2`
else
	counter=$((counter+1))
fi
done

echo "storage_ac_name = $storage_ac_name ; storage_type = $storage_ty"


az storage blob show --account-name hdfcrgrdsf1fb6 --account-key aSzVlfrRmMQwcMoIPTwB8hgBUQXu+Ppl0nPS2P12FFyvI2X3Nas1urk8fVSHIhdfoDZ88VgMRw1kATg8rTnyrA== --container-name vhds --name hdfcrgrds-mysqlha2-20170310-1.vhd|jq '.metadata.microsoftazurecompute_disksizeingb'
