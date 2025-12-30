import 'package:flutter/material.dart';
import 'package:jcp/style/custom_text.dart';
import '../style/colors.dart';

typedef OnDelete();

class PartsWidget extends StatefulWidget {
  final OnDelete? onDelete;
  final TextEditingController? part;
  final List<String> suggestions;
  final FocusNode? focusNode;
  final Key? scrollKey;
  final String hintText;
  final bool showDelete;

  const PartsWidget({
    Key? key,
    required this.onDelete,
    required this.part,
    required this.suggestions,
    required this.hintText,
    this.focusNode,
    this.scrollKey,
    this.showDelete = true,
  }) : super(key: key);

  @override
  State<PartsWidget> createState() => _PartsWidgetState();
}

class _PartsWidgetState extends State<PartsWidget> {
  late FocusNode _focusNode;
  Color borderColor = grey;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    // Only add internal listener if we are managing the FocusNode ourselves.
    // If an external FocusNode is provided, the parent is responsible for scrolling (like in HomeWidget's onAddForm).
    if (widget.focusNode == null) {
      _addFocusListener();
    }
  }

  void _addFocusListener() {
    _focusNode.addListener(() {
      if (!_isDisposed && _focusNode.hasFocus) {
        _scrollToWidget();
      }
    });
  }

  void _scrollToWidget() {
    Future.delayed(Duration(milliseconds: 300), () {
      if (!_isDisposed && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            Scrollable.ensureVisible(
              context,
              duration: Duration(milliseconds: 300),
              alignment: 0.3,
              curve: Curves.easeInOut,
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _updateBorderColor(String input) {
    setState(() {
      if (widget.suggestions.contains(input)) {
        borderColor = green;
      } else {
        borderColor = red;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      height: 65,
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
      child: Row(
          mainAxisAlignment: widget.showDelete
              ? MainAxisAlignment.spaceBetween
              : MainAxisAlignment.end,
          children: [
            if (widget.showDelete)
              GestureDetector(
                onTap: widget.onDelete,
                child: Image.asset(
                  "assets/images/02.png",
                  width: 20,
                  height: 20,
                ),
              ),
            Container(
              width: widget.showDelete ? size.width * 0.85 : size.width * 0.91,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: grey,
              ),
              child: RawAutocomplete<String>(
                focusNode: _focusNode,
                textEditingController: widget.part,
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<String>.empty();
                  }

                  String query = textEditingValue.text.trim().toLowerCase();

                  final startsWithList = widget.suggestions
                      .where((item) => item.toLowerCase().startsWith(query))
                      .toList();

                  final containsList = widget.suggestions
                      .where((item) =>
                          !item.toLowerCase().startsWith(query) &&
                          item.toLowerCase().contains(query))
                      .toList();

                  final filteredList = [ ...containsList,...startsWithList,];

                  return filteredList;
                },
                onSelected: (String selection) {
                  // Controller is updated automatically by RawAutocomplete
                  _updateBorderColor(selection);
                  // Manually unfocus if needed or keep focus
                },
                optionsViewBuilder: (BuildContext context,
                    AutocompleteOnSelected<String> onSelected,
                    Iterable<String> options) {
                  final optionsList = options.toList();

                  if (optionsList.isEmpty) {
                    return SizedBox.shrink();
                  }

                  return Material(
                    elevation: 4.0,
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      constraints: BoxConstraints(
                          maxHeight: optionsList.length <= 4
                              ? (optionsList.length * 60).toDouble()
                              : 200),
                      width: double.infinity,
                      child: optionsList.length <= 4
                          ? ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: optionsList.length,
                              itemBuilder: (context, index) {
                                final option = optionsList[index];
                                return InkWell(
                                  onTap: () => onSelected(option),
                                  child: Container(
                                    height: 60,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.grey[300]!,
                                          width: 0.5,
                                        ),
                                      ),
                                    ),
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: CustomText(
                                        text: option,
                                        textDirection: TextDirection.rtl,
                                        size: 16,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            )
                          : ListWheelScrollView.useDelegate(
                              itemExtent: 60,
                              physics: BouncingScrollPhysics(),
                              useMagnifier: false,
                              magnification: 1.0,
                              perspective: 0.0002,
                              childDelegate: optionsList.length > 4
                                  ? ListWheelChildLoopingListDelegate(
                                      children: optionsList.map((option) {
                                        return InkWell(
                                          onTap: () => onSelected(option),
                                          child: Container(
                                            height: 50,
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 12,
                                            ),
                                            decoration: BoxDecoration(
                                              border: Border(
                                                bottom: BorderSide(
                                                  color: Colors.grey[300]!,
                                                  width: 0.5,
                                                ),
                                              ),
                                            ),
                                            child: Align(
                                              alignment: Alignment.center,
                                              child: CustomText(
                                                text: option,
                                                textDirection:
                                                    TextDirection.rtl,
                                                size: 16,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    )
                                  : ListWheelChildListDelegate(
                                      children: optionsList.map((option) {
                                        return InkWell(
                                          onTap: () => onSelected(option),
                                          child: Container(
                                            height: 50,
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 12,
                                            ),
                                            decoration: BoxDecoration(
                                              border: Border(
                                                bottom: BorderSide(
                                                  color: Colors.grey[300]!,
                                                  width: 0.5,
                                                ),
                                              ),
                                            ),
                                            child: Align(
                                              alignment: Alignment.center,
                                              child: CustomText(
                                                text: option,
                                                textDirection:
                                                    TextDirection.rtl,
                                                size: 16,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                            ),
                    ),
                  );
                },
                fieldViewBuilder: (
                  BuildContext context,
                  TextEditingController textEditingController,
                  FocusNode fieldFocusNode,
                  VoidCallback onFieldSubmitted,
                ) {
                  return TextFormField(
                    key: widget.scrollKey,
                    // textEditingController passed from RawAutocomplete is the one we provided (widget.part)
                    controller: textEditingController,
                    // fieldFocusNode passed from RawAutocomplete is the one we provided (_focusNode)
                    focusNode: fieldFocusNode,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    maxLength: 30,
                    onChanged: (val) {
                      setState(() {
                        // widget.part?.text = val; // No need, controller is updated
                        _updateBorderColor(val);
                      });
                    },
                    decoration: InputDecoration(
                      counterText: '',
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: borderColor, width: 2),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: borderColor, width: 2),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      hintText: widget.hintText,
                      hintStyle: TextStyle(
                        color: words,
                        fontFamily: "Tajawal",
                        fontSize: size.width * 0.04,
                      ),
                    ),
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: size.width * 0.04,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
    );
  }
}
