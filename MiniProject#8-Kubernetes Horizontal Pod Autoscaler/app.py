from flask import Flask
import math
import time

app = Flask(__name__)

@app.route('/')
def cpu_load():
    start = time.time()

    while time.time() - start < 0.2:
        for i in range(100000):
            math.sqrt(i)

    return "Autoscaler Demo Running!"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)