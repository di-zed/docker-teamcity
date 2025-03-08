#!/bin/bash

FOLDER_NAME="TeamCity_Backup_$(date +%Y%m%d_%H%M%S)"
FOLDER_NAME_SENSITIVE="${FOLDER_NAME}_sensitive"
FOLDER_NAME_SANITIZED="${FOLDER_NAME}_sanitized"

echo "01. Creating a backup copy of $FOLDER_NAME.zip..."
docker-compose exec teamcity ./opt/teamcity/bin/maintainDB.sh backup -C -D -U --backup-file $FOLDER_NAME

echo "02. Copying backup $FOLDER_NAME.zip from container..."
docker-compose cp teamcity:/data/teamcity_server/datadir/backup/$FOLDER_NAME.zip ./

echo "03. Unpacking backup copy $FOLDER_NAME.zip..."
unzip $FOLDER_NAME.zip -d ./$FOLDER_NAME
find ./$FOLDER_NAME -type d -exec chmod 755 {} \; && find ./$FOLDER_NAME -type f -exec chmod 644 {} \;

echo "04. Creating a folder to back up sensitive data..."
mkdir -p ./$FOLDER_NAME_SENSITIVE
mkdir -p ./$FOLDER_NAME_SENSITIVE/config

echo "05. Removing the encryption key from the main-config.xml..."
cp ./$FOLDER_NAME/config/main-config.xml ./$FOLDER_NAME_SENSITIVE/config/main-config.xml
sed -i '' 's/encryption-key="[^"]*"/encryption-key="REMOVED"/' ./$FOLDER_NAME/config/main-config.xml

echo "06. Removing the encryption keys from the encryption-config.xml..."
cp ./$FOLDER_NAME/config/encryption-config.xml ./$FOLDER_NAME_SENSITIVE/config/encryption-config.xml
sed -i '' 's/<key value="[^"]*"/<key value="REMOVED"/g' ./$FOLDER_NAME/config/encryption-config.xml

echo "07. Removing the database connection properties from the database.properties..."
cp ./$FOLDER_NAME/config/database.properties ./$FOLDER_NAME_SENSITIVE/config/database.properties
sed -i '' 's/^connectionProperties.user=.*/connectionProperties.user=REMOVED/' ./$FOLDER_NAME/config/database.properties
sed -i '' 's/^connectionProperties.password=.*/connectionProperties.password=REMOVED/' ./$FOLDER_NAME/config/database.properties

echo "08. Removing all private keys from backup..."
find "./$FOLDER_NAME" -type f | while read file; do
  if head -n 1 "$file" | grep -q "PRIVATE KEY"; then
    dest_dir="./$FOLDER_NAME_SENSITIVE/$(dirname "$file" | sed "s|./$FOLDER_NAME/||")"
    mkdir -p "$dest_dir"
    mv "$file" "$dest_dir/"
    echo "Moved file with key: $file to $dest_dir"
  fi
done

if grep -r "PRIVATE KEY" "./$FOLDER_NAME"; then
  echo "==============="
  echo "WARNING! Private keys found in the backup!"
  echo "==============="
fi

echo "09. Setting the correct permissions on the folder with sensitive data..."
find ./$FOLDER_NAME_SENSITIVE -type d -exec chmod 755 {} \; && find ./$FOLDER_NAME_SENSITIVE -type f -exec chmod 644 {} \;

echo "10. Archiving data..."
zip -r $FOLDER_NAME_SANITIZED.zip ./$FOLDER_NAME
zip -r $FOLDER_NAME_SENSITIVE.zip ./$FOLDER_NAME_SENSITIVE

echo "11. Deleting old data..."
rm ./$FOLDER_NAME.zip
rm -rf ./$FOLDER_NAME
rm -rf ./$FOLDER_NAME_SENSITIVE

echo ""
echo "SUCCESS!"
echo "Sanitized backup (data that can be stored as a backup): ./$FOLDER_NAME_SANITIZED.zip"
echo "Sensitive backup (very sensitive data, better to store separately from backup): ./$FOLDER_NAME_SENSITIVE.zip"