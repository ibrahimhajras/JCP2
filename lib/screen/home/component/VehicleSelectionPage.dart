import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../../model/category_model.dart';
import '../../../provider/EngineSizeProvider.dart';
import '../../../style/colors.dart';
import '../../../style/custom_text.dart';
import '../../../widget/RotatingImagePage.dart';

class VehicleSelectionPage extends StatefulWidget {
  const VehicleSelectionPage({Key? key}) : super(key: key);

  @override
  State<VehicleSelectionPage> createState() => _VehicleSelectionPageState();
}

const String baseUrl = "https://jordancarpart.com/Api";

class _VehicleSelectionPageState extends State<VehicleSelectionPage>
    with TickerProviderStateMixin {
  late AnimationController _cardController;
  late AnimationController _progressController;
  late Animation<double> _cardAnimation;
  late Animation<double> _progressAnimation;
  Color focusedColor = Colors.black;
  Color bor = green;
  int count = 0;
  String hint = "1 H G B H 4 1 J X M N 1 0 9 1 8 6";

  List<String> brands = [];
  List<CategoryModel> categories = [];

  String? selectedBrand;
  CategoryModel? selectedCategory;

  int currentStep = 0;

  bool isLoadingBrands = true;
  bool isLoadingCategories = false;

  final Map<String, List<String>> years = {
    'default': List.generate(
        40, (index) => (DateTime.now().year + 2 - index).toString()),
  };

  final List<String> fuelTypes = [
    'Gasoline',
    'Diesel',
    'Electric',
    'Hybrid',
    'Plug in'
  ];

  String? selectedYear;
  String? selectedFuelType;
  String? selectedEngineSize;
  String? selectedChassisNumber;

  // ✅ إضافة controller لرقم الشاصي
  final TextEditingController chassisController = TextEditingController();

  Future<void> _fetchBrands() async {
    setState(() {
      isLoadingBrands = true;
    });
    try {
      final response = await http.get(Uri.parse("$baseUrl/get_all_cars.php"));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['status'] == 'success') {
          setState(() {
            brands = List<String>.from(jsonData['data']);
          });
        }
      }
    } catch (e) {
    } finally {
      setState(() {
        isLoadingBrands = false;
      });
    }
  }

  Future<void> _fetchCategories(String carName) async {
    setState(() {
      isLoadingCategories = true;
    });
    try {
      final response = await http.get(Uri.parse(
          "$baseUrl/get_all_categories2.php?car_name=${Uri.encodeComponent(carName)}"));

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);

        final jsonData = jsonDecode(decodedBody);

        if (jsonData['status'] == 'success') {
          setState(() {
            categories = (jsonData['data'] as List)
                .map((item) => CategoryModel.fromJson(item))
                .toList();
          });
        } else {
          setState(() {
            categories = [];
          });
        }
      }
    } catch (e) {
    } finally {
      setState(() {
        isLoadingCategories = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    // أولاً: إنشاء الـ AnimationControllers
    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    // ثانياً: إنشاء الـ Animations
    _cardAnimation = CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeOutBack,
    );

    _progressAnimation = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOutCubic,
    );

    // ثالثاً: بدء الـ animations
    _cardController.forward();

    // رابعاً: باقي العمليات
    _fetchBrands();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EngineSizeProvider>(context, listen: false)
          .fetchEngineSizes();
    });
  }

  @override
  void dispose() {
    _cardController.dispose();
    _progressController.dispose();
    chassisController.dispose();
    super.dispose();
  }

  void _nextStep() {
    setState(() {
      currentStep++;
      _progressController.animateTo(
        currentStep / 6,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
    _cardController.reset();
    _cardController.forward();
  }

  void _onBrandSelected(String brand) async {
    setState(() {
      selectedBrand = brand;
      selectedCategory = null;
      selectedYear = null;
      selectedFuelType = null;
      selectedEngineSize = null;
      selectedChassisNumber = null;
      chassisController.clear(); // ✅ تنظيف حقل رقم الشاصي
    });
    _nextStep();
    await _fetchCategories(brand);
    _cardController.reset();
    _cardController.forward();
  }

  void _onCategorySelected(CategoryModel category) async {
    setState(() {
      selectedCategory = category;
      selectedYear = null;
      selectedFuelType = null;
      selectedEngineSize = null;
      selectedChassisNumber = null;
      chassisController.clear(); // ✅ تنظيف حقل رقم الشاصي
    });
    await Future.delayed(const Duration(milliseconds: 200));
    _nextStep();
  }

  void _onYearSelected(String year) {
    setState(() {
      selectedYear = year;
      selectedFuelType = null;
      selectedEngineSize = null;
      selectedChassisNumber = null;
      chassisController.clear(); // ✅ تنظيف حقل رقم الشاصي
    });
    _nextStep();
  }

  void _onFuelTypeSelected(String fuelType) async {
    setState(() {
      selectedFuelType = fuelType;
      selectedEngineSize = null;
    });

    if (fuelType.toLowerCase().contains('electric') ||
        fuelType.toLowerCase().contains('كهرب')) {
      setState(() {
        selectedEngineSize = 'N/A';
      });
      // نكمل للخطوة التالية (رقم الشاصي) بدلاً من الخروج
      _nextStep();
    } else {
      // إذا مش كهربا نكمل الخطوات العادية
      _nextStep();
    }
  }

  void _onEngineSizeSelected(String engineSize) {
    setState(() {
      selectedEngineSize = engineSize;
    });
    _nextStep();
  }

  void _onChassisNumberEntered(String chassisNumber) {
    setState(() {
      selectedChassisNumber =
          chassisNumber.trim().isEmpty ? 'N/A' : chassisNumber.trim();
    });

    Future.delayed(const Duration(milliseconds: 400), () {
      final result = {
        'brand': selectedBrand!,
        'model': selectedCategory!.categoryName,
        'year': selectedYear!,
        'fuelType': selectedFuelType!,
        'engineSize': selectedEngineSize!,
        'chassisNumber': selectedChassisNumber!,
      };

      Navigator.pop(context, result);
    });
  }

  void _skipChassisNumber() {
    setState(() {
      selectedChassisNumber = 'N/A';
    });

    Future.delayed(const Duration(milliseconds: 400), () {
      final result = {
        'brand': selectedBrand!,
        'model': selectedCategory!.categoryName,
        'year': selectedYear!,
        'fuelType': selectedFuelType!,
        'engineSize': selectedEngineSize!,
        'chassisNumber': selectedChassisNumber!,
      };

      Navigator.pop(context, result);
    });
  }

  Widget _buildProgressBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStepIndicator(0, 'نوع السيارة', Icons.directions_car),
              _buildConnector(0),
              _buildStepIndicator(1, 'الفئة', Icons.model_training),
              _buildConnector(1),
              _buildStepIndicator(2, 'السنة', Icons.calendar_today),
              _buildConnector(2),
              _buildStepIndicator(3, 'الوقود', Icons.local_gas_station),
              _buildConnector(3),
              _buildStepIndicator(4, 'المحرك', Icons.settings),
              _buildConnector(4),
              _buildStepIndicator(5, 'الشاصي', Icons.confirmation_number),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: red.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return Stack(
                    children: [
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.grey.shade100,
                              Colors.grey.shade200,
                            ],
                          ),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: _progressAnimation.value,
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                primary1,
                                primary2,
                                primary3,
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
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label, IconData icon) {
    bool isActive = currentStep >= step;
    bool isCurrent = currentStep == step;
    bool isEngineStep = label.contains('المحرك');

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutBack,
          width: isCurrent ? 50 : 38,
          height: isCurrent ? 50 : 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isActive
                ? LinearGradient(
                    colors: [
                      primary1,
                      primary2,
                      primary3,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isActive ? null : Colors.grey.shade300,
            boxShadow: isCurrent
                ? [
                    BoxShadow(
                      color: red.withOpacity(0.5),
                      blurRadius: 15,
                      spreadRadius: 3,
                    ),
                  ]
                : isActive
                    ? [
                        BoxShadow(
                          color: red.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
            border: isCurrent
                ? Border.all(
                    color: Colors.white,
                    width: 3,
                  )
                : null,
          ),
          child: Center(
            child: isEngineStep
                ? Image.asset(
                    isActive
                        ? 'assets/images/engine.png'
                        : 'assets/images/engine2.png',
                    color: isActive ? Colors.white : Colors.grey.shade600,
                    width: isCurrent ? 26 : 22,
                    height: isCurrent ? 26 : 22,
                    fit: BoxFit.contain,
                  )
                : Icon(
                    icon,
                    color: isActive ? Colors.white : Colors.grey.shade500,
                    size: isCurrent ? 24 : 20,
                  ),
          ),
        ),
        const SizedBox(height: 6),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: isCurrent ? 11 : 10,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w400,
            color: isActive ? red : Colors.grey.shade500,
          ),
          child: Text(label),
        ),
      ],
    );
  }

  Widget _buildConnector(int step) {
    bool isActive = currentStep > step;
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        height: 3,
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          gradient: isActive
              ? LinearGradient(
                  colors: [
                    primary1,
                    primary2,
                    primary3,
                  ],
                )
              : null,
          color: isActive ? null : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    if (selectedBrand == null) return const SizedBox();

    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;
    final isMediumScreen = size.width >= 360 && size.width < 400;
    final horizontalMargin = size.width * 0.04;
    final verticalMargin = size.height * 0.008;
    final containerPadding = size.width * 0.035;
    final borderRadius = isSmallScreen ? 16.0 : 18.0;
    final titleFontSize = isSmallScreen ? 14.0 : (isMediumScreen ? 16.0 : 17.0);
    final iconSize = isSmallScreen ? 20.0 : 22.0;
    final circleSize = isSmallScreen ? 80.0 : 100.0;
    final circleSize2 = isSmallScreen ? 100.0 : 120.0;
    final valueFontSize = isSmallScreen ? 14.0 : (isMediumScreen ? 15.0 : 16.0);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: horizontalMargin,
        vertical: verticalMargin,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primary1,
            primary2,
            primary3,
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: red.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned(
            left: -20,
            top: -20,
            child: Container(
              width: circleSize,
              height: circleSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            right: -30,
            bottom: -30,
            child: Container(
              width: circleSize2,
              height: circleSize2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.07),
              ),
            ),
          ),
          // Content
          Padding(
            padding: EdgeInsets.all(containerPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(),
                    Container(
                      padding: EdgeInsets.only(
                        right: isSmallScreen ? 6.0 : 8.0,
                        left: isSmallScreen ? 6.0 : 8.0,
                        bottom: isSmallScreen ? 6.0 : 8.0,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.directions_car,
                        color: Colors.white,
                        size: iconSize,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        'معلومات المركبة',
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 12,
                ),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: size.width * 0.02,
                  runSpacing: size.height * 0.008,
                  children: [
                    if (selectedBrand != null)
                      _buildInfoChipForSummary(
                        selectedBrand!,
                        valueFontSize,
                        isSmallScreen,
                      ),
                    if (selectedCategory != null)
                      _buildInfoChipForSummary(
                        selectedCategory!.categoryName,
                        valueFontSize,
                        isSmallScreen,
                      ),
                    if (selectedYear != null)
                      _buildInfoChipForSummary(
                        selectedYear!,
                        valueFontSize,
                        isSmallScreen,
                      ),
                    if (selectedFuelType != null)
                      _buildInfoChipForSummary(
                        selectedFuelType!,
                        valueFontSize,
                        isSmallScreen,
                      ),
                    if (selectedEngineSize != null &&
                        selectedEngineSize != "N/A" &&
                        selectedEngineSize!.isNotEmpty)
                      _buildInfoChipForSummary(
                        selectedEngineSize!,
                        valueFontSize,
                        isSmallScreen,
                      ),
                    if (selectedChassisNumber != null &&
                        selectedChassisNumber != "N/A" &&
                        selectedChassisNumber!.isNotEmpty)
                      _buildInfoChipForSummary(
                        'شاصي: ${selectedChassisNumber!}',
                        valueFontSize,
                        isSmallScreen,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChipForSummary(
    String value,
    double fontSize,
    bool isSmallScreen,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 10.0 : 12.0,
        vertical: isSmallScreen ? 6.0 : 8.0,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        value,
        style: TextStyle(
          fontFamily: 'Tajawal',
          fontSize: fontSize * 0.8,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          height: 1.2,
        ),
      ),
    );
  }



  Widget _buildSelectionContent() {
    if (isLoadingBrands && currentStep == 0) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(50),
          child: RotatingImagePage(),
        ),
      );
    }

    if (isLoadingCategories && currentStep == 1) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(50),
          child: RotatingImagePage(),
        ),
      );
    }

    switch (currentStep) {
      case 0:
        return _buildGridSelection(
          title: 'اختر نوع السيارة',
          items: brands,
          onSelected: _onBrandSelected,
          icon: Icons.directions_car,
        );
      case 1:
        return _buildCategoryGridSelection(
          title: 'اختر الفئة',
          categories: categories,
          onSelected: _onCategorySelected,
          icon: Icons.model_training,
        );

      case 2:
        return _buildListSelection(
          title: 'اختر سنة الصنع',
          items: years['default']!,
          onSelected: _onYearSelected,
          icon: Icons.calendar_today,
        );
      case 3:
        return _buildGridSelection(
          title: 'اختر نوع الوقود',
          items: fuelTypes,
          onSelected: _onFuelTypeSelected,
          icon: Icons.local_gas_station,
        );
      case 4:
        final provider = Provider.of<EngineSizeProvider>(context);
        if (provider.isLoading) {
          return Center(child: RotatingImagePage());
        } else if (provider.error.isNotEmpty) {
          return Center(child: Text(provider.error));
        } else {
          return Column(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedEngineSize = 'N/A';
                  });
                  // الانتقال لخطوة رقم الشاصي بدلاً من الخروج
                  _nextStep();
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [Colors.grey.shade300, Colors.grey.shade100],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: Colors.grey.shade400,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'تخطي',
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _buildGridSelection(
                title: 'اختر حجم المحرك',
                items: provider.engineSizes,
                onSelected: _onEngineSizeSelected,
                icon: Icons.settings,
              ),
            ],
          );
        }

      case 5:
        return _buildChassisNumberInput();

      default:
        return const SizedBox();
    }
  }

  Widget _buildChassisNumberInput() {

    final bool isChassisRequired = selectedCategory?.isChassisRequired ?? false;
    final String titleText =
        isChassisRequired ? 'رقم الشاصي (إجباري)' : 'رقم الشاصي (اختياري)';

    return FadeTransition(
      opacity: _cardAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.15),
          end: Offset.zero,
        ).animate(_cardAnimation),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Text(
                titleText,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isChassisRequired ? red : Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                height: 60,
                color: grey,
                child: TextField(
                  controller: chassisController,
                  maxLength: 17,
                  maxLines: 1,
                  textCapitalization: TextCapitalization.characters,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    counterText: "",
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: bor, width: 2),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: focusedColor, width: 2),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: bor, width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    fillColor: grey,
                    filled: true,
                    hintText: hint,
                    hintStyle: TextStyle(
                      color: green,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                      fontFamily: "Tajawal",
                    ),
                  ),
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  onChanged: (value) {
                    count = value.length;
                    if (value.length == 17 && !value.contains(" ")) {
                      setState(() {
                        focusedColor = green;
                        bor = green;
                      });
                    } else {
                      setState(() {
                        focusedColor = red;
                        bor = red;
                      });
                    }
                  },
                  onTap: () {
                    setState(() {
                      hint = "";
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  // زر "تخطي" - يظهر فقط إذا رقم الشاصي مش إجباري
                  if (!isChassisRequired) ...[
                    Expanded(
                      child: GestureDetector(
                        onTap: _skipChassisNumber,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              colors: [
                                Colors.grey.shade300,
                                Colors.grey.shade100
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(
                              color: Colors.grey.shade400,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              'تخطي',
                              style: TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                  ],
                  // زر "حفظ"
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (isChassisRequired &&
                            chassisController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Center(
                                child: Text(
                                  'رقم الشاصي إجباري لهذه الفئة',
                                  style: TextStyle(
                                    fontFamily: 'Tajawal',
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              backgroundColor: red,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                          return;
                        }
                        _onChassisNumberEntered(chassisController.text);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            colors: [primary1, primary2, primary3],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: green.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'حفظ',
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryGridSelection({
    required String title,
    required List<CategoryModel> categories,
    required Function(CategoryModel) onSelected,
    required IconData icon,
  }) {
    List<CategoryModel> filteredCategories = categories;

    return FadeTransition(
      opacity: _cardAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.15),
          end: Offset.zero,
        ).animate(_cardAnimation),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              StatefulBuilder(
                builder: (context, setStateSearch) {
                  return Column(
                    children: [
                      filteredCategories.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(40),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 60,
                                    color: Colors.grey.shade300,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'لا توجد نتائج',
                                    style: TextStyle(
                                      fontFamily: 'Tajawal',
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 2.5,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                              ),
                              itemCount: filteredCategories.length,
                              itemBuilder: (context, index) {
                                return _buildCategoryGridItem(
                                  filteredCategories[index],
                                  onSelected,
                                  index,
                                );
                              },
                            ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryGridItem(
      CategoryModel category, Function(CategoryModel) onSelected, int index) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onSelected(category),
        borderRadius: BorderRadius.circular(16),
        splashColor: red.withOpacity(0.2),
        highlightColor: red.withOpacity(0.1),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white,
                Colors.grey.shade50,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey.shade200,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: red.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: 1,
              ),
            ],
          ),
          child: Center(
            child: Text(
              category.categoryName,
              style: const TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                letterSpacing: 0.3,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGridSelection({
    required String title,
    required List<String> items,
    required Function(String) onSelected,
    required IconData icon,
  }) {
    List<String> filteredItems = items;
    return FadeTransition(
      opacity: _cardAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.15),
          end: Offset.zero,
        ).animate(_cardAnimation),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              StatefulBuilder(
                builder: (context, setStateSearch) {
                  return Column(
                    children: [
                      filteredItems.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(40),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 60,
                                    color: Colors.grey.shade300,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'لا توجد نتائج',
                                    style: TextStyle(
                                      fontFamily: 'Tajawal',
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 2.5,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                              ),
                              itemCount: filteredItems.length,
                              itemBuilder: (context, index) {
                                return _buildGridItem(
                                  filteredItems[index],
                                  onSelected,
                                  index,
                                );
                              },
                            ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListSelection({
    required String title,
    required List<String> items,
    required Function(String) onSelected,
    required IconData icon,
  }) {
    final ScrollController scrollController = ScrollController();

    return FadeTransition(
      opacity: _cardAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            StatefulBuilder(
              builder: (context, setStateSearch) {
                return Column(
                  children: [
                    items.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(40),
                            child: Column(
                              children: [
                                Icon(Icons.search_off,
                                    size: 60, color: Colors.grey.shade300),
                                const SizedBox(height: 16),
                                Text(
                                  'لا توجد نتائج',
                                  style: TextStyle(
                                    fontFamily: 'Tajawal',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Container(
                            width: double.infinity,
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            height: 400,
                            // ثبت الارتفاع بدلاً من constraints
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: red.withOpacity(0.08),
                                  blurRadius: 15,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                              border: Border.all(
                                  color: Colors.grey.shade200, width: 1.5),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: ListView.separated(
                                controller: scrollController,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                itemCount: items.length,
                                separatorBuilder: (context, index) => Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: Colors.grey.shade200,
                                  indent: 16,
                                  endIndent: 16,
                                ),
                                itemBuilder: (context, index) {
                                  return InkWell(
                                    onTap: () => onSelected(items[index]),
                                    splashColor: red.withOpacity(0.1),
                                    highlightColor: red.withOpacity(0.05),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 18,
                                      ),
                                      child: Center(
                                        child: Text(
                                          items[index],
                                          style: const TextStyle(
                                            fontFamily: 'Tajawal',
                                            fontSize: 17,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridItem(String item, Function(String) onSelected, int index) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onSelected(item),
        borderRadius: BorderRadius.circular(16),
        splashColor: red.withOpacity(0.2),
        highlightColor: red.withOpacity(0.1),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white,
                Colors.grey.shade50,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey.shade200,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: red.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: 1,
              ),
            ],
          ),
          child: Center(
            child: Text(
              item,
              style: const TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                letterSpacing: 0.3,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.17,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomRight,
                  end: Alignment.topLeft,
                  colors: [primary1, primary2, primary3],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  CustomText(
                    text: "إضافة معلومات المركبة",
                    color: Colors.white,
                    size: 20,
                    weight: FontWeight.bold,
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            _buildProgressBar(),
            _buildSummaryCard(),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  const SizedBox(height: 25),
                  _buildSelectionContent(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
