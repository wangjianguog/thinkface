#!/bin/bash

# need 1 input parameters
if [ $# -ne 1 ]; then
    echo "Usage: $0 <IMAGE_TAG>"
    exit
fi

DATA_DIR=$PWD/rs-fast-60001
DB_PASSWORD=123456
RS_VERSION=10.120.17.37:5000/rs-server-fast:$1
RS_SERVER_NAME=rs-server-60001
RS_DB_NAME=rs-db-60001
RS_SERVER_PORT=60001

docker stop $RS_SERVER_NAME
docker stop $RS_DB_NAME

docker rm $RS_SERVER_NAME
docker rm $RS_DB_NAME

## path to save data !!!! change 
mkdir -p $DATA_DIR
mkdir $DATA_DIR/faceData
mkdir $DATA_DIR/mysql-data
mkdir $DATA_DIR/logs

## setup mysql-server
## copy base mysql data !!!! change password, current is 123456

docker run 	-d \
           	--name $RS_DB_NAME \
		-v $DATA_DIR/mysql-data:/var/lib/mysql \
		-e MYSQL_ROOT_PASSWORD=$DB_PASSWORD \
		mysql:5.7


read -p "press enter after mysql configuration..."  cmd


##
## mysql setting
## create database leface_60001;
## grant all privileges on *.* to 'root'@'%' identified by 'lenovo_149569!' with grant option;
## flush privileges;
## 

## setup recognitioin server
## 

docker run 	-dt \
		-p $RS_SERVER_PORT:60001 \
        	--dns=10.96.1.18 \
		-v $DATA_DIR/faceData/:/home/RecognitionServer/bin/faceData \
                -v $DATA_DIR/logs/:/home/RecognitionServer/bin/logs \
		--link $RS_DB_NAME:docker-mysql \
		--name $RS_SERVER_NAME \
		$RS_VERSION

## copy license
docker cp ../recog-new-license $RS_SERVER_NAME:/home/RecognitionServer/bin/model/license

## copy config files
## !!!! change mysql password & url (optional) in Beans.xml & fs.xml
## !!!! change app.id & app.secret in application.properties
docker cp ./FaceConfig $RS_SERVER_NAME:/home/RecognitionServer/bin/FaceConfig



## restart $RS_SERVER_NAME
docker restart $RS_SERVER_NAME
