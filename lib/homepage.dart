import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_simple_treeview/flutter_simple_treeview.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:legaltree/models.dart';
import 'package:legaltree/treenode.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Statement rnstatement = Statement(
    "The Minimum Wages Act 1948 is an Act of Parliament concerning Indian labour law that sets the minimum wages that must be paid to skilled and unskilled labours.",
    "SUB/PURPOSE(\"New Pension Scheme was implemented with the decision of the Union Government.\",\"his was to replace the Old Pension Scheme which had defined-benefit pensions for all its employees .\")",
  );
  List<Statement> statements = [
    Statement(
      "The Minimum Wages Act 1948 is an Act of Parliament concerning Indian labour law that sets the minimum wages that must be paid to skilled and unskilled labours.",
      "SUB/ELABORATION('The Minimum Wages Act 1948 is an Act of Parliament concerning Indian labour law .', SUB/ELABORATION('Indian labour law sets the minimum wages .','The minimum wages must be paid to skilled and unskilled labours .'))",
    ),
  ];

  Node parseInput(String input) {
    input = input.trim();
    if (input.startsWith("\"") && input.endsWith("\"")) {
      return Node(isLeaf: true, text: replaceStarsWithCommas(input.substring(1, input.length - 1)));
    }

    final startIndex = input.indexOf('(');
    final endIndex = input.lastIndexOf(')');

    final nodeType = input.substring(0, startIndex);
    final nodeText = input.substring(startIndex + 1, endIndex);

    final childrenNodes = _splitChildren(nodeText);

    return Node(isLeaf: false, text: nodeType, children: childrenNodes);
  }

  List<Node> _splitChildren(String input) {
    final children = <Node>[];
    int start = 0;
    int quoteCount = 0;

    for (int i = 0; i < input.length; i++) {
      if (input[i] == '(') {
        quoteCount++;
      } else if (input[i] == ')') {
        quoteCount--;
      } else if (input[i] == ',' && quoteCount == 0) {
        final childText = input.substring(start, i).trim();
        if (childText.isNotEmpty) {
          children.add(parseInput(childText));
        }
        start = i + 1;
      }
    }

    final lastChildText = input.substring(start).trim();
    if (lastChildText.isNotEmpty) {
      children.add(parseInput(lastChildText));
    }
    return children;
  }

  String replaceStarsWithCommas(String input) {
    String withoutstars = input.replaceAll('*', ',');
    String withouthashes = withoutstars.replaceAll('#', ')');
    String withoutats = withouthashes.replaceAll('@', '(');
    return withoutats;
  }

  String replaceCommasBetweenDoublequotes(String input) {
    bool insideDoublequotes = false;
    StringBuffer result = StringBuffer();

    for (int i = 0; i < input.length; i++) {
      if (input[i] == '\"') {
        insideDoublequotes = !insideDoublequotes;
        result.write(input[i]);
      } else if (insideDoublequotes && input[i] == ',') {
        result.write('*');
      } else if (insideDoublequotes && input[i] == '(') {
        result.write('@');
      } else if (insideDoublequotes && input[i] == ')') {
        result.write('#');
      } else {
        result.write(input[i]);
      }
    }

    return result.toString();
  }

  Future<Node?> fetchTree(String text) async {
    Dio dio = Dio();
    dio.options.headers['Content-Type'] = 'application/json';

    try {
      final response = await dio.get('http://localhost:3000/get_response',
          queryParameters: {'sentence': text});
      if (response.statusCode == 200) {
        final parsed = json.decode(response.data);
        String treeText = parsed['response'];
        return parseInput(treeText);
      } else {
        print('Unexpected status code: ${response.statusCode}');
        print('Response data: ${response.data}');
        throw Exception('Failed to load tree');
      }
    } catch (e) {
      print("Error in fetchTree: $e");
      throw Exception('Failed to load tree');
    }
  }

  Widget buildTree() {
    Statement currentStatement = rnstatement;
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
                  labelText: 'Prediction Text',
                ),
                onChanged: (text) {
                  rnstatement.outputText = text;
                },
              ),
            ),
          ),
          GestureDetector(
            onTap: () async {
              Node? tree = await fetchTree(rnstatement.outputText);
              setState(() {
                root = tree;
              });
            },
            child: Container(
              margin: EdgeInsets.only(top: 20),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.amber,
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "Generate Tree",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                ),
              ),
            ),
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
      backgroundColor: Colors.white,
      body: buildTree(),
    );
  }
}
