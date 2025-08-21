from flask import Flask, request, jsonify
import subprocess

app = Flask(__name__)

@app.route('/metrics', methods=['GET'])
def metrics():
    # Get the IP address from the query parameters
    ip = request.args.get('host')

    if not ip:
        return jsonify({"error": "No IP address provided"}), 400

    # Execute the bash command
    try:
        # Run the bash script with the provided IP
        result = subprocess.run(['./ilo_exporter.sh', ip],
                                capture_output=True, text=True, check=True)
        # Return the output of the command
        return result.stdout, 200
    except subprocess.CalledProcessError as e:
        return jsonify({"error": "Command failed", "output": e.stderr}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000)

