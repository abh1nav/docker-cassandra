#!/bin/bash
#

## In below given variables - require information to be feed by system admin##
# For _NODETOOL , you can replace $(which nodetool) with  absolute path of nodetool command.
#

_HOST=127.0.0.1
_BACKUP_DIR=/backup
_DATA_DIR=/opt/cassandra/data

export LC_ALL=en_US.UTF-8
_CQLSH=$(which cqlsh)
_CQLSH=${_CQLSH}" ${_HOST}";
_NODETOOL=$(which nodetool)

mkdir /backup/
## Do not edit below given variable ##

_TODAY_DATE=$(date +%F_\%T)
_BACKUP_SNAPSHOT_DIR="$_BACKUP_DIR/$_TODAY_DATE/SNAPSHOTS"
_BACKUP_SCHEMA_DIR="$_BACKUP_DIR/$_TODAY_DATE/SCHEMA"
_SNAPSHOT_DIR=$(find $_DATA_DIR -type d -name snapshots)
_SNAPSHOT_NAME=snp-$(date +%F-%H%M-%S)
_DATE_SCHEMA=$(date +%F-%H%M-%S)


###### Create / check backup Directory ####

if [ -d  "$_BACKUP_SCHEMA_DIR" ]
then
  echo "$_BACKUP_SCHEMA_DIR already exist"
else
  mkdir -p "$_BACKUP_SCHEMA_DIR"
fi

if [ -d  "$_BACKUP_SNAPSHOT_DIR" ]
then
  echo "$_BACKUP_SNAPSHOT_DIR already exist"
else
  mkdir -p "$_BACKUP_SNAPSHOT_DIR"
fi



##################### SECTION 1 : SCHEMA BACKUP ############################################ 

## List All Keyspaces
${_CQLSH} -e "DESC KEYSPACES" |perl -pe 's/\e([^\[\]]|\[.*?[a-zA-Z]|\].*?\a)//g' | sed '/^$/d' > Keyspace_name_schema.cql

#_KEYSPACE_NAME=$(cat Keyspace_name_schema.cql)

## Create directory inside backup SCHEMA directory. As per keyspace name.
for i in $(cat Keyspace_name_schema.cql)
do
  i=$(echo $i| tr -d '"')
  if [ -d $i ]
  then
    echo "$i directory exist"
  else
    mkdir -p $_BACKUP_SCHEMA_DIR/$i
  fi
done

## Take SCHEMA Backup - All Keyspace and All tables
for VAR_KEYSPACE in $(cat Keyspace_name_schema.cql)
do
  VAR_KEYSPACE_NOTICKS=$(echo $VAR_KEYSPACE| tr -d '"')
  ${_CQLSH} -e "DESC KEYSPACE  $VAR_KEYSPACE" > "$_BACKUP_SCHEMA_DIR/$VAR_KEYSPACE_NOTICKS/$VAR_KEYSPACE_NOTICKS"_schema-"$_DATE_SCHEMA".cql 
done


##################### END OF LINE ---- SECTION 1 : SCHEMA BACKUP #####################

###### Create snapshots for all keyspaces
echo "creating snapshots for all keyspaces ....."
$_NODETOOL snapshot -t $_SNAPSHOT_NAME

###### Get Snapshot directory path
_SNAPSHOT_DIR_LIST=`find $_DATA_DIR -type d -name snapshots|awk '{gsub("'$_DATA_DIR'", "");print}' > snapshot_dir_list`

#echo $_SNAPSHOT_DIR_LIST > snapshot_dir_list

## Create directory inside backup directory. As per keyspace name.
for i in `cat snapshot_dir_list`
do
  if [ -d $_BACKUP_SNAPSHOT_DIR/$i ]
  then
    echo "$i directory exist"
  else
    mkdir -p $_BACKUP_SNAPSHOT_DIR/$i
    echo $i Directory is created
  fi
done

### Copy default Snapshot dir to backup dir

find $_DATA_DIR -type d -name $_SNAPSHOT_NAME > snp_dir_list

for SNP_VAR in `cat snp_dir_list`;
do
  ## Triming _DATA_DIR
  _SNP_PATH_TRIM=`echo $SNP_VAR|awk '{gsub("'$_DATA_DIR'", "");print}'`
  
  cp -prvf "$SNP_VAR" "$_BACKUP_SNAPSHOT_DIR$_SNP_PATH_TRIM";
  
done

# flush commitlogs (for quicker startup)
cd /opt/cassandra/commitlog/ && $_NODETOOL flush


