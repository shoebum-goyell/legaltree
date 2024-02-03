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
  bool value1 = false;
  bool value2 = false;
  final Key _key = ValueKey(22);
  int currentIndex = 0;
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
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 30.0),
            child: FloatingActionButton(
              backgroundColor: Colors.amber,
              onPressed: () {
                // Move to the next statement on button press
                setState(() {
                  // currentIndex = (currentIndex + 1) % statements.length;
                });
              },
              child: Icon(Icons.info_outline),
            ),
          ),
          FloatingActionButton(
            backgroundColor: Colors.amber,
            onPressed: () {
              // Move to the next statement on button press
              setState(() {
                value1 = false;
                value2 = false;
                currentIndex = (currentIndex + 1) % statements.length;
              });
            },
            child: Icon(Icons.arrow_forward),
          ),
        ],
      ),
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
    Node root = parseInput(s);


    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 40.0, left: 20, right: 20),
              child: Container(
                child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enter your input',
                  ),
                  onChanged: (text) {
                    rnstatement.outputText = text;
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 40.0, left: 20, right: 20),
              child: Container(
                child: Text("Input: ${currentStatement.inputText}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 40.0, left: 20, right: 20),
              child: Container(
                child: Text("Prediction: ${currentStatement.outputText}",style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
                  child: root,
                ),
              ),
            ),
            // SizedBox(height: 20),
            // Text(
            //   "Are the clauses correctly identified? Meaning do they form meaningful sentences",
            //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            // ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     Radio(
            //       value: true,
            //       groupValue: value1, // Provide the appropriate group value
            //       onChanged: (value) {
            //         setState(() {
            //           value1 = value!;
            //         });
            //       },
            //     ),
            //     Text("Yes"),
            //     Radio(
            //       value: false,
            //       groupValue: value1, // Provide the appropriate group value
            //       onChanged: (value) {
            //         setState(() {
            //           value1 = value!;
            //         });
            //       },
            //     ),
            //     Text("No"),
            //   ],
            // ),
            //
            // SizedBox(height: 20),
            // Text(
            //   "Are the relations between the sentences correctly identified?",
            //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            // ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     Radio(
            //       value: true,
            //       groupValue: value2,
            //       onChanged: (value) {
            //         setState(() {
            //           value2 = value!;
            //         });
            //       },
            //     ),
            //     Text("Yes"),
            //     Radio(
            //       value: false,
            //       groupValue: value2,
            //       onChanged: (value) {
            //         setState(() {
            //           value2 = value!;
            //         });
            //       },
            //     ),
            //     Text("No"),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }
}
