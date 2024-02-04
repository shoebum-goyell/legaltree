import 'package:flutter/material.dart';
import 'package:flutter_simple_treeview/flutter_simple_treeview.dart';
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
      "SUB/ELABORATION('The Minimum Wages Act 1948 is an Act of Parliament concerning Indian labour law .', SUB/ELABORATION('Indian labour law sets the minimum wages .','The minimum wages must be paid to skilled and unskilled labours .'))"
  );
  List<Statement> statements = [
  Statement(
      "The Minimum Wages Act 1948 is an Act of Parliament concerning Indian labour law that sets the minimum wages that must be paid to skilled and unskilled labours.",
    "SUB/ELABORATION('The Minimum Wages Act 1948 is an Act of Parliament concerning Indian labour law .', SUB/ELABORATION('Indian labour law sets the minimum wages .','The minimum wages must be paid to skilled and unskilled labours .'))"
  ),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: buildTree(),

    );
  }
  String replaceStarsWithCommas(String input) {
    String withoutstars = input.replaceAll('*', ',');
    String withouthashes = withoutstars.replaceAll('#', ')');
    String withoutats = withouthashes.replaceAll('@', '(');
    return withoutats;
  }

  Node parseInput(String input) {
    input = input.trim();
    if (input.startsWith("'") && input.endsWith("'")) {
      print("yo");
      return Node(isLeaf: true, text: replaceStarsWithCommas(input.substring(1, input.length - 1)));
    }

    // Find the first parenthesis
    final startIndex = input.indexOf('(');
    print("startIndex");
    final endIndex = input.lastIndexOf(')');
    print("endIndex");

    // Extract node type and text
    final nodeType = input.substring(0, startIndex);
    print(nodeType);
    final nodeText = input.substring(startIndex + 1, endIndex);
    print(nodeText);

    // Split children based on commas
    final childrenText = nodeText.split(',');

    // Create child nodes
    final childrenNodes = _splitChildren(nodeText);

    // Create the current node
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
        // Split only if the comma is not inside quotes
        final childText = input.substring(start, i).trim();
        if (childText.isNotEmpty) {
          children.add(parseInput(childText));
        }
        start = i + 1;
      }
    }

    // Add the last child
    final lastChildText = input.substring(start).trim();
    if (lastChildText.isNotEmpty) {
      children.add(parseInput(lastChildText));
    }
    return children;
  }
  String replaceCommasBetweenSingleQuotes(String input) {
    bool insideSingleQuotes = false;
    StringBuffer result = StringBuffer();

    for (int i = 0; i < input.length; i++) {
      if (input[i] == '\'') {
        insideSingleQuotes = !insideSingleQuotes;
        result.write(input[i]);
      } else if (insideSingleQuotes && input[i] == ',') {
        result.write('*');
      } else if (insideSingleQuotes && input[i] == '(') {
        result.write('@');
      }
      else if (insideSingleQuotes && input[i] == ')') {
        result.write('#');
      }
      else {
        result.write(input[i]);
      }
    }

    return result.toString();
  }

  Widget buildTree() {
    Statement currentStatement = rnstatement;
    String s = replaceCommasBetweenSingleQuotes(currentStatement.outputText);
    Node? root;
    try{
      root = parseInput(s);
    }
    catch(e){
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
              onTap: () {
                setState(() {
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
                  child: root != null? root! : Text("Failed to generate tree"),
                ),
              ),
            ),
          ],
        ),
    );
  }
}
