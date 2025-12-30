import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:jcp/screen/auth/login.dart';
import 'package:jcp/screen/auth/otppage.dart';
import 'package:jcp/widget/Inallpage/showConfirmationDialog.dart';
import '../../style/appbar.dart';
import '../../style/colors.dart';
import '../../style/custom_text.dart';
import 'package:jcp/widget/RotatingImagePage.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../../utils/otp_rate_limiter.dart';
// Import the math package for Random
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:flutter/cupertino.dart';
import 'package:jcp/widget/KeyboardActionsUtil.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController fname = TextEditingController();
  TextEditingController lname = TextEditingController();
  TextEditingController phone = TextEditingController();
  String city = "Amman";
  TextEditingController password = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();
  TextEditingController street = TextEditingController();
  bool _isChecked = false;
  final FocusNode fNameFocus = FocusNode();
  final FocusNode lNameFocus = FocusNode();
  final FocusNode phoneFocus = FocusNode();
  final FocusNode streetFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  final FocusNode confirmPasswordFocus = FocusNode();

  final _key = GlobalKey<ScaffoldState>();
  bool ob = true;
  bool ob1 = true;
  bool isLoading = false;
  List<String> list = [
    "عمَان",
    "اربد",
    "الزرقاء",
    "عجلون",
    "جرش",
    "المفرق",
    "البلقاء",
    "مأدبا",
    "الكرك",
    "الطفيلة",
    "معان",
    "العقبة",
  ];

  String phoneHint = "79xxxxxxxxx",
      passHint = "**********",
      passConfirmHint = "**********";

  String fNameHint = "الإسم الاول";
  String lNameHint = "اسم العائلة";

  String image = "assets/images/eye-hide.png";
  String image1 = "assets/images/eye-hide.png";
  String title = "عمَان";

  String generateOTP() {
    final Random _random = Random();
    String otp = '';

    for (int i = 0; i < 6; i++) {
      otp += _random.nextInt(10).toString();
    }
    return otp;
  }

  Future<void> sendOtp(String fname, String lname, String phone,
      String password, String city, String AddressDetail) async {
    setState(() {
      isLoading = true;
    });

    bool startsWithEnglishLetter(String text) {
      if (text.isEmpty) return false;
      return RegExp(r'^[a-zA-Z]').hasMatch(text[0]);
    }

    String capitalizeFirstLetter(String text) {
      if (text.isEmpty) return text;
      return text[0].toUpperCase() + text.substring(1);
    }

    try {
      // Check OTP rate limit first
      final limitCheck = await OtpRateLimiter.checkOtpLimit(phone);

      if (limitCheck['success'] == true && limitCheck['allowed'] == false) {
        setState(() {
          isLoading = false;
        });

        String message = 'لقد تجاوزت الحد المسموح من محاولات إرسال رمز التحقق';
        if (limitCheck['remaining_seconds'] != null) {
          message += '\n\nيمكنك المحاولة مرة أخرى بعد\n${OtpRateLimiter.formatRemainingTime(limitCheck['remaining_seconds'])}';
        }

        showConfirmationDialog(
          context: context,
          message: message,
          confirmText: 'حسناً',
          onConfirm: () {},
          cancelText: '',
        );
        return;
      }

      if (startsWithEnglishLetter(fname)) {
        fname = capitalizeFirstLetter(fname);
      }
      if (startsWithEnglishLetter(lname)) {
        lname = capitalizeFirstLetter(lname);
      }

      // Log OTP attempt
      await OtpRateLimiter.logOtpAttempt(phone);

      setState(() {
        isLoading = false;
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OtpPage(
              phone: phone,
              fname: fname,
              lname: lname,
              password: password,
              city: city,
              AddressDetail: AddressDetail),
        ),
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      showConfirmationDialog(
        context: context,
        message: 'حدث خطأ أثناء إرسال OTP: ',
        confirmText: 'حسناً',
        onConfirm: () {
        },
        cancelText: '',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBarWidget(
        title: "إنشاء حساب جديد",
        color: white,
      ),
      key: _key,
      backgroundColor: white,
      body: KeyboardActions(
        config: KeyboardActionsUtil.buildConfig(context, [
          fNameFocus,
          lNameFocus,
          phoneFocus,
          streetFocus,
          passwordFocus,
          confirmPasswordFocus,
        ]),
        tapOutsideBehavior: TapOutsideBehavior.opaqueDismiss,
        child: SingleChildScrollView(
          child: Stack(
            children: [
            Container(
              child: Column(
                children: [
                  buildInputFields(size),
                  SizedBox(height: 15),
                  MaterialButton(
                    onPressed: () async {
                      if (fname.text.isEmpty ||
                          lname.text.isEmpty ||
                          phone.text.isEmpty ||
                          password.text.isEmpty ||
                          city.isEmpty ||
                          street.text.isEmpty) {
                        showConfirmationDialog(
                          context: context,
                          message: 'الرجاء إكمال جميع الحقول قبل المتابعة',
                          confirmText: 'حسناً',
                          onConfirm: () {},
                          cancelText: '',
                        );
                        return;
                      }
                      if (phone.text.length != 9 ||
                          !phone.text.startsWith('7')) {
                        showConfirmationDialog(
                          context: context,
                          message:
                          'يجب أن يكون رقم الهاتف مكونًا من 9 أرقام ويبدأ بالرقم 7',
                          confirmText: 'حسناً',
                          onConfirm: () {},
                          cancelText: '',
                        );
                        return;
                      }
                      if (password.text != confirmPassword.text) {
                        showConfirmationDialog(
                          context: context,
                          message:
                          'كلمة المرور وتأكيد كلمة المرور غير متطابقتين. يرجى التأكد من تطابقهما',
                          confirmText: 'حسناً',
                          onConfirm: () {},
                          cancelText: '',
                        );
                        return;
                      }
                      if (!_isChecked) {
                        showConfirmationDialog(
                          context: context,
                          message:
                          'يرجى الموافقة على الشروط والأحكام قبل المتابعة',
                          confirmText: 'حسناً',
                          onConfirm: () {},
                          cancelText: '',
                        );
                        return;
                      }

                      String apiUrl =
                          "https://jordancarpart.com/Api/auth/CheckPhone.php?phone=${phone.text}";
                      try {
                        final response = await http.get(Uri.parse(apiUrl));

                        if (response.statusCode == 200) {
                          final data = json.decode(response.body);
                          if (data['success'] == true &&
                              data['exists'] == true) {
                            showConfirmationDialog(
                              context: context,
                              message:
                              '.رقم الهاتف مسجل مسبقًا. يرجى استخدام رقم آخر',
                              confirmText: 'حسناً',
                              onConfirm: () {},
                              cancelText: '',
                            );
                            return;
                          } else if (data['success'] == true &&
                              data['exists'] == false) {
                            sendOtp(fname.text, lname.text, phone.text,
                                password.text, city, street.text);
                          } else {
                            showConfirmationDialog(
                              context: context,
                              message:
                              '. يرجى التحقق من اتصال الإنترنت والمحاولة مرة أخرى',
                              confirmText: 'حسناً',
                              onConfirm: () {},
                            );
                          }
                        } else {
                          showConfirmationDialog(
                            context: context,
                            message:
                            '. يرجى التحقق من اتصال الإنترنت والمحاولة مرة أخرى',
                            confirmText: 'حسناً',
                            onConfirm: () {},
                          );
                        }
                      } catch (e) {
                        showConfirmationDialog(
                          context: context,
                          message:
                          '. يرجى التحقق من اتصال الإنترنت والمحاولة مرة أخرى',
                          confirmText: 'حسناً',
                          onConfirm: () {},
                        );
                      }
                    },
                    height: 50,
                    minWidth: size.width * 0.9,
                    color: Color.fromRGBO(195, 29, 29, 1),
                    child: Text(
                      "إنشاء الحساب",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontFamily: "Tajawal",
                      ),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginPage(),
                              ));
                        },
                        child: CustomText(
                          text: 'تسجيل الدخول',
                          color: red,
                          size: 16,
                          weight: FontWeight.w700,
                        ),
                      ),
                      CustomText(
                        text: 'هل لديك حساب ؟',
                        size: 16,
                        color: Colors.grey.shade600,
                        weight: FontWeight.w700,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (isLoading) _buildLoadingOverlay(),
          ],
        ),
      ),
    ),
    );
  }

  Widget buildInputFields(Size size) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child:
                buildTextField(lname, "إسم العائلة", lNameFocus, lNameHint, (newHint) {
                  setState(() {
                    lNameHint = newHint;
                  });
                }),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child:
                buildTextField(fname, "الإسم الاول", fNameFocus, fNameHint, (newHint) {
                  setState(() {
                    fNameHint = newHint;
                  });
                }),
              ),
            ),
          ],
        ),
        buildPhoneField(),
        SizedBox(
          height: size.height * 0.01,
        ),
        buildCityField(),
        SizedBox(
          height: size.height * 0.01,
        ),
        StreetFieldWidget(
          hintText: "المنطقة - الشارع - رقم البناية",
          controller: street,
          focusNode: streetFocus,
        ),
        Padding(
          padding: const EdgeInsets.all(15.0),
          child:
          buildPasswordField(password, "كلمة المرور", passwordFocus, passHint, ob, (val) {
            setState(() {
              ob = val;
            });
          }),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.0),
          child: buildPasswordField(
              confirmPassword, "تأكيد كلمة المرور", confirmPasswordFocus, passConfirmHint, ob1,
                  (val) {
                setState(() {
                  ob1 = val;
                });
              }),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Checkbox(
                  value: _isChecked,
                  activeColor: Colors.green,
                  onChanged: (value) {
                    setState(() {
                      _isChecked = value!;
                    });
                  },
                ),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      text: 'الموافقة على الشروط والاحكام. ',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: "Tajawal",
                      ),
                      children: [
                        TextSpan(
                          text: 'المزيد...',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 14,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              showDialog(
                                context: context,
                                builder: (context) => Dialog(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                  child: Directionality(
                                    textDirection: TextDirection.rtl,
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.9,
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Center(
                                            child: Text(
                                              "الأحكام والشروط",
                                              style: TextStyle(
                                                fontFamily: "Tajawal",
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 16),
                                          Expanded(
                                            child: SingleChildScrollView(
                                              child: Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "شروط وأحكام استخدام تطبيق قطع سيارات الأردن المملوك لدى شركة بيت المهندسين لتسويق قطع السيارات",
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                      FontWeight.bold,
                                                      fontFamily: "Tajawal",
                                                    ),
                                                  ),
                                                  SizedBox(height: 10),
                                                  Text(
                                                    "يرجى قراءة هذه الشروط والأحكام بعناية قبل استخدام تطبيقنا. بمجرد استخدامك للتطبيق، فإنك تقر بأنك قرأت وفهمت ووافقت على الالتزام بهذه الشروط. إذا كنت لا توافق على أي جزء من هذه الشروط، يرجى التوقف عن استخدام التطبيق فورًا.",
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontFamily: "Tajawal",
                                                    ),
                                                    textAlign:
                                                    TextAlign.justify,
                                                  ),
                                                  SizedBox(height: 16),
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey[200],
                                                      borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                    ),
                                                    padding:
                                                    const EdgeInsets.all(
                                                        16.0),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .start,
                                                      children: [
                                                        ..._buildTerms(),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 16),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: red,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(8),
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 32, vertical: 12),
                                            ),
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                            child: Text(
                                              "تم",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: "Tajawal",
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  List<Widget> _buildTerms() {
    return [

      _buildSection("1. التعريفات", [
        "1.1. \"التطبيق\" يشير إلى تطبيق قطع سيارات الأردن.",
        "1.2. \"الشركة\" تشير إلى شركة بيت المهندسين لتسويق قطع السيارات ذ.م.م.",
        "1.3. \"المستخدم\" يشير إلى أي شخص يقوم باستخدام التطبيق.",
        "1.4. \"المورد\" أو \"التاجر\" يشير إلى المحلات أو الجهات التجارية التي تعرض قطع سيارات عبر التطبيق.",
        "1.5. \"شركة التوصيل\" أو \"المتعهد\" تشير إلى الجهات أو الأفراد المتعاقد معهم لنقل وتوصيل الطلبات.",
      ]),

      _buildSection("2. هدف التطبيق", [
        "2.1. التطبيق يعمل كوسيط لتوفير قطع السيارات من الموردين للعملاء، ولا يمتلك القطع المعروضة.",
        "2.2. تسعى الشركة لتقديم أفضل الخيارات من حيث السعر والجودة قدر الإمكان.",
        "2.3. الشركة تسهل التواصل بين الموردين والعملاء، وتُصدر فقط \"فاتورة عمولة التسويق\" الخاصة بها.",
      ]),

      _buildSection("3. استخدام التطبيق", [
        "3.1. يحق للمستخدم استخدام التطبيق للأغراض الشخصية فقط، ما لم يتم الاتفاق خلاف ذلك كتابيًا مع الشركة.",
        "3.2. يمنع إساءة استخدام التطبيق بأي شكل يؤدي لتعطيل الخدمات أو التأثير على المستخدمين الآخرين.",
        "3.3. تحتفظ الشركة بحق تعديل أو إيقاف التطبيق جزئيًا أو كليًا دون إشعار مسبق.",
      ]),

      _buildSection("4. البيانات الشخصية وسياسة الخصوصية", [
        "4.1. نقوم بجمع المعلومات التي تقدمها عند التسجيل أو التواصل معنا (مثل الاسم، رقم الهاتف) وبيانات الاستخدام لتحسين الخدمة.",
        "4.2. يتم استخدام المعلومات لتقديم الخدمة، والتواصل معك، وتحسين تجربة الاستخدام، وضمان أمن التطبيق.",
        "4.3. لا تتم مشاركة بياناتك مع أي طرف ثالث إلا بعد موافقتك أو إذا كان مطلوبًا قانونيًا، أو لتحسين الخدمة (مثلاً مشاركة رقم هاتفك مع المورد أو شركة التوصيل لتنفيذ الطلب).",
        "4.4. نستخدم تدابير تقنية وإدارية لحماية بياناتك. جميع بيانات الدفع تمر عبر بوابات دفع إلكترونية معتمدة ولا يتم تخزينها على خوادمنا.",
        "4.5. جميع بيانات الدفع الإلكتروني تتم معالجتها مباشرة عبر مزود دفع إلكتروني معتمد وآمن. لا يتم في أي وقت تخزين بيانات بطاقات الدفع أو أرقام البطاقات الائتمانية أو الرموز السرية على خوادم التطبيق.",
      ]),

      _buildSection("5. إخلاء المسؤولية", [
        "5.1. التطبيق يُقدّم \"كما هو\" دون أي ضمانات صريحة أو ضمنية.",
        "5.2. الشركة غير مسؤولة عن أي أضرار مباشرة أو غير مباشرة نتيجة استخدام التطبيق.",
        "5.3. لا تضمن الشركة دقة أو اكتمال أو موثوقية أي محتوى معروض في التطبيق.",
      ]),

      _buildSection("6. حقوق الملكية الفكرية", [
        "6.1. جميع الحقوق الفكرية المتعلقة بالتطبيق ومحتوياته مملوكة للشركة ومرخصة لها.",
        "6.2. يمنع نسخ أو تعديل أو توزيع أي جزء من التطبيق دون إذن خطي مسبق من الشركة.",
      ]),

      _buildSection("7. التعاملات المالية والدفع الإلكتروني", [
        "7.1. جميع الأسعار قابلة للتغيير دون إشعار مسبق.",
        "7.2. أي معاملات مالية بين المستخدمين والموردين هي مسؤولية الطرفين فقط.",
        "7.3. تصدر \"فاتورة القطع\" من المورد، و\"فاتورة التوصيل\" من شركة التوصيل (عند وجود رسوم توصيل).",
        "7.4. تصدر الشركة فقط \"فاتورة عمولة التسويق\" الخاصة بها.",
        "7.5. جميع بيانات الدفع الإلكتروني تمر عبر بوابات دفع معتمدة وآمنة وفق معايير PCI DSS ولا يتم حفظ بيانات البطاقة لدينا.",
        "7.6. يمكنك التأكد من أمان العملية من خلال ظهور شعارات Visa وMasterCard عند الدفع.",
      ]),

      _buildSection("8. سياسة التوصيل", [
        "8.1. التوصيل يتم عبر المورد أو شركة توصيل أو متعهد مستقل حسب نوع الطلب وموقع العميل.",
        "8.2. مدة التوصيل تختلف حسب القطعة والموقع وتُحدد من قبل المورد أو شركة التوصيل.",
        "8.3. رسوم التوصيل تُوضح مسبقًا وتُدفع مباشرة للجهة المسؤولة عن التوصيل.",
        "8.4. عند توفر خدمة تتبع الطلب، يتم إرسال رقم التتبع للعميل.",
        "8.5. في حال وجود مشكلة في التوصيل، يرجى التواصل مع المورد أو دعم التطبيق.",
      ]),

      _buildSection("9. سياسة الإلغاء، الاسترجاع، والاستبدال", [
        "9.1. يمكن إلغاء الطلب خلال ساعة واحدة فقط من إتمام عملية الشراء، ما لم يتم شحن القطعة.",
        "9.2. بعد تنفيذ الطلب، يخضع الاسترجاع لسياسة المورد.",
        "9.3. يُسمح بالاسترجاع فقط في الحالات التالية: (أ) إذا كانت القطعة غير مطابقة للوصف، (ب) إذا كانت تالفة، (ج) إذا تم تسليم قطعة خاطئة.",
        "9.4. يجب تقديم طلب الاسترجاع خلال 24 ساعة من استلام القطعة.",
        "9.5. يشترط أن تكون القطعة في حالتها الأصلية وغير مستخدمة.",
        "9.6. يتحمل الزبون رسوم الشحن والإرجاع إلا إذا كانت القطعة خاطئة أو تالفة.",
        "9.7. لا يمكن استرجاع أو استبدال القطع الكهربائية أو بعد تركيبها.",
        "9.8. في حال سوء الاستخدام يحق للشركة رفض الطلب.",
        "9.9. للتواصل بخصوص الإرجاع: 0795888268 أو jcpofficialjo@gmail.com.",
      ]),

      _buildSection("10. الشروط الخاصة بحالة القطع ومدة الكفالة", [
        "10.1. جميع القطع المعروضة مسؤولية الموردين.",
        "10.2. الشركة لا تضمن حالة القطع أو الكفالة.",
        "10.3. النزاعات المتعلقة بالكفالة تُحل مباشرة بين المستخدم والمورد.",
      ]),

      _buildSection("11. سياسة شركات التوصيل والمتعهدين", [
        "11.1. تعتمد الشركة على شركات توصيل أو متعهدين مستقلين.",
        "11.2. شركات التوصيل جهات مستقلة ولا علاقة شراكة بينها وبين الشركة.",
        "11.3. التوصيل مسؤولية الجهة الناقلة من الاستلام حتى التسليم.",
        "11.4. الشركة غير مسؤولة عن التأخير أو التلف الناتج عن شركة التوصيل.",
        "11.5. الشكاوى تُتابع مع دعم التطبيق أو شركة التوصيل مباشرة.",
        "11.6. شركات التوصيل ملزمة بالحفاظ على سرية بيانات العملاء.",
      ]),

      _buildSection("12. سياسة التعامل مع الموردين (التجار)", [
        "12.1. المورد أو التاجر هو أي جهة تجارية تعرض قطع السيارات عبر التطبيق.",
        "12.2. يلتزم المورد بتقديم بيانات صحيحة ودقيقة للقطع.",
        "12.3. يتحمل المورد كامل المسؤولية عن صحة وجودة القطع.",
        "12.4. تقتصر مسؤولية الشركة على التسويق فقط.",
        "12.5. تحصل الشركة على عمولة محددة مسبقًا تُسوى خلال 24 ساعة من الصفقة.",
        "12.6. في حال الغش أو التلاعب، يحق للشركة إيقاف الحساب والمطالبة بتعويض.",
        "12.7. تخضع العلاقة بين المورد والمنصة لقوانين المملكة الأردنية الهاشمية.",
      ]),

      _buildSection("13. سياسة الطلبات الخاصة", [
        "13.1. عروض الأسعار صالحة لمدة 30 يومًا فقط من وقت العرض.",
        "13.2. يتم الدفع كاملًا مقدمًا عند تأكيد الطلب.",
        "13.3. المدد الزمنية تقديرية ولا تتحمل الشركة مسؤولية التأخير الناتج عن الجمارك أو الشحن.",
        "13.4. لا يمكن الإلغاء بعد التجهيز إلا وفق الشروط المحددة.",
        "13.5. على العميل فحص الشحنة خلال 24 ساعة من الاستلام.",
        "13.6. لا استرجاع للقطع المصنّعة حسب الطلب أو بعد فتحها أو تركيبها.",
      ]),

      _buildSection("14. التعديلات على الشروط والسياسات", [
        "14.1. تحتفظ الشركة بحق تعديل هذه الشروط والسياسات في أي وقت.",
        "14.2. استمرار استخدامك للتطبيق يعني الموافقة الضمنية على التعديلات.",
      ]),

      _buildSection("15. تسوية النزاعات", [
        "15.1. تسعى الشركة لحل النزاعات وديًا، وفي حال تعذر، يتم اللجوء للمحكمة المختصة في محافظة إربد.",
      ]),

      _buildSection("16. القانون الواجب التطبيق", [
        "16.1. تخضع هذه الشروط لقوانين المملكة الأردنية الهاشمية.",
        "16.2. المحاكم الأردنية (محافظة إربد) هي المختصة بالنزاعات.",
      ]),

      _buildSection("17. الاتصال والدعم", [
        "لأي استفسارات أو ملاحظات أو شكاوى، يرجى التواصل معنا عبر البريد الإلكتروني: jcpofficialjo@gmail.com",
        "بوضع علامة صح في مربع الموافقة على الشروط والأحكام، فإنك تقر بموافقتك الكاملة على جميع ما ورد في هذه الشروط والأحكام وسياسات الاستخدام.",
      ]),
    ];
  }

  Widget _buildSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            fontFamily: "Tajawal",
          ),
        ),
        SizedBox(height: 8),
        ...items.map((item) => Text(
          item,
          style: TextStyle(
            fontSize: 14,
            fontFamily: "Tajawal",
          ),
        )),
        SizedBox(height: 16),
      ],
    );
  }

  Widget buildTextField(
      TextEditingController controller,
      String labelText,
      FocusNode focusNode,
      String initialHintText,
      Function(String) updateHint,
      ) {
    String hintText = initialHintText;

    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 6.5),
              child: CustomText(
                text: labelText,
                size: 18,
              ),
            ),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              shadowColor: Colors.black,
              color: grey,
              child: TextFormField(
                controller: controller,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: hintText,
                ),
                focusNode: focusNode,
                onTap: () {
                  setState(() {
                    updateHint("");
                  });
                },
                onChanged: (value) {
                  setState(() {
                    if (value.isEmpty) {
                      updateHint(labelText);
                    }
                  });
                },
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w100,
                  fontSize: 16,
                  fontFamily: "Tajawal",
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildPhoneField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 6.5),
            child: CustomText(
              text: "رقم الهاتف",
              size: 18,
            ),
          ),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            color: grey,
            child: SizedBox(
              height: 47,
                child: IntlPhoneField(
                  focusNode: phoneFocus,
                  onTap: () {
                    setState(() {
                      phoneHint = "";
                    });
                  },
                  disableLengthCheck: true,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  textAlign: TextAlign.start,
                  decoration: InputDecoration(
                    hintText: phoneHint,
                    border: InputBorder.none,
                    hintStyle: const TextStyle(
                      color: Color.fromRGBO(153, 153, 160, 1),
                      fontSize: 18,
                      fontFamily: "Tajawal",
                      fontWeight: FontWeight.w100,
                    ),
                    contentPadding:
                    const EdgeInsets.only(top: 3.0, left: 12.0),
                  ),
                  flagsButtonMargin: const EdgeInsets.only(right: 5),
                  disableAutoFillHints: true,
                  textAlignVertical: TextAlignVertical.center,
                  initialCountryCode: 'JO',
                  controller: phone,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  onChanged: (phoneNumber) {
                    String x = phoneNumber.completeNumber;
                    if (phoneNumber.number.isEmpty) {
                      setState(() {
                        phoneHint = "79xxxxxxxxx";
                      });
                    } else if (phoneNumber.number[0] == '0') {
                      x = x.replaceFirst("0", "");
                    }
                  },
                  onSubmitted: (value) {
                    phoneFocus.unfocus();
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildCityField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 6.5),
            child: CustomText(
              text: "المحافظة",
              size: 18,
            ),
          ),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            color: grey,
            child: DropdownButtonFormField<String>(
              dropdownColor: Colors.white,
              padding: EdgeInsets.only(right: 5),
              alignment: Alignment.center,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.keyboard_arrow_down_rounded),
                border: InputBorder.none,
              ),
              items: list.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  alignment: Alignment.centerRight,
                  child: CustomText(
                    text: value,
                    color: Colors.black,
                  ),
                );
              }).toList(),
              value: title,
              isExpanded: true,
              menuMaxHeight: 200,
              icon: Container(),
              iconSize: 30.0,
              onChanged: (val) {
                setState(() {
                  title = val!;
                  city = title;
                });
              },
              borderRadius: BorderRadius.circular(10),
              elevation: 10,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500,
                fontSize: 16,
                fontFamily: "Tajawal",
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPasswordField(
      TextEditingController controller,
      String labelText,
      FocusNode focusNode,
      String hintText,
      bool obscureText,
      Function(bool) toggleVisibility,
      ) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 6.5),
              child: CustomText(
                text: labelText,
                size: 18,
              ),
            ),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              shadowColor: Colors.black,
              color: grey,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: TextFormField(
                  controller: controller,
                  focusNode: focusNode,
                  textAlign: TextAlign.end,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: hintText,
                    icon: GestureDetector(
                      onTap: () {
                        setState(() {
                          ob = !ob;
                          image = ob
                              ? "assets/images/eye-hide.png"
                              : "assets/images/eye-show.png";
                        });
                      },
                      child: Image.asset(
                        image,
                        width: 32,
                        height: 32,
                      ),
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      hintText = "";
                    });
                  },
                  onChanged: (value) {
                    if (value.isEmpty) {
                      setState(() {
                        hintText = "**********";
                      });
                    }
                  },
                  obscureText: ob,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    fontFamily: "Tajawal",
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoadingOverlay() {
    return Stack(
      children: [
        ModalBarrier(color: Colors.black54, dismissible: false),
        Center(
          child: RotatingImagePage(),
        ),
      ],
    );
  }
}

