import 'package:flutter/material.dart';
import 'package:legaltree/colors.dart';

class Node extends StatefulWidget {
  const Node({
    this.isLeaf = false,
    this.children = const [],
    this.text = '',
    Key? key}) : super(key: key);

  final bool isLeaf;
  final List<Node> children;
  final String text;

  @override
  State<Node> createState() => _NodeState();
}

class _NodeState extends State<Node> {
  bool isExpanded = true;
  @override
  Widget build(BuildContext context) {
    if (widget.isLeaf) {
      print("text: {${widget.text}}");
      return Padding(
        padding: const EdgeInsets.all(5.0),
        child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: kColorPrimary,
              borderRadius: BorderRadius.circular(4),
            ),
          width: 200,
            child: Text(widget.text, style: TextStyle(color: Colors.white, fontSize: 14),)),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10),
        child: Container(
          decoration: BoxDecoration(
            color: kColorBackground,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: kColorBorder)
          ),
          child: Column(
            children: [
              SizedBox(height: 4,),
              Row(
                children: [
                  Text(widget.text, style: TextStyle(fontSize: 14),),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isExpanded = !isExpanded;
                      });
                    },
                    child: Icon(isExpanded ? Icons.arrow_drop_down : Icons.arrow_right),
                  )
                ],
              ),
              SizedBox(height: 10,),
              isExpanded? Row(
                children:  List.generate(widget.children.length, (index) {
                  double angle = 90;
                  if(widget.children.length == 2) {
                    angle = 270 / (4*index +2);
                  }
                  if(widget.children.length == 3) {
                    angle = (270/3) + (-45*index + 45);
                  }
                  if(widget.children.length > 3){
                    angle = 0;
                  }
                  return Container(
                    width: 25,
                    child: Transform.rotate(
                      angle: angle * (3.141592653589793 / 180), // Convert degrees to radians
                      child: Container(
                        height: 2.0, // Match the height of the outer container
                        color: Colors.black,
                      ),
                    ),
                  );
                }),
              ) : Container(),
              SizedBox(height: 10,),
              isExpanded? Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: widget.children
              ):Container(),
            ],
          ),
        ),
      );
    }
  }
}


