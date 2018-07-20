region=`/usr/bin/ec2metadata --availability-zone|rev|cut -c 2-20|rev`

echo "[default]
output = json
region = $region
aws_access_key_id = xxxxxxxxxxxxxxxxxx
aws_secret_access_key = xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" >/root/.aws/config
