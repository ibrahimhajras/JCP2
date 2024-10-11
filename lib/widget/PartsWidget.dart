import 'package:flutter/material.dart';
import '../style/colors.dart';

typedef OnDelete();

class PartsWidget extends StatefulWidget {
  final OnDelete? onDelete;
  final TextEditingController? part;

  const PartsWidget({
    super.key,
    required this.onDelete,
    required this.part,
  });

  @override
  State<PartsWidget> createState() => _PartsWidgetState();
}

class _PartsWidgetState extends State<PartsWidget> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      height: 65,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: 5,
          horizontal: 15,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: widget.onDelete,
              child: Image.asset(
                "assets/images/02.png",
                width: 20,
                height: 20,
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.75,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: grey,
              ),
              child: TextFormField(
                controller: widget.part,
                textAlign: TextAlign.end,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: grey,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: grey,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  fillColor: grey,
                  hintText: "قطعة الجديدة",
                  hintStyle: TextStyle(
                    color: words,
                    fontSize: size.width * 0.04,
                  ),
                ),
                style: TextStyle(
                  color: Colors.black,
                  fontSize: size.width * 0.04,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
