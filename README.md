Log Mysql Connections
=====================

Description
-----------
This Bash tool was created to compile a unique list of IP's that are connecting to a configured Mysql Database. The purpose was to have basic way to passively gather this data to confirm connected IP's.  

#### Example | usage
```
./get-client-ips/app.sh --help
./get-client-ips/app.sh --config="config/test.conf" --log="log/my-database.log"

### If you want to poll the db
watch -n3 './get-client-ips/app.sh --config="config/test.conf" --log="log/my-database.log"'
```