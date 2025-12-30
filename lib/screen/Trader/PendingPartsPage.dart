import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jcp/style/colors.dart';
import 'package:jcp/widget/RotatingImagePage.dart';
import 'dart:convert';
import 'dart:async';
import 'package:provider/provider.dart';
import '../../provider/ProfileProvider.dart';
import '../../style/custom_text.dart';
import '../../widget/Inallpage/showConfirmationDialog.dart';
import '../../widget/FullScreenImageViewer.dart';
import 'PartDetailsPage.dart';

class PendingPartsPage extends StatefulWidget {
  const PendingPartsPage({super.key});

  @override
  _PendingPartsPageState createState() => _PendingPartsPageState();
}

class _PendingPartsPageState extends State<PendingPartsPage> {
  List<Map<String, dynamic>> pendingParts = [];
  bool isLoading = true;
  Timer? _timer;
  final int _limit = 50;
  int _offset = 0;
  bool _isFetchingMore = false;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    loadPendingParts();
    _startAutoRefresh();
    _scrollController.addListener(_scrollListener);
  }

  Future<void> _silentRefresh() async {
    try {
      final user = Provider.of<ProfileProvider>(context, listen: false);

      final url = Uri.parse(
          'https://jordancarpart.com/Api/trader/getTraderInvitationsCount2.php?user_id=${user.user_id}&limit=$_limit&offset=0');

      final response = await http.get(url, headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      });
      print(url);
      print(response.body);
      if (response.statusCode == 200) {
        final responseData = jsonDecode(utf8.decode(response.bodyBytes));
        if (responseData['success'] == true) {
          final recentInvitations =
          responseData['data']['recent_invitations'] as List;

          final pendingInvitations = recentInvitations
              .where((invitation) => invitation['status'] == 'pending')
              .map((invitation) => invitation as Map<String, dynamic>)
              .toList();
          setState(() {
            pendingParts = pendingInvitations;
          });
        }
      }
    } catch (e) {}
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100 &&
        !_isFetchingMore &&
        _hasMore) {
      loadPendingParts(loadMore: true);
    }
  }

  Future<void> loadPendingParts({bool loadMore = false}) async {
    try {
      final user = Provider.of<ProfileProvider>(context, listen: false);

      if (!loadMore) {
        setState(() {
          isLoading = true;
          _offset = 0;
          _hasMore = true;
        });
      } else {
        setState(() {
          _isFetchingMore = true;
        });
      }

      final url = Uri.parse(
          'https://jordancarpart.com/Api/trader/getTraderInvitationsCount2.php?user_id=${user.user_id}&limit=$_limit&offset=$_offset');

      final response = await http.get(url, headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      });

      if (response.statusCode == 200) {
        final responseData =
        jsonDecode(utf8.decode(response.bodyBytes)); // ✅ UTF-8 fix

        if (responseData['success'] == true) {
          final recentInvitations =
          responseData['data']['recent_invitations'] as List;

          final pendingInvitations = recentInvitations
              .where((invitation) => invitation['status'] == 'pending')
              .map((invitation) => invitation as Map<String, dynamic>)
              .toList();

          setState(() {
            if (loadMore) {
              pendingParts.addAll(pendingInvitations);
            } else {
              pendingParts = pendingInvitations;
            }

            _offset += _limit;
            _hasMore = pendingInvitations.length == _limit;
            isLoading = false;
            _isFetchingMore = false;
          });
        } else {
          setState(() {
            isLoading = false;
            _isFetchingMore = false;
          });
        }
      } else {
        setState(() {
          isLoading = false;
          _isFetchingMore = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        _isFetchingMore = false;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _startAutoRefresh() {
    _timer = Timer.periodic(const Duration(seconds: 7), (timer) {
      if (mounted && _scrollController.position.pixels == 0) {
        _silentRefresh();
      }
    });
  }

  Widget _buildHeader(Size size) {
    return Container(
      height: size.height * 0.2,
      width: size.width,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
          colors: [
            Color(0xFFB02D2D),
            Color(0xFFC41D1D),
            Color(0xFF7D0A0A),
          ],
          stops: [0.1587, 0.3988, 0.9722],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          top: size.height * 0.075,
          left: 10,
          right: 10,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 40),
            CustomText(
              text: "قطع للتسعير",
              color: Colors.white,
              size: 22,
              weight: FontWeight.w900,
            ),
            Directionality(
              textDirection: TextDirection.rtl,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                behavior: HitTestBehavior.translucent,
                child: Container(
                  padding: const EdgeInsets.all(25.0),
                  color: Colors.transparent,
                  child: const Icon(Icons.arrow_back_ios_rounded,
                      color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateInvitationStatus(int invitationId, String status) async {
    try {
      final response = await http.post(
        Uri.parse('https://jordancarpart.com/Api/updateInvitationStatus.php'),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          'invitation_id': invitationId,
          'status': status,
        }),
      );
      if (response.statusCode == 200) {
        final responseData =
        jsonDecode(utf8.decode(response.bodyBytes)); // ✅ UTF-8 fix
        if (responseData['success'] == true) {
          loadPendingParts();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: CustomText(
                text: "تم رفض الدعوة بنجاح",
                color: Colors.white,
                textAlign: TextAlign.center,
              ),
              backgroundColor: red,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: CustomText(
            text: "خطأ في رفض الدعوة",
            color: Colors.white,
            textAlign: TextAlign.center,
          ),
          backgroundColor: red,
        ),
      );
    }
  }

  Future<void> _requestPartImage(Map<String, dynamic> part) async {
    try {
      final user = Provider.of<ProfileProvider>(context, listen: false);
      final response = await http.post(
        Uri.parse('https://jordancarpart.com/Api/trader/requestPartImage.php'),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          'invitation_id': part['id'],
          'trader_id': user.user_id,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(utf8.decode(response.bodyBytes));
        if (responseData['success'] == true) {
          setState(() {
            part['is_image_requested'] = 1;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: CustomText(
                text: "تم إرسال طلب الصورة بنجاح",
                color: Colors.white,
                textAlign: TextAlign.center,
              ),
              backgroundColor: red,
            ),
          );
        } else {
          throw Exception(responseData['message']);
        }
      } else {
        throw Exception("Server error: ${response.statusCode}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: CustomText(
            text: "خطأ في إرسال الطلب",
            color: Colors.white,
            textAlign: TextAlign.center,
          ),
          backgroundColor: red,
        ),
      );
    }
  }

  void _showDeclineConfirmation(Map<String, dynamic> part) {
    bool hasImage = part['image_path'] != null && part['image_path'].toString().isNotEmpty;
    bool isImageRequested = part['is_image_requested'] == 1 || part['is_image_requested'] == true;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                const Text(
                  "هل أنت متأكد من عدم توفر هذه القطعة في المتجر لديك؟",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontFamily: "Tajawal",
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // زر لا (إلغاء)
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                          ),
                          child: const Text(
                            "لا",
                            style: TextStyle(color: Colors.white, fontSize: 13, fontFamily: "Tajawal"),
                          ),
                        ),
                        const SizedBox(width: 15),
                        // زر نعم (رفض)
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _updateInvitationStatus(part['id'], 'declined');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                          ),
                          child: const Text(
                            "نعم",
                            style: TextStyle(color: Colors.white, fontSize: 13, fontFamily: "Tajawal"),
                          ),
                        ),
                      ],
                    ),
                    if (!hasImage && !isImageRequested) ...[
                      const SizedBox(height: 12),
                      // زر طلب صورة (يظهر فقط إذا لم تكن هناك صورة ولم يسبق طلبه)
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _requestPartImage(part);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                        ),
                        child: const Text(
                          "طلب صورة",
                          style: TextStyle(color: Colors.white, fontSize: 13, fontFamily: "Tajawal"),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(size),
          Expanded(
            child: isLoading
                ? Center(child: RotatingImagePage())
                : pendingParts.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.build_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  CustomText(
                    text: "لا توجد قطع معلقة للتسعير",
                    color: Colors.grey,
                    size: 16,
                  ),
                ],
              ),
            )
                : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount:
              pendingParts.length + (_isFetchingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == pendingParts.length && _isFetchingMore) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: RotatingImagePage(),
                    ),
                  );
                }

                final part = pendingParts[index];
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: CustomText(
                            text: part['part_name'] ?? 'غير محدد',
                            color: Colors.black,
                            size: 16,
                            weight: FontWeight.bold,
                            textDirection: TextDirection.rtl,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onLongPress: () {
                        _showDeclineConfirmation(part);
                      },
                      child: Card(
                        color: const Color(0xFFF6F6F6),
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment:
                                CrossAxisAlignment.center,
                                children: [
                                  CustomText(
                                    color: const Color(0xFF8D8D92),
                                    text: [
                                      part['car_name'],
                                      part['car_category'],
                                      part['fuel_type'],
                                      part['car_year'],
                                      part['engine_size'],
                                    ]
                                        .where((e) =>
                                    e != null &&
                                        e
                                            .toString()
                                            .trim()
                                            .isNotEmpty &&
                                        e != "N/A")
                                        .join(' '),
                                  ),
                                ],
                              ),
                              if (part['chassis_number'] != null &&
                                  part['chassis_number']
                                      .toString()
                                      .trim()
                                      .isNotEmpty &&
                                  part['chassis_number'] != "N/A")
                                Padding(
                                  padding:
                                  const EdgeInsets.only(top: 4.0),
                                  child: Center(
                                    child: CustomText(
                                      text:
                                      "${part['chassis_number']}",
                                      color: const Color(0xFF8D8D92),
                                      size: 13,
                                      weight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 4),
                              Center(
                                child: CustomText(
                                  text: part['invitation_date'] ??
                                      'غير محدد',
                                  color: Colors.grey[600],
                                  size: 12,
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 100,
                                    height: 30,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 8),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  PartDetailsPage(
                                                      part: part)),
                                        ).then((value) {
                                          loadPendingParts();
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: green,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: CustomText(
                                        text: "تسعير",
                                        color: Colors.white,
                                        size: 15,
                                        weight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  if (part['image_path'] != null &&
                                      part['image_path'].toString().isNotEmpty)
                                    Container(
                                      width: 100,
                                      height: 30,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 8),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => FullScreenImageViewer(
                                              imageUrl: 'https://jordancarpart.com/Api/${part['image_path']}',
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: orange, // A different color for distinction
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: CustomText(
                                          text: "صورة",
                                          color: Colors.white,
                                          size: 14,
                                          weight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
