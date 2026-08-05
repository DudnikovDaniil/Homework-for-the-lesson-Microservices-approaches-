from flask import Flask, jsonify, request, Response
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
FILE_SIZE = Histogram('file_size_bytes', 'Uploaded file size in bytes')

@app.route('/')
def health():
    logger.info("Health check requested")
    return jsonify({"status": "healthy", "service": "uploader"})

@app.route('/metrics')
def metrics():
    logger.info("Metrics requested")
    return Response(generate_latest(), mimetype=CONTENT_TYPE_LATEST)

@app.route('/upload', methods=['POST'])
def upload():
    start = time.time()
    file_size = random.randint(1024, 10485760)
    status = random.choices([200, 200, 200, 400, 500], weights=[0.7, 0.15, 0.1, 0.03, 0.02])[0]
    
    REQUESTS.labels(method='POST', endpoint='/upload', status=status).inc()
    LATENCY.labels(method='POST', endpoint='/upload').observe(time.time() - start)
    FILE_SIZE.observe(file_size)
    
    logger.info(f"Upload attempt - size: {file_size}, status: {status}")
    
    if status != 200:
        return jsonify({"error": "Upload failed"}), status
    
    return jsonify({
        "status": "success",
        "file_id": f"file-{random.randint(1000, 9999)}",
        "size": file_size
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=9090)
