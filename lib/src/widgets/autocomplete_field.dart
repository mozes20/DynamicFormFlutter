import 'dart:async';

import 'package:dynamic_form/dynamic_form.dart';
import 'package:flutter/material.dart';

class AutocompleteField extends StatefulWidget {
  final TextEditingController textEditingController;
  final AutocompleteElement element;
  final InputDecoration? inputDecoration;
  const AutocompleteField({
    Key? key,
    required this.textEditingController,
    required this.element,
    this.inputDecoration,
  }) : super(key: key);

  @override
  State<AutocompleteField> createState() => _AutocompleteFieldState();
}

class _AutocompleteFieldState extends State<AutocompleteField> {
  late Iterable<String> _lastOptions = [];
  late final _Debounceable<Iterable<String>?, String> _debouncedSearch;

  @override
  void initState() {
    super.initState();
    widget.textEditingController.addListener(() {
      setState(() {});
    });
    _debouncedSearch =
        _debounce<Iterable<String>?, String>(widget.element.search);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Autocomplete<String>(
            optionsBuilder: (textEditingValue) async {
              final Iterable<String>? options =
                  await _debouncedSearch(textEditingValue.text);
              if (options == null) {
                return _lastOptions;
              }
              _lastOptions = options;
              return options;
            },
            onSelected: (String selection) {
              widget.textEditingController.text = selection;
            },
            fieldViewBuilder: (BuildContext context,
                TextEditingController textEditingController,
                FocusNode focusNode,
                VoidCallback onFieldSubmitted) {
              return TextFormField(
                onChanged: (value) {
                  if (value.isEmpty) {
                    textEditingController.text = '';
                  } else {
                    textEditingController.text = value;
                  }
                },
                decoration: widget.inputDecoration,
                controller: widget.textEditingController,
                focusNode: focusNode,
                enableInteractiveSelection: false,
                onTap: () => setState(() => {}),
              );
            },
            optionsViewBuilder: (context, onSelected, options) {
              return Padding(
                padding: const EdgeInsets.all(4.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    shape: RoundedRectangleBorder(
                      borderRadius: widget.element.decorationElement?.radius ??
                          BorderRadius.circular(0.0),
                    ),
                    elevation: 10,
                    color: Colors.white,
                    shadowColor: Colors.black,
                    child: Container(
                      height: 52.0 * options.length,
                      width: constraints.biggest.width,
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: options.length,
                        itemBuilder: (context, index) {
                          final option = options.elementAt(index);
                          return InkWell(
                            borderRadius:
                                widget.element.decorationElement?.radius ??
                                    BorderRadius.circular(0.0),
                            hoverColor: Colors.grey.withOpacity(0.5),
                            onTap: () {
                              onSelected(option);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(option),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      );
    });
  }
}

typedef _Debounceable<S, T> = Future<S?> Function(T parameter);

/// Returns a new function that is a debounced version of the given function.
///
/// This means that the original function will be called only after no calls
/// have been made for the given Duration.
_Debounceable<S, T> _debounce<S, T>(_Debounceable<S?, T> function) {
  _DebounceTimer? debounceTimer;

  return (T parameter) async {
    if (debounceTimer != null && !debounceTimer!.isCompleted) {
      debounceTimer!.cancel();
    }
    debounceTimer = _DebounceTimer();
    try {
      await debounceTimer!.future;
    } catch (error) {
      if (error is _CancelException) {
        return null;
      }
      rethrow;
    }
    return function(parameter);
  };
}

const Duration debounceDuration = Duration(milliseconds: 300);

class _DebounceTimer {
  _DebounceTimer() {
    _timer = Timer(debounceDuration, _onComplete);
  }

  late final Timer _timer;
  final Completer<void> _completer = Completer<void>();

  void _onComplete() {
    _completer.complete();
  }

  Future<void> get future => _completer.future;

  bool get isCompleted => _completer.isCompleted;

  void cancel() {
    _timer.cancel();
    _completer.completeError(const _CancelException());
  }
}

// An exception indicating that the timer was canceled.
class _CancelException implements Exception {
  const _CancelException();
}
