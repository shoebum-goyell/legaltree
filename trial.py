from flask import Flask, request, jsonify
import spacy
from transformers import AutoTokenizer, AutoModelForSeq2SeqLM
from flask_cors import CORS


app = Flask(__name__)
CORS(app)

# Load Transformers model and Spacy tokenizer
tokenizer = AutoTokenizer.from_pretrained("bphclegalie/t5-base-legen")
model = AutoModelForSeq2SeqLM.from_pretrained("bphclegalie/t5-base-legen")
nlp = spacy.load("en_core_web_sm")

# Function to get discourse tree from Transformers model
def get_discourse_tree(text):
    sentences = " ".join([t.text for t in nlp(text)])
    input_ids = tokenizer(text, max_length=384, truncation=True, return_tensors="pt").input_ids
    outputs = model.generate(input_ids=input_ids, max_length=128)
    answer = [tokenizer.decode(output, skip_special_tokens=True) for output in outputs]
    return " ".join(answer)


@app.route('/get_response', methods=['POST'])
def get_response():
    response = ""
    try:
        print(request.content_type)
        sentence = request.get_json()['sentence']
        print(sentence)
        if not sentence:
            return jsonify({'error': 'Invalid request. "sentence" parameter is required.'}), 400

        response = get_discourse_tree(sentence)
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    return response
   

if __name__ == '__main__':
    app.run(debug=True, host='172.16.92.129', port=3000)
