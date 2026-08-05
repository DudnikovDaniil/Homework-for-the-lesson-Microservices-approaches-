from flask import Flask, Response
from prometheus_client import Counter, generate_latest, REGISTRY, CONTENT_TYPE_LATEST
import random
import time

app = Flask(__name__)

# Создаем метрики
REQUESTS = Counter('http_requests_total', 'Total requests', ['service', 'endpoint'])
ERRORS = Counter('http_errors_total', 'Total errors', ['service'])

@app.route('/metrics')
def metrics():
    # Генерируем случайные данные
    REQUESTS.labels(service='security', endpoint='login').inc(random.randint(1, 10))
    REQUESTS.labels(service='uploader', endpoint='upload').inc(random.randint(1, 8))
    REQUESTS.labels(service='api', endpoint='gateway').inc(random.randint(1, 5))
    ERRORS.labels(service='security').inc(random.randint(0, 2))
    ERRORS.labels(service='uploader').inc(random.randint(0, 3))
    
    return Response(generate_latest(), mimetype=CONTENT_TYPE_LATEST)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=9090)
