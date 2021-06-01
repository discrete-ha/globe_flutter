

import 'package:flutter/material.dart';

class RichTextField extends StatelessWidget {

  Function? onChangeFunction;
  String? lableText;
  String? hintText;
  int? numberOfLine;
  TextEditingController? _editingController;

  RichTextField(onChangeFunction, lableText, hintText, TextEditingController _editingController){
    this.onChangeFunction= onChangeFunction;
    this.lableText= lableText;
    this.hintText= hintText;
    this._editingController = _editingController;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(5.0),
        child: new Container(
          height: 45.0,
          child:TextField(
            onChanged: (value) {
              onChangeFunction!();
            },
            controller: _editingController,
            decoration: InputDecoration(
                labelText: lableText,
                hintText: hintText,
                contentPadding: new EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
                // prefixIcon: Icon(Icons.search),
                enabledBorder: new UnderlineInputBorder(
                    borderSide: new BorderSide(color: Colors.blueGrey)
                )
            ),
          ),
        )
    );
  }
}
