import 'package:flutter/material.dart';

class Node extends StatelessWidget {
  const Node({
    this.isLeaf = false,
    this.children = const [],
    this.text = '',
    Key? key}) : super(key: key);

  final bool isLeaf;
  final List<Node> children;
  final String text;

  @override
  Widget build(BuildContext context) {
    if (isLeaf) {
      print("text: {$text}");
      return Padding(
        padding: const EdgeInsets.all(15.0),
        child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
            ),
          width: 250,
            child: Text(text)),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.black)
          ),
          child: Column(
            children: [
              SizedBox(height: 10,),
              Text(text, style: TextStyle(fontSize: 20),),
              SizedBox(height: 30,),
              Row(
                children:  List.generate(children.length, (index) {
                  double angle = 90;
                  if(children.length == 2) {
                    angle = 270 / (4*index +2);
                  }
                  if(children.length == 3) {
                    angle = (270/3) + (-45*index + 45);
                  }
                  if(children.length > 3){
                    angle = 0;
                  }
                  return Container(
                    width: 50,
                    child: Transform.rotate(
                      angle: angle * (3.141592653589793 / 180), // Convert degrees to radians
                      child: Container(
                        height: 2.0, // Match the height of the outer container
                        color: Colors.black,
                      ),
                    ),
                  );
                }),
              ),
              SizedBox(height: 10,),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: children
              ),
            ],
          ),
        ),
      );
    }
  }
}


