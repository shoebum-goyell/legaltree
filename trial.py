from transformers import AutoTokenizer, AutoModelForSeq2SeqLM
import spacy

tokenizer = AutoTokenizer.from_pretrained("bphclegalie/t5-base-legen")
model = AutoModelForSeq2SeqLM.from_pretrained("bphclegalie/t5-base-legen")
nlp = spacy.load("en_core_web_sm")


def get_discourse_tree(text):
    sentences = " ".join([t.text for t in nlp(text)])
    input_ids = tokenizer(text, max_length=384,
                          truncation=True, return_tensors="pt").input_ids
    outputs = model.generate(input_ids=input_ids, max_length=128)
    answer = [tokenizer.decode(output, skip_special_tokens=True)
              for output in outputs]
    return " ".join(answer)


from flask import Flask, request, jsonify
import pandas as pd
from flask_cors import CORS


app = Flask(__name__)
CORS(app)

@app.route('/get_response', methods=['GET'])
def get_response():
    
    request_data = request.get_json()
    print(request_data)

    if not request_data or 'sentence' not in request_data:
        
        return jsonify({'error': 'Invalid request. "sentence" parameter is required.'}), 400

    sentence = request_data['sentence']
    print(sentence)
    response = getresponsefrommodel(sentence)

    return jsonify({'response': response})

def process_sentence(sentence):
    return f"You sent: '{sentence}'. This is the API response."


def getresponsefrommodel(sentence):
    discourse_tree = get_discourse_tree(sentence)
    return discourse_tree


if __name__ == '__main__':
    app.run(debug=True, host='127.0.0.1', port=3000)