class StreetFieldWidget extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;
  final FocusNode focusNode;

  const StreetFieldWidget({
    Key? key,
    required this.hintText,
    required this.controller,
    required this.focusNode,
  }) : super(key: key);

  @override
  _StreetFieldWidgetState createState() => _StreetFieldWidgetState();
}

class _StreetFieldWidgetState extends State<StreetFieldWidget> {
  late String currentHintText;

  @override
  void initState() {
    super.initState();
    currentHintText = widget.hintText;

    widget.focusNode.addListener(() {
      setState(() {
        if (widget.focusNode.hasFocus) {
          currentHintText = '';
        } else if (widget.controller.text.isEmpty) {
          currentHintText = widget.hintText;
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 6.5),
            child: CustomText(
              text: "تفاصيل العنوان",
              size: 18,
              color: Colors.black,
            ),
          ),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            color: grey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: TextFormField(
                controller: widget.controller,
                focusNode: widget.focusNode,
                textAlign: TextAlign.end,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: currentHintText,
                  hintStyle: TextStyle(
                    color: Color.fromRGBO(153, 153, 160, 1),
                    fontSize: 16,
                    fontFamily: "Tajawal",
                    fontWeight: FontWeight.w100,
                  ),
                ),
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                  fontFamily: "Tajawal",
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
