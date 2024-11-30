import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PythonCompilerScreen extends StatefulWidget {
  @override
  _PythonCompilerScreenState createState() => _PythonCompilerScreenState();
}

class _PythonCompilerScreenState extends State<PythonCompilerScreen> {
  TextEditingController _controller = TextEditingController();
  FocusNode _focusNode = FocusNode();
  String error = '';
  String output = '';
  bool isRunning = false;

 
  Future<void> executePythonCode(String code) async {
    setState(() {
      isRunning = true;
      error = ''; 
      output = ''; 
    });

    final url = Uri.parse('http://localhost:5000/execute'); 
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'code': code}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          output = data['output'];
          error = ''; 
          isRunning = false;
        });
      } else {
       
        final data = json.decode(response.body);
        setState(() {
          error = data['error'] ?? 'Unknown error occurred';
          output = ''; 
          isRunning = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error connecting to server: $e';
        output = '';  
        isRunning = false;
      });
    }
  }


  void clear() {
    setState(() {
      _controller.clear();
      error = '';
      output = '';
    });
  }


  void onTextSelectionChanged(TextSelection selection) {
    if (selection != TextSelection.collapsed) {
      setState(() {
     
        print("Selected Text: ${_controller.text.substring(selection.start, selection.end)}");
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        
        final selection = _controller.selection;
        onTextSelectionChanged(selection);
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(' Python Compiler'),
        backgroundColor: Color(0xFFFFFFFF),
      ),
      backgroundColor: Colors.black87,
      body: SingleChildScrollView( 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           
            Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 40, 27, 27),
                borderRadius: BorderRadius.circular(0),
              ),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                maxLines: 20,
                textInputAction: TextInputAction.done,
                style: TextStyle(
                  fontFamily: 'Courier New', // Monospace font for code
                  fontSize: 16,
                  color: Colors.white, // White text color
                ),
                decoration: InputDecoration(
                  hintText: 'Enter your Python code here',
                  hintStyle: TextStyle(color: Colors.white60),
                  filled: true,
                  fillColor: Colors.black,
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),
            SizedBox(height: 20),

         
            Row(
              children: [
                Flexible(
                  flex: 60,
                  child: Opacity(
                    opacity: isRunning ? 0.5 : 1.0,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: isRunning ? null : () {
                          String code = _controller.text;
                          if (code.isNotEmpty) {
                            executePythonCode(code);
                          }
                        },
                        child: isRunning ? Text('Running...') : Text('Run Code', style: TextStyle(fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFFFFF),
                          padding: EdgeInsets.symmetric(vertical: 14),
                          textStyle: TextStyle(fontSize: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4), // Reduced circular shape
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Flexible(
                  flex: 45, 
                  child: ElevatedButton(
                    onPressed: clear,
                    child: Text('Clear', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFFFFF),
                      padding: EdgeInsets.symmetric(vertical: 14),
                      textStyle: TextStyle(fontSize: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ],
            ),

           
           const  SizedBox(height: 20),
            if (error.isNotEmpty) ...[
            const  Text(
                'Error:',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
              ),
              Text(error, style: TextStyle(color: Colors.red)),
            ],
            if (output.isNotEmpty) ...[
             const Text(
                'Output:',
                style: TextStyle(fontWeight: FontWeight.bold,color: Color(0xFFFFFFFF)),
              ),
             const  SizedBox(height: 10),
              Text(output, style: TextStyle(color: Color(0xFFFFFFFF),fontWeight: FontWeight.bold)), 
            ],
          ],
        ),
      ),
    );
  }
}
