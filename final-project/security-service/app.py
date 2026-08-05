from flask import Flask, jsonify, Response
from prometheus_client import Counter, Histogram, generate_latest, REGISTRY, CONTENT_TYPE_LATEST
import random
import time
import logging

app = Flask(__name__)

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

REQUESTS = Counter('http_requests_total', 'Total HTTP requests', ['method', 'endpoint', 'status'])
LATENCY = Histogram('http_request_duration_seconds', 'Request latency', ['method', 'endpoint'])
ERRORS = Counter('http_errors_total', 'Total HTTP errors', ['method', 'endpoint'])

@app.route('/')
def health():
    logger.info("Health check requested")
    return jsonify({"status": "healthy", "service": "security"})

@app.route('/metrics')
def metrics():
    logger.info("Metrics requested")
    return Response(generate_latest(), mimetype=CONTENT_TYPE_LATEST)

@app.route('/login')
def login():
    start = time.time()
    success = random.random() > 0.2
    status = 200 if success else random.choice([401, 500])
    
    REQUESTS.labels(method='GET', endpoint='/login', status=status).inc()
    LATENCY.labels(method='GET', endpoint='/login').observe(time.time() - start)
    
    logger.info(f"Login attempt - status: {status}")
    
    if status != 200:
        ERRORS.labels(method='GET', endpoint='/login').inc()
        return jsonify({"error": "Authentication failed"}), status
    
    return jsonify({
        "status": "success",
        "user_id": random.randint(1, 1000),
        "token": f"token-{random.randint(1000, 9999)}"
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=9090)
