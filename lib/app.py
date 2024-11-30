from flask import Flask, request, jsonify
from flask_cors import CORS
import subprocess
import traceback

app = Flask(__name__)

CORS(app)

@app.route('/execute', methods=['POST'])
def execute_code():
    try:
     
        data = request.get_json()
        code = data.get('code', '')

        if not code:
            return jsonify({'error': 'No code provided'}), 400

      
        result = subprocess.run(
            ['python', '-c', code],  
            text=True,
            capture_output=True,
            timeout=10 
        )

       
        if result.returncode == 0:
            return jsonify({'output': result.stdout.strip(), 'error': ''})
        else:
          
            error_message = result.stderr.strip()
            if error_message:
                return jsonify({'error': error_message, 'output': ''}), 400

    except subprocess.TimeoutExpired:
        return jsonify({'error': 'Execution timed out. Please check your code.', 'output': ''}), 408
    except Exception as e:
    
        print(f"Error occurred: {str(e)}") 
        print(traceback.format_exc())  
        return jsonify({'error': f'Internal server error: {str(e)}', 'output': ''}), 500


if __name__ == '__main__':
   
    app.run(debug=True, host='0.0.0.0', port=5000)
