from flask import Flask, request, jsonify

app = Flask(__name__)

import os

# Download token from environment variables
AUTHORIZED_TOKEN = os.getenv("LOAD_TEST_TOKEN", "default_token")  # Set default value

@app.before_request
def authorize_request():
    token = request.headers.get("Authorization")
    if not token or token.split(" ")[1] != AUTHORIZED_TOKEN:
        return jsonify({"error": "Unauthorized"}), 401

@app.route("/", methods=["GET", "POST"])
def handle_request():
    return jsonify({"message": "Request successful!"})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)

#### Old code without authorization
# @app.route('/', methods=['GET'])
# def home():
#     return jsonify({'message': 'Hello from Cloud Run!'})
#
# @app.route('/echo', methods=['POST'])
# def echo():
#     data = request.get_json()
#     return jsonify({'you_sent': data}), 200
#
# if __name__ == '__main__':
#     app.run(host='0.0.0.0', port=8080)

