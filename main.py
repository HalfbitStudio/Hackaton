import pickle
import tensorflow as tf
from PIL import Image
from io import BytesIO
import base64
import numpy as np
from flask import Flask, request, jsonify

classess = pickle.load(open('labels.pcl', 'rb'))
model = tf.keras.models.load_model('model.h5')

app = Flask(__name__)

print(classess)

@app.route("/api/predict", methods=['POST'])
def predict():
    data = request.json.get('image')
    im = np.asarray(Image.open(BytesIO(base64.b64decode(data))).convert('RGB').resize((224,224)))
    im = tf.expand_dims(im, 0)  # Create a batch
    predictions = model.predict(im)
    score = tf.nn.softmax(predictions[0])
    resp = {"label": classess[np.argmax(score)], "confidence":100 * np.max(score) }
    print(resp)
    return resp


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=7777)