import 'package:dynamicForm/src/element.dart';
import 'package:dynamicForm/src/group_elements.dart';
import 'package:flutter/material.dart';

class SimpleDynamicForm extends StatefulWidget {
  final List<GroupElement> groupElements;
  final EdgeInsets padding;

  SimpleDynamicForm({
    Key key,
    @required this.groupElements,
    this.padding,
  })  : assert(groupElements.isNotEmpty, "you cannot generate empty form"),
        super(key: key);

  static SimpleDynamicFormState of(BuildContext context,
      {bool nullOk = false}) {
    assert(context != null);
    assert(nullOk != null);
    final SimpleDynamicFormState result =
        context.findAncestorStateOfType<SimpleDynamicFormState>();
    if (nullOk || result != null) return result;
    throw FlutterError.fromParts(<DiagnosticsNode>[
      ErrorSummary(
          'SimpleDynamicForm.of() called with a context that does not contain an SimpleDynamicForm.'),
      ErrorDescription(
          'No SimpleDynamicForm ancestor could be found starting from the context that was passed to SimpleDynamicForm.of().'),
      context.describeElement('The context used was')
    ]);
  }

  @override
  State<StatefulWidget> createState() {
    return SimpleDynamicFormState();
  }
}

class SimpleDynamicFormState extends State<SimpleDynamicForm> {
  GlobalKey<FormState> _formKey;
  List<List<TextEditingController>> _listGTextControler;

  recuperateAllValues() {
    List<String> values = [];
    _listGTextControler.forEach((textControllers) {
      textControllers.forEach((controller) {
        values.add(controller.text);
      });
    });
    return values;
  }

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _listGTextControler = [];
    widget.groupElements.forEach((g) {
      List<TextEditingController> _list = [];
      g.textElements.forEach((e) {
        _list.add(TextEditingController());
      });
      _listGTextControler.add(_list);
    });
  }

  bool validate() {
    return _formKey.currentState.validate();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding ?? EdgeInsets.all(5.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            for (var gelement in widget.groupElements) ...[
              if (gelement.directionGroup == DirectionGroup.Horizontal) ...[
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    for (var element in gelement.textElements) ...[
                      Flexible(
                        flex: getFlex(gelement.textElements, element, gelement.sizeElements),
                        child: generateTextField(
                          element,
                          gelement,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
              if (gelement.directionGroup == DirectionGroup.Vertical) ...[
                for (var element in gelement.textElements) ...[
                  generateTextField(element, gelement),
                ],
              ]
            ],
          ],
        ),
      ),
    );
  }

  int getFlex(List<TextElement> textElements, element, List<double> sizeElements) {
    int flex = 0;
    if (textElements.indexOf(element) <sizeElements.length)
      flex = (sizeElements[textElements.indexOf(element)] * 10).toInt();
    else {
      flex = ((1 - sizeElements.reduce((a, b) => a + b)) * 10).toInt();
    }
    return flex;
  }

  Widget generateTextField(TextElement element, GroupElement gelement) {
    return Padding(
      padding: element.padding,
      child: TextFormField(
        controller: _listGTextControler[widget.groupElements.indexOf(gelement)]
            [gelement.textElements.indexOf(element)],
        validator: element.validator,
        keyboardType: getInput(element.typeInput),
        readOnly: element.readOnly,
        decoration: InputDecoration(
          labelText: element.label,
          hintText: element.hint,
        ),
      ),
    );
  }

  TextInputType getInput(TypeInput typeInput) {
    switch (typeInput) {
      case TypeInput.Email:
        return TextInputType.emailAddress;
        break;
      case TypeInput.Numeric:
        return TextInputType.number;
        break;
      case TypeInput.Address:
        return TextInputType.text;
        break;
      case TypeInput.Text:
      case TypeInput.Password:
        return TextInputType.text;
        break;
      case TypeInput.Phone:
        return TextInputType.phone;
        break;
    }
  }
}