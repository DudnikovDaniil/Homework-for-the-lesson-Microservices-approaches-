#!/bin/bash
echo " Генерация трафика для Dashboard..."
for i in {1..100}; do
    # Разные запросы к security
    curl -s http://localhost:8080/security/login > /dev/null
    curl -s http://localhost:8080/security/ > /dev/null
    
    # Разные запросы к uploader
    curl -s -X POST http://localhost:8080/uploader/upload > /dev/null
    curl -s http://localhost:8080/uploader/ > /dev/null
    
    # Запросы к storage
    curl -s http://localhost:8080/storage/minio/v2/metrics/cluster > /dev/null
    
    if [ $((i % 10)) -eq 0 ]; then
        echo " Сгенерировано $i запросов"
    fi
    sleep 0.5
done
echo " Готово! Сгенерировано 100 запросов"
