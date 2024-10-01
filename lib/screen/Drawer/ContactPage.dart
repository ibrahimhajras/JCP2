import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:jcp/model/CommentModel.dart';
import 'package:jcp/provider/ProfileProvider.dart';
import 'package:jcp/screen/home/homeuser.dart';
import 'package:jcp/style/colors.dart';
import 'package:jcp/style/custom_text.dart';
import 'package:jcp/widget/RotatingImagePage.dart';
import 'package:provider/provider.dart';

import '../../widget/Inallpage/CustomButton.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  TextEditingController _feedBack = TextEditingController();
  TextEditingController _feedMessage = TextEditingController();
  bool isLoading = false;

  Future<void> submitComment(CommentModel comment) async {
    final url = Uri.parse(
        'https://jordancarpart.com/Api/contactUs.php?title=${comment.title}&comment=${comment.comment}&name=${comment.name}&address=${comment.address}&user_id=${comment.uid}&phone=${comment.phone}&time=${DateTime.now().toIso8601String()}');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        print('تم تحديث المدينة بنجاح');
      }
    } catch (error) {
      throw Exception('Failed to add comment: $error');
    }
  }

  Widget _buildSuccessBottomSheet(Size size) {
    return Container(
      height: 390,
      width: size.width,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.25),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(1),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 15),
            Center(
              child: SvgPicture.asset(
                'assets/svg/line.svg',
                width: 30,
                height: 5,
              ),
            ),
            SizedBox(height: 35),
            Center(
              child: Image.asset(
                "assets/images/done-icon 1.png",
                height: 122,
                width: 122,
              ),
            ),
            SizedBox(height: 25),
            Center(
              child: CustomText(
                text: " تم ارسال رسالتك سوف يتم التواصل معك في اقرب وقت ممكن ",
                size: 24,
                weight: FontWeight.w700,
              ),
            ),
            SizedBox(height: size.height * 0.05),
            MaterialButton(
              onPressed: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomePage(),
                    ));
              },
              height: 45,
              minWidth: size.width * 0.9,
              color: Color.fromRGBO(195, 29, 29, 1),
              child: CustomText(
                text: "رجوع",
                color: white,
                size: 18,
              ),
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final user = Provider.of<ProfileProvider>(context);

    return Scaffold(
      backgroundColor: white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              child: Column(
                children: [
                  Container(
                    height: size.height * 0.2,
                    width: size.width,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomRight,
                        end: Alignment.topLeft,
                        colors: [
                          primary1,
                          primary2,
                          primary3,
                        ],
                      ),
                      image: DecorationImage(
                        image: AssetImage("assets/images/card.png"),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          CustomText(
                            text: "تواصل معنا",
                            color: white,
                            size: 22,
                            weight: FontWeight.w700,
                          ),
                          SizedBox(width: size.width * 0.2),
                          Padding(
                            padding: const EdgeInsets.only(right: 15),
                            child: IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        CustomText(text: "الموضوع", size: 18),
                        Card(
                          shadowColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          color: white,
                          child: TextFormField(
                            maxLines: 1,
                            controller: _feedBack,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: BorderSide(
                                  color: black,
                                  width: 1,
                                ),
                              ),
                              hintText: " الموضوع ",
                              suffixIcon: Icon(
                                Icons.chat_bubble_outline_rounded,
                              ),
                            ),
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              color: black,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              fontFamily: "Tajawal",
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        CustomText(text: "الرسالة", size: 18),
                        Card(
                          shadowColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          color: white,
                          child: TextFormField(
                            maxLines: 10,
                            controller: _feedMessage,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: BorderSide(
                                  color: black,
                                  width: 1,
                                ),
                              ),
                            ),
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              color: black,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              fontFamily: "Tajawal",
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 35),
                    child: CustomButton(
                      text: "ارسل",
                      onPressed: () async {
                        final comment = CommentModel(
                          title: _feedBack.text,
                          comment: _feedMessage.text,
                          name: user.name,
                          address: user.city,
                          uid: user.user_id,
                          phone: user.phone,
                          time: DateTime.now(),
                        );

                        await submitComment(comment);
                        _feedBack.clear();
                        _feedMessage.clear();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isLoading) _buildLoadingOverlay(),
          // Show loading overlay when isLoading is true
        ],
      ),
    );
  }

  // Loading overlay widget
  Widget _buildLoadingOverlay() {
    return Stack(
      children: [
        ModalBarrier(color: Colors.black54, dismissible: false),
        Center(
          child: RotatingImagePage(), // Use the same rotating image widget
        ),
      ],
    );
  }
}
