#!/bin/bash
echo " Генерация трафика..."
for i in {1..30}; do
    echo " Request #$i"
    curl -s http://localhost:8080/security/login > /dev/null
    curl -s http://localhost:8080/security/ > /dev/null
    curl -s -X POST http://localhost:8080/uploader/upload > /dev/null
    curl -s http://localhost:8080/uploader/ > /dev/null
    curl -s http://localhost:8080/storage/minio/v2/metrics/cluster > /dev/null
    sleep 1
done
echo " Готово!"
