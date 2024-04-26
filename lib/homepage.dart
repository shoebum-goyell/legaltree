import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_simple_treeview/flutter_simple_treeview.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:legaltree/colors.dart';
import 'package:legaltree/models.dart';
import 'package:legaltree/treenode.dart';
import 'dart:html' as html;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  openInWindow(String uri, String name) {
    print("hello");
    html.window.open(uri, name);
  }

  Statement rnstatement = Statement(
    "The Minimum Wages Act 1948 is an Act of Parliament concerning Indian labour law that sets the minimum wages that must be paid to skilled and unskilled labours.",
    "None",
  );
  List<Statement> statements = [
    Statement(
      "The Minimum Wages Act 1948 is an Act of Parliament concerning Indian labour law that sets the minimum wages that must be paid to skilled and unskilled labours.",
      "SUB/ELABORATION('The Minimum Wages Act 1948 is an Act of Parliament concerning Indian labour law .', SUB/ELABORATION('Indian labour law sets the minimum wages .','The minimum wages must be paid to skilled and unskilled labours .'))",
    ),
  ];

  Node parseInput(String input) {
    input = input.trim();
    print("kljadf");
    if (input.startsWith("\'") && input.endsWith("\'")) {
      print("hjasld");
      return Node(isLeaf: true, text: replaceStarsWithCommas(input.substring(1, input.length - 1)));
    }
    print("kajhdsf");

    print(input);
    final startIndex = input.indexOf('(');
    final endIndex = input.lastIndexOf(')');

    print("asdlfkj");
    final nodeType = input.substring(0, startIndex);
    print(nodeType);
    final nodeText = input.substring(startIndex + 1, endIndex);
    print(nodeText);
    print("hello");
    final childrenNodes = _splitChildren(nodeText);

    return Node(isLeaf: false, text: nodeType, children: childrenNodes);
  }

  List<Node> _splitChildren(String input) {
    final children = <Node>[];
    int start = 0;
    int quoteCount = 0;
    print(input);
    for (int i = 0; i < input.length; i++) {
      if (input[i] == '(') {
        quoteCount++;
      } else if (input[i] == ')') {
        quoteCount--;
      } else if (input[i] == ',' && quoteCount == 0) {
        final childText = input.substring(start, i).trim();
        print(childText);
        if (childText.isNotEmpty) {
          print("hello");
          children.add(parseInput(childText));
          print(children);
        }
        start = i + 1;
        print(input[start]);
      }
    }

    final lastChildText = input.substring(start).trim();
    if (lastChildText.isNotEmpty) {
      children.add(parseInput(lastChildText));
    }
    return children;
  }

  String replaceStarsWithCommas(String input) {
    print("helloasdlfk");
    String withoutstars = input.replaceAll('*', ',');
    String withouthashes = withoutstars.replaceAll('#', ')');
    String withoutats = withouthashes.replaceAll('@', '(');
    print(withoutats);
    return withoutats;
  }

  String replaceCommasBetweenDoublequotes(String input) {
    bool insideDoublequotes = false;
    StringBuffer result = StringBuffer();

    for (int i = 0; i < input.length; i++) {
      if (input[i] == '\'' && input[i+1] != ')') {
        insideDoublequotes = !insideDoublequotes;
        result.write(input[i]);
      } else if (insideDoublequotes && input[i] == ',') {
        result.write('*');
      } else if (insideDoublequotes && input[i] == '(') {
        result.write('@');
      } else if (insideDoublequotes && input[i] == ')' && i != input.length - 1) {
        result.write('#');
      } else {
        result.write(input[i]);
      }
    }

    return result.toString();
  }


  Future<Node?> fetchTree(String text) async {
    try {
      var headers = {
        'Content-Type': 'application/json'
      };
      var request = http.Request('POST', Uri.parse('http://172.16.92.129:3000/get_response'));
      print("yoooo");
      request.body = json.encode({
        "sentence": text
      });
      request.headers.addAll(headers);
      print("lkjaf");
      setState(() {
        rnstatement.outputText = "Loading...";
      });
      http.StreamedResponse response = await request.send();
      print("sakj");
      if (response.statusCode == 200) {
        var pred = await response.stream.bytesToString();
        setState(() {
          rnstatement.outputText = pred;
        });
      }
      else {
        print(response.reasonPhrase);
      }
    } catch (e) {
      print(e);
    }
  }


  Widget buildTree() {
    Statement currentStatement = rnstatement;
    print("Yoooo");
    print(currentStatement.outputText);
    String s = replaceCommasBetweenDoublequotes(currentStatement.outputText);
    Node? root;
    try {
      root = parseInput(s);
    } catch (e) {
      print(e);
    }
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 40.0, left: 20, right: 20),
            child: Container(
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Input Text',
                ),
                onChanged: (text) {
                  rnstatement.inputText = text;
                },
              ),
            ),
          ),

          GestureDetector(
            onTap: () async {
              Node? tree = await fetchTree(rnstatement.inputText);
              setState(() {
                root = tree;
              });
            },
            child: Container(
              margin: EdgeInsets.only(top: 20),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: kColorPrimary,
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "Generate Tree",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          SizedBox(height: 20,),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Container(width: 800, child: Center(child: Text("Prediction: " + rnstatement.outputText))),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
                child: root != null ? root! : Text("Failed to generate tree"),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kColorSecondary,
      appBar: AppBar(
        title: Text("LEGEN Tree Generator", style: TextStyle(color: Colors.white)),
        backgroundColor: kColorPrimary,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                openInWindow("https://huggingface.co/bphclegalie/t5-base-legen", "yo");
              },
              child: Icon(Icons.help_outline, color: Colors.white,),),
          )
        ],
      ),
      body: buildTree(),
    );
  }
}
