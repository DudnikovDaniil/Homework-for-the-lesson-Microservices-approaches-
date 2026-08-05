#!/bin/bash
echo "===  СТАТУС ВСЕХ СЕРВИСОВ ==="
echo

echo "--- Контейнеры ---"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo
echo "--- Проверка доступности ---"

check() {
    echo -n "$1: "
    if curl -s -o /dev/null -w "%{http_code}" "$2" 2>/dev/null | grep -q "${3:-200}"; then
        echo " OK"
    else
        echo " FAIL"
    fi
}

check "Kibana" "http://localhost:8081" "302|200"
check "Grafana" "http://localhost:3000" "302|200"
check "Prometheus" "http://localhost:9090" "200"
check "Elasticsearch" "http://localhost:9200" "200"
check "Security Service" "http://localhost:9091/metrics" "200"
check "Uploader Service" "http://localhost:9092/metrics" "200"
check "API Gateway" "http://localhost:8080" "200"
check "Storage (MinIO)" "http://localhost:9000/minio/v2/metrics/cluster" "200"

echo
echo "--- Индексы Elasticsearch ---"
INDICES=$(curl -s -u elastic:qwerty123456 "http://localhost:9200/_cat/indices" | grep logs)
if [ -n "$INDICES" ]; then
    echo " Найдены индексы:"
    echo "$INDICES"
else
    echo " Индексы логов не найдены (подождите 30 секунд)"
fi

echo
echo "===  ДОСТУПНЫЕ URL ==="
echo " Kibana (логи):    http://localhost:8081  (admin / qwerty123456)"
echo " Grafana (метрики): http://localhost:3000  (admin / qwerty123456)"
echo " Prometheus:       http://localhost:9090"
echo " Security Service: http://localhost:9091"
echo " Uploader Service: http://localhost:9092"
echo " Storage (MinIO):  http://localhost:9000"
echo " API Gateway:      http://localhost:8080"
