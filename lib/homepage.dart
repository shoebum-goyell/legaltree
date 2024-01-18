import 'package:flutter/material.dart';
import 'package:flutter_simple_treeview/flutter_simple_treeview.dart';
import 'package:legaltree/treenode.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Key _key = ValueKey(22);
  final TreeController _controller = TreeController(allNodesExpanded: true);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      body: buildTree()
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
    String text = "SUB/ELABORATION(SUB/ELABORATION('This was to the general labour laws applicable to all workers.','This was in addition.' ), SUB/CONDITION('Graduation is payable to the employee.',SUB/CONDITION('Graduation is payable to the employee.','He or she resigns or retires.')))";
    String s = replaceCommasBetweenSingleQuotes(text);
    Node root = parseInput(s);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 40.0, left: 20, right:20),
          child: Container(
              child: Text(text),
          ),
        ),
        SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
            child: root
            // child: Node(
            //     text: 'SUB/ELABORATION',
            //     children: [
            //       Node(
            //         text: 'The Industrial Employment(Standing Orders) Act 1946 requires.',
            //         isLeaf: true,
            //       ),
            //       Node(
            //         text: 'CO/DISJUNCTION',
            //         children: [
            //           Node(
            //             text: 'Employers have terms including working hours, leave, productivity goals, dismissal procedures or worker classification, approved by a government body.',
            //             isLeaf: true,
            //           ),
            //           Node(
            //             text: 'Employees have terms include working hours, leave, productivity goals or dismissal procedures, approved by government body',
            //             isLeaf: true,
            //           ),
            //           Node(
            //             text: 'Employees have terms include working hours, leave, productivity goals or dismissal procedures, approved by government body',
            //             isLeaf: true,
            //           ),
            //         ],
            //       ),
            //     ],
            //   ),
          ),
        ),
      )],
    );
  }
}
