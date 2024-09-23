import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jcp/provider/ProfileProvider.dart';
import 'package:jcp/style/colors.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TraderProfilePage extends StatefulWidget {
  const TraderProfilePage({super.key});

  @override
  State<TraderProfilePage> createState() => _TraderProfilePageState();
}

class _TraderProfilePageState extends State<TraderProfilePage> {
  String? traderName;
  String? storeName;
  String? phoneNumber;
  String? fullAddress;
  bool isEditing = false;

  TextEditingController traderNameController = TextEditingController();
  TextEditingController storeNameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchProfileData();
  }

  Future<void> fetchProfileData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? phone = prefs.getString('phone');

    if (phone != null) {
      final response = await http.get(
        Uri.parse(
            'https://jordancarpart.com/Api/getinfotrader.php?phone=$phone'),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final profileData = data['data'][0]; // Get first item in the data array
        setState(() {
          traderName = profileData['name'];
          storeName = profileData['store'];
          phoneNumber = profileData['phone'];
          fullAddress = profileData['full_address'];
          traderNameController.text = traderName!;
          storeNameController.text = storeName!;
          phoneController.text = phoneNumber!;
          addressController.text = fullAddress!;
        });
      } else {
        throw Exception('Failed to load profile data');
      }
    }
  }

  Future<void> updateProfileData() async {
    // updatemaketrader.php

    //name
    // store
    // address
    //phone
    final profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);
    final phone = profileProvider.getphone();

    final response = await http.post(
      Uri.parse('https://jordancarpart.com/Api/updatemaketrader.php'),
      body: {
        'name': traderNameController.text,
        'store': storeNameController.text,
        'address': addressController.text,
        'phone': phone,
      },
    );
    print(response.body.toString());
    print(phone);

    if (response.statusCode == 200) {
      setState(() {
        isEditing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم تحديث المعلومات بنجاح')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في تحديث المعلومات')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: size.height * 0.2,
                width: size.width,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomRight,
                    end: Alignment.topLeft,
                    colors: [
                      Colors.blue,
                      Colors.blueAccent,
                      Colors.lightBlue,
                    ],
                  ),
                  image: DecorationImage(
                    image: AssetImage("assets/images/card.png"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        top: size.height * 0.05,
                        left: 10,
                        right: 10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Center(
                                child: Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 15),
                        ],
                      ),
                    ),
                    Center(
                      child: Text(
                        "معلومات التاجر",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: size.height * .02),
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image.asset(
                  "assets/images/person.png",
                  height: 110,
                  width: 110,
                ),
              ),
              SizedBox(height: size.height * .01),
              _buildProfileField(
                "إسم صاحب المحل",
                traderNameController,
                isEditing,
              ),
              _buildProfileField(
                "إسم المحل",
                storeNameController,
                isEditing,
              ),
              _buildProfileField(
                "رقم الهاتف",
                phoneController,
                false,
              ),
              _buildProfileField(
                "العنوان الكامل",
                addressController,
                isEditing,
                maxLines: 2,
              ),
              SizedBox(height: 20),
              if (!isEditing)
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isEditing = true;
                    });
                  },
                  child: Text('تعديل المعلومات'),
                ),
              if (isEditing)
                ElevatedButton(
                  onPressed: () {
                    updateProfileData();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // اللون الأحمر لزر "إرسال"
                  ),
                  child: Text(
                    'إرسال',
                    style: TextStyle(color: Colors.white), // نص أبيض
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileField(
      String label, TextEditingController controller, bool enabled,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            shadowColor: Colors.black,
            color: grey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: TextFormField(
                controller: controller,
                enabled: enabled,
                textAlign: TextAlign.end,
                decoration: InputDecoration(
                  border: InputBorder.none,
                ),
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  fontFamily: "Tajawal",
                ),
                maxLines: maxLines,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
