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
        print("Hiiiii")
        return jsonify({'error': 'Invalid request. "sentence" parameter is required.'}), 400

    sentence = request_data['sentence']
    print(sentence)
    response = getresponsefrommodel(sentence)

    return jsonify({'response': response})

def process_sentence(sentence):
    return f"You sent: '{sentence}'. This is the API response."


def getresponsefrommodel(sentence):
    response_from_model = ""
    excel_file = "predictions.xlsx"
    prediction = find_prediction(sentence, excel_file)
    print(prediction)
    
    return prediction

def find_prediction(input_sentence, excel_file):
    try:
        df = pd.read_excel(excel_file, engine='openpyxl', header=None)
        print("yo")
        for index, row in df.iterrows():
            if str(row[0]) == input_sentence:
                return df.iloc[index + 1, 0] if index + 1 < len(df) else "No prediction found for this sentence."
        
        return "Sentence not found."
    
    except Exception as e:
        return f"An error occurred: {str(e)}"



if __name__ == '__main__':
    app.run(debug=True, host='127.0.0.1', port=3000)

