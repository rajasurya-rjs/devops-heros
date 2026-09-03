import socket
import sys
from flask import Flask

app = Flask(__name__)


@app.route("/")
def hello():
    return f"""<!DOCTYPE html>
<html>
  <head><title>Python Hello World</title></head>
  <body style="font-family: sans-serif; text-align: center; margin-top: 80px;">
    <h1>Hello World from Python!</h1>
    <p>Flask app running inside a Docker container</p>
    <p>container hostname: {socket.gethostname()}</p>
    <p>python version: {sys.version.split()[0]}</p>
  </body>
</html>"""


@app.route("/health")
def health():
    return {"status": "ok", "app": "python-app"}


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
