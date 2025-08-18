from flask import Flask

app = Flask(__name__)

@app.route('/')
def home():
    return "Hello, Flask! This is running on port 7860."
    #return redirect("https://shop.alvgw.xyz")

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=7860)
