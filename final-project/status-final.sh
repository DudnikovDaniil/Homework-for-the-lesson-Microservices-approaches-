#!/bin/bash
echo "===  ФИНАЛЬНЫЙ СТАТУС СИСТЕМЫ ==="
echo

echo "--- Контейнеры ---"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo
echo "--- Проверка сервисов ---"

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
check "Security Service" "http://localhost:9091/" "200"
check "Uploader Service" "http://localhost:9092/" "200"
check "API Gateway" "http://localhost:8080" "200"

echo
echo "--- Индексы Elasticsearch ---"
INDICES=$(curl -s -u elastic:qwerty123456 "http://localhost:9200/_cat/indices" 2>/dev/null | grep logs)
if [ -n "$INDICES" ]; then
    echo " Найдены индексы:"
    echo "$INDICES"
    echo
    echo " Количество логов:"
    curl -s -u elastic:qwerty123456 "http://localhost:9200/logs-*/_count" 2>/dev/null | python3 -m json.tool | grep count
else
    echo " Индексы логов еще создаются (подожди 1-2 минуты)"
fi

echo
echo "===  ВСЕ ЗАДАЧИ ВЫПОЛНЕНЫ! ==="
echo
echo " ДОСТУПНЫЕ СЕРВИСЫ:"
echo " Kibana (логи):    http://localhost:8081"
echo "   Логин: admin"
echo "   Пароль: qwerty123456"
echo
echo " Grafana (метрики): http://localhost:3000"
echo "   Логин: admin"
echo "   Пароль: qwerty123456"
echo
echo " Prometheus:       http://localhost:9090"
echo " Security Service: http://localhost:9091"
echo " Uploader Service: http://localhost:9092"
echo " Storage (MinIO):  http://localhost:9000"
echo " API Gateway:      http://localhost:8080"
echo
echo " Инструкция по Kibana:"
echo "1. Открой http://localhost:8081"
echo "2. Войди: admin / qwerty123456"
echo "3. Stack Management → Index Patterns → Create"
echo "4. Введи: logs-* → Next → Выбери @timestamp → Create"
echo "5. Перейди в Discover для просмотра логов"
