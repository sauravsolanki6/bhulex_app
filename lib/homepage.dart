import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart'
    show CachedNetworkImage;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import 'Core/apputility.dart';
import 'E-Applications/aapli_chawadi_page.dart';
import 'E-Applications/area_converter_page.dart';
import 'E-Applications/e_property_valuation_page.dart';
import 'My_package/package_details_new.dart';
import 'Order/all_order.dart';
import 'Order/all_packages.dart';
import 'Order/order_list.dart';
import 'Order/package_details.dart';
import 'colors/custom_color.dart';
import 'colors/order_fonts.dart';
import 'controller/GlobalControllers/state_controller.dart';
import 'controller/order/language controller.dart';
import 'controller/package/getallpackagecontroller.dart' show PackageController;
import 'controller/package/my_package_controller.dart';
import 'customfiles/bottom_navigation_controller.dart';
import 'investigate_reports_form/cersai_report.dart';
import 'investigate_reports_form/mortage_report.dart';
import 'investigate_reports_form/registered_document.dart';
import 'investigate_reports_form/rera builder.dart';
import 'language/hindi.dart';
import 'legal_advisory_forms/adhikar_abhilekh.dart';
import 'legal_advisory_forms/courtcases.dart';
import 'legal_advisory_forms/investigate.dart';
import 'legal_advisory_forms/legal_drafts_new.dart';
import 'legal_advisory_forms/legaldrafts.dart';
import 'network/url.dart';
import 'old_records_form/old extract1.dart';
import 'old_records_form/old_revenue_records.dart';
import 'profile/profile.dart';
import 'quicke_services_forms/digitally_sign1.dart';
import 'quicke_services_forms/digitally_sign_property_card.dart';
import 'quicke_services_forms/indexII_search.dart';
import 'quicke_services_forms/rera_certificate.dart';

class HomePage2 extends StatefulWidget {
  final String? package;
  final String customer_id;
  final String? packageid;
  const HomePage2({
    super.key,
    this.package,
    required this.customer_id,
    this.packageid,
    required String customerId,
  });

  @override
  State<HomePage2> createState() => _HomePage2State();
}

class _HomePage2State extends State<HomePage2> {
  List<dynamic> categoryList = [];
  String iconPath = '';
  String customerName = '';
  final String customer_id = '';

  bool isLoading = true;
  List<dynamic> customerList = [];
  String? selectedState;
  int _selectedIndex = 0;
  bool isToggled = false;
  bool hasConnection = true;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  final BottomNavigationController controller =
      Get.find<BottomNavigationController>();
  final PackageController packageController = Get.put(PackageController());
  final LanguageController languageController = Get.put(LanguageController());
  final StateController stateController = Get.put(StateController());
  final Map<String, String> instantTextMap = {
    'Quick Services': 'instant',
    'Old Records of Rights': 'within12Hours',
    'Legal Advisory': 'within12Hours',
    'Investigative Reports': 'within24Hours',
    'E-Applications': 'within12Hours',
  };

  @override
  void initState() {
    super.initState();
    _loadToggleState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initConnectivity();
    });
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadToggleState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isToggled = prefs.getBool('isToggled') ?? false;
      languageController.isToggled.value = isToggled;
    });
    fetchCategories();
  }

  Future<void> _saveToggleState(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isToggled', value);
    setState(() {
      isToggled = value;
      languageController.isToggled.value = value;
    });
  }

  void _initConnectivity() {
    _checkConnectivity().then((isConnected) {
      if (!mounted) return;
      setState(() {
        hasConnection = isConnected;
      });
      if (isConnected) {
        fetchCategories();
      }
    });

    // _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
    //   (ConnectivityResult result) {
    //     _checkConnectivity().then((isConnected) {
    //       if (!mounted) return;
    //       if (isConnected != hasConnection) {
    //         setState(() {
    //           hasConnection = isConnected;
    //         });
    //         if (isConnected) {
    //           fetchCategories();
    //         }
    //       }
    //     });
    //   },
    // );
  }

  Future<bool> _checkConnectivity() async {
    try {
      var connectivityResult = await Connectivity().checkConnectivity();
      bool isConnected = connectivityResult != ConnectivityResult.none;
      if (isConnected) {
        isConnected = await _hasInternet();
      }
      return isConnected;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _hasInternet() async {
    try {
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  void _showNoInternetPopup() {
    if (!mounted) return;
    _scaffoldMessengerKey.currentState?.removeCurrentSnackBar();
    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(
          languageController.isToggled.value
              ? 'इंटरनेट कनेक्शन नाही'
              : 'No Internet Connection',
          style: AppFontStyle2.blinker(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label:
              languageController.isToggled.value ? 'पुन्हा प्रयत्न' : 'Retry',
          textColor: Colors.white,
          onPressed: () async {
            bool isConnected = await _checkConnectivity();
            if (!mounted) return;
            setState(() {
              hasConnection = isConnected;
            });
            if (isConnected) {
              fetchCategories();
            } else {
              _showNoInternetPopup();
            }
          },
        ),
      ),
    );
  }

  Future<void> fetchCategories() async {
    if (!hasConnection) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? customerId = prefs.getString('customer_id');
    var requestBody = {
      "customer_id": customerId,
      "lang": languageController.isToggled.value ? 'mr' : 'en',
    };

    final String url = URLS().get_all_category_apiUrl;

    // Print the request URL and body
    print("Request URL: $url");
    print("Request Body: ${jsonEncode(requestBody)}");

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(requestBody),
      );

      // Print the raw response
      print("Response Status Code: ${response.statusCode}");
      log("Response Body of category: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        setState(() {
          categoryList = responseData['data'] ?? [];
          iconPath = responseData['icon_path'] ?? '';
          isLoading = false;
        });
      } else {
        print(
          "Error: Server responded with status code ${response.statusCode}",
        );
      }
    } catch (e) {
      print("Error fetching categories: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _onRefresh() async {
    if (!hasConnection) {
      _showNoInternetPopup();
      return;
    }
    await fetchCategories();
    await Get.find<PackageOrderController>().fetchPackageOrders(
      customerId: widget.customer_id,
      customOffset: 0,
      isToggled: Get.find<LanguageController>().isToggled.value,
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        print("Home tapped");
        break;
      case 1:
        print("Customer Care tapped");
        break;
      case 2:
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) =>
        //         const MyOrderScreen(package_id: '', customer_id: ''),
        //   ),
        // );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const OrderCardsPage(),
          ),
        );
        break;

      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ProfilePage(isToggled: languageController.isToggled.value),
          ),
        );
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PackageScreen(
              customerId: '',
              package_id: '',
              customerid: '',
            ),
          ),
        );

        break;
    }
  }

  Future<bool> _showExitDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Obx(
              () => Text(
                languageController.isToggled.value
                    ? 'साठवलेला डेटा नष्ट होईल'
                    : 'Unsaved Data Will Be Lost',
                style: AppFontStyle2.blinker(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            content: Obx(
              () => Text(
                languageController.isToggled.value
                    ? 'आपण खात्रीने बाहेर पडू इच्छिता?'
                    : 'Are you sure you want to exit?',
                style: AppFontStyle2.blinker(fontSize: 16),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Obx(
                  () => Text(
                    languageController.isToggled.value ? 'रद्द करा' : 'Cancel',
                    style: AppFontStyle2.blinker(color: Colors.grey),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => SystemNavigator.pop(),
                child: Obx(
                  () => Text(
                    languageController.isToggled.value ? 'होय' : 'Yes',
                    style: AppFontStyle2.blinker(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => await _showExitDialog(context),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F8F8),
        appBar: AppBar(
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          elevation: 0,
          title: Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 10),
            child: Image.asset('assets/images/bhulexlogo.png', height: 40),
          ),
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1.0),
            child: Divider(
              height: 1,
              thickness: 1,
              color: Color(0xFFD9D9D9),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(top: 8.0, right: 8.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 60,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Obx(
                          () => CupertinoSwitch(
                            value: languageController.isToggled.value,
                            onChanged: (bool newValue) {
                              languageController.toggleLanguage(newValue);
                              _saveToggleState(newValue);
                              setState(() {
                                fetchCategories();
                              });
                            },
                            activeColor: const Color(0xFFF57C00),
                            trackColor: Colors.grey[300],
                            thumbColor: Colors.white,
                          ),
                        ),
                        Obx(
                          () => !languageController.isToggled.value
                              ? const Positioned(
                                  left: 15,
                                  child: Text(
                                    'A',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black,
                                    ),
                                  ),
                                )
                              : const Positioned(
                                  top: 10,
                                  right: 15,
                                  child: Text(
                                    'अ',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0, right: 8.0),
              child: IconButton(
                icon: const Icon(
                  Icons.search,
                  size: 30,
                  color: Colors.black,
                ),
                onPressed: () {
                  print('Search icon pressed');
                },
              ),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _onRefresh,
          child: isLoading
              ? ListView.builder(
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Container(height: 150, color: Colors.white),
                      ),
                    );
                  },
                )
              : !hasConnection
                  ? SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 20),
                            Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 30.0,
                                vertical: 10.0,
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red, width: 1),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.cancel,
                                      color: Colors.red, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    languageController.isToggled.value
                                        ? 'इंटरनेट नाही'
                                        : 'No Internet',
                                    style: AppFontStyle2.blinker(
                                      fontSize: 14,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Obx(
                              () => Text(
                                languageController.isToggled.value
                                    ? 'कोणताही डेटा उपलब्ध नाही'
                                    : 'No data available',
                                style: AppFontStyle2.blinker(
                                  fontSize: 16,
                                  color: Colorfile.lightblack,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Obx(() => stateController.isLoading.value
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : Obx(() {
                                    final isSelected = stateController
                                        .selectedStateName.value.isNotEmpty;
                                    final borderColor = isSelected
                                        ? Color(0xFFF26500)
                                        : Color(0xFFD9D9D9);

                                    return DropdownSearch<String>(
                                      items: stateController.states
                                          .map((state) => state.stateName)
                                          .toList(),
                                      selectedItem: isSelected
                                          ? stateController
                                              .selectedStateName.value
                                          : null,
                                      dropdownDecoratorProps:
                                          DropDownDecoratorProps(
                                        dropdownSearchDecoration:
                                            InputDecoration(
                                          labelText:
                                              languageController.isToggled.value
                                                  ? 'राज्य निवडा'
                                                  : 'Select State',
                                          labelStyle: AppFontStyle2.blinker(
                                            color: Colors.black,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 14,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            borderSide: BorderSide(
                                              color: borderColor,
                                              width: 1,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            borderSide: BorderSide(
                                              color: borderColor,
                                              width: 1,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            borderSide: BorderSide(
                                              color: borderColor,
                                              width: 1,
                                            ),
                                          ),
                                          disabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            borderSide: BorderSide(
                                              color: borderColor,
                                              width: 1,
                                            ),
                                          ),
                                        ),
                                      ),
                                      popupProps: const PopupProps.menu(
                                        showSearchBox: true,
                                        searchFieldProps: TextFieldProps(
                                          decoration: InputDecoration(
                                            hintText: 'Search State...',
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                      onChanged: (value) {
                                        stateController.setSelectedState(value);
                                      },
                                    );
                                  })),
                          ),
                          ...categoryList.map((category) {
                            var services = category['service'] ?? [];
                            return Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Obx(
                                          () => Text(
                                            languageController.isToggled.value
                                                ? (category[
                                                        'category_name_in_local_language'] ??
                                                    category['category_name'] ??
                                                    '')
                                                : (category['category_name'] ??
                                                    ''),
                                            style: AppFontStyle2.blinker(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            child: Container(
                                              height: 1,
                                              color: const Color(0xFF757575),
                                            ),
                                          ),
                                        ),
                                        Obx(
                                          () => Text(
                                            LocalizationStringsinstant
                                                .getString(
                                              instantTextMap[category[
                                                      'category_name']] ??
                                                  '',
                                              languageController
                                                  .isToggled.value,
                                            ),
                                            style: AppFontStyle2.blinker(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w400,
                                              color: Colorfile.lightgrey,
                                            ),
                                            textAlign: TextAlign.end,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  GridView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: services.length,
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 4,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10,
                                      childAspectRatio: 1.4,
                                    ),
                                    itemBuilder: (context, serviceIndex) {
                                      var service = services[serviceIndex];
                                      String serviceIcon =
                                          service['icon'] != null
                                              ? iconPath + service['icon']
                                              : '';
                                      return Obx(() {
                                        String displayName = languageController
                                                .isToggled.value
                                            ? (service[
                                                    'service_name_in_local_language'] ??
                                                service['service_name'] ??
                                                '')
                                            : (service['service_name'] ?? '');
                                        return InkWell(
                                          onTap: () {
                                            var selectedService =
                                                services[serviceIndex];
                                            final id = selectedService['id']
                                                .toString();
                                            final serviceName = selectedService[
                                                    'service_name'] ??
                                                '';
                                            final tblName =
                                                selectedService['tbl_name'] ??
                                                    '';
                                            if ([
                                              "tbl_seven_twelve",
                                              "tbl_eighta_extract",
                                              "tbl_e_mutation_extract",
                                              "tbl_bhu_naksha",
                                            ].contains(tblName)) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      DigitallySign1(
                                                    id: id,
                                                    packageId: "",
                                                    serviceName: serviceName,
                                                    tblName: tblName,
                                                    isToggled:
                                                        languageController
                                                            .isToggled.value,
                                                    serviceNameInLocalLanguage:
                                                        selectedService[
                                                                'service_name_in_local_language'] ??
                                                            serviceName,
                                                    lead_id: '',
                                                    customer_id: '',
                                                    package_lead_id: '',
                                                  ),
                                                ),
                                              );
                                            } else if ([
                                              "tbl_index_second_search",
                                            ].contains(tblName)) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      IndexSearch1(
                                                    id: id,
                                                    packageId: "",
                                                    serviceName: serviceName,
                                                    tblName: tblName,
                                                    isToggled:
                                                        languageController
                                                            .isToggled.value,
                                                    serviceNameInLocalLanguage:
                                                        selectedService[
                                                                'service_name_in_local_language'] ??
                                                            serviceName,
                                                    lead_id: '',
                                                    customer_id:
                                                        widget.customer_id,
                                                    package_lead_id: '',
                                                  ),
                                                ),
                                              );
                                            } else if ([
                                              "tbl_rera_certificate",
                                            ].contains(tblName)) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (
                                                    context,
                                                  ) =>
                                                      ReraCertificate(
                                                    id: id,
                                                    packageId: "",
                                                    serviceName: serviceName,
                                                    tblName: tblName,
                                                    isToggled:
                                                        languageController
                                                            .isToggled.value,
                                                    serviceNameInLocalLanguage:
                                                        selectedService[
                                                                'service_name_in_local_language'] ??
                                                            serviceName,
                                                    lead_id: '',
                                                    customer_id: '',
                                                    package_lead_id: '',
                                                  ),
                                                ),
                                              );
                                            } else if ([
                                              "tbl_property_card",
                                            ].contains(tblName)) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      propertyCard(
                                                    id: id,
                                                    packageId: "",
                                                    serviceName: serviceName,
                                                    tblName: tblName,
                                                    isToggled:
                                                        languageController
                                                            .isToggled.value,
                                                    serviceNameInLocalLanguage:
                                                        selectedService[
                                                                'service_name_in_local_language'] ??
                                                            serviceName,
                                                    package_lead_id: '',
                                                    lead_id: '',
                                                    customer_id: '',
                                                  ),
                                                ),
                                              );
                                            } else if ([
                                              "tbl_old_seven_twelve",
                                              "tbl_old_eighta_extract",
                                              "tbl_old_e_mutation_extract",
                                            ].contains(tblName)) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      oldextract1(
                                                    id: id,
                                                    packageId: "",
                                                    serviceName: serviceName,
                                                    tblName: tblName,
                                                    isToggled:
                                                        languageController
                                                            .isToggled.value,
                                                    serviceNameInLocalLanguage:
                                                        selectedService[
                                                                'service_name_in_local_language'] ??
                                                            serviceName,
                                                    lead_id: '',
                                                    customer_id: '',
                                                    package_lead_id: '',
                                                  ),
                                                ),
                                              );
                                            } else if ([
                                              "tbl_old_bhu_naksha",
                                            ].contains(tblName)) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      OldRevenueRecords(
                                                    id: id,
                                                    packageId: "",
                                                    serviceName: serviceName,
                                                    tblName: tblName,
                                                    isToggled:
                                                        languageController
                                                            .isToggled.value,
                                                    serviceNameInLocalLanguage:
                                                        selectedService[
                                                                'service_name_in_local_language'] ??
                                                            serviceName,
                                                    lead_id: '',
                                                    customer_id: '',
                                                    package_lead_id: '',
                                                  ),
                                                ),
                                              );
                                            } else if ([
                                              "tbl_mortage_report",
                                            ].contains(tblName)) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (
                                                    context,
                                                  ) =>
                                                      MortgageReports(
                                                    id: id,
                                                    packageId: "",
                                                    serviceName: serviceName,
                                                    tblName: tblName,
                                                    isToggled:
                                                        languageController
                                                            .isToggled.value,
                                                    serviceNameInLocalLanguage:
                                                        selectedService[
                                                                'service_name_in_local_language'] ??
                                                            serviceName,
                                                    lead_id: '',
                                                    customer_id: '',
                                                    package_lead_id: '',
                                                  ),
                                                ),
                                              );
                                            } else if ([
                                              "tbl_ceersai_report",
                                            ].contains(tblName)) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (
                                                    context,
                                                  ) =>
                                                      CersaiReport(
                                                    id: id,
                                                    packageId: "",
                                                    serviceName: serviceName,
                                                    tblName: tblName,
                                                    isToggled:
                                                        languageController
                                                            .isToggled.value,
                                                    serviceNameInLocalLanguage:
                                                        selectedService[
                                                                'service_name_in_local_language'] ??
                                                            serviceName,
                                                    lead_id: '',
                                                    customer_id: '',
                                                    package_lead_id: '',
                                                  ),
                                                ),
                                              );
                                            } else if ([
                                              "tbl_rera_builder_documents",
                                            ].contains(tblName)) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      RERA_Builder(
                                                    id: id,
                                                    packageId: "",
                                                    serviceName: serviceName,
                                                    tblName: tblName,
                                                    isToggled:
                                                        languageController
                                                            .isToggled.value,
                                                    serviceNameInLocalLanguage:
                                                        selectedService[
                                                                'service_name_in_local_language'] ??
                                                            serviceName,
                                                    customer_id: '',
                                                    lead_id: '',
                                                    package_lead_id: '',
                                                  ),
                                                ),
                                              );
                                            } else if ([
                                              "tbl_registered_document",
                                            ].contains(tblName)) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (
                                                    context,
                                                  ) =>
                                                      RegisteredDocument(
                                                    id: id,
                                                    packageId: "",
                                                    serviceName: serviceName,
                                                    tblName: tblName,
                                                    isToggled:
                                                        languageController
                                                            .isToggled.value,
                                                    serviceNameInLocalLanguage:
                                                        selectedService[
                                                                'service_name_in_local_language'] ??
                                                            serviceName,
                                                    lead_id: '',
                                                    customer_id: '',
                                                    package_lead_id: '',
                                                  ),
                                                ),
                                              );
                                            } else if ([
                                              "tbl_title_investigation_report",
                                            ].contains(tblName)) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      Investigation(
                                                    id: id,
                                                    packageId: "",
                                                    serviceName: serviceName,
                                                    tblName: tblName,
                                                    isToggled:
                                                        languageController
                                                            .isToggled.value,
                                                    serviceNameInLocalLanguage:
                                                        selectedService[
                                                                'service_name_in_local_language'] ??
                                                            serviceName,
                                                    customer_id: '',
                                                    lead_id: '',
                                                    package_lead_id: '',
                                                  ),
                                                ),
                                              );
                                            } else if ([
                                              "tbl_legal_drafts",
                                            ].contains(tblName)) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      LegalDraftsNew(
                                                    id: id,
                                                    packageId: "",
                                                    serviceName: serviceName,
                                                    tblName: tblName,
                                                    isToggled:
                                                        languageController
                                                            .isToggled.value,
                                                    serviceNameInLocalLanguage:
                                                        selectedService[
                                                                'service_name_in_local_language'] ??
                                                            serviceName,
                                                    lead_id: '',
                                                    customer_id: '',
                                                    package_lead_id: '',
                                                  ),
                                                ),
                                              );
                                            } else if (["tbl_court_cases"]
                                                .contains(tblName)) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      Courtcases(
                                                    id: id,
                                                    packageId: "",
                                                    serviceName: serviceName,
                                                    tblName: tblName,
                                                    isToggled:
                                                        languageController
                                                            .isToggled.value,
                                                    serviceNameInLocalLanguage:
                                                        selectedService[
                                                                'service_name_in_local_language'] ??
                                                            serviceName,
                                                    lead_id: '',
                                                    customer_id: '',
                                                    package_lead_id: '',
                                                  ),
                                                ),
                                              );
                                            } else if (["tbl_adhikar_abhilekh"]
                                                .contains(tblName)) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (
                                                    context,
                                                  ) =>
                                                      Adhikar_Abhilekh(
                                                    id: id,
                                                    packageId: "",
                                                    serviceName: serviceName,
                                                    tblName: tblName,
                                                    isToggled:
                                                        languageController
                                                            .isToggled.value,
                                                    serviceNameInLocalLanguage:
                                                        selectedService[
                                                                'service_name_in_local_language'] ??
                                                            serviceName,
                                                    lead_id: '',
                                                    customerid: customer_id,
                                                    package_lead_id: '',
                                                  ),
                                                ),
                                              );
                                            } else {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Obx(
                                                    () => Text(
                                                      languageController
                                                              .isToggled.value
                                                          ? "या निवडीसाठी सेवा उपलब्ध नाही."
                                                          : "Service not available for this selection.",
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              serviceIcon.isNotEmpty
                                                  ? Image.network(
                                                      serviceIcon,
                                                      height: 25,
                                                      width: 25,
                                                      fit: BoxFit.contain,
                                                      errorBuilder:
                                                          (ctx, _, __) =>
                                                              const Icon(
                                                        Icons.broken_image,
                                                        size: 25,
                                                      ),
                                                    )
                                                  : const Icon(
                                                      Icons
                                                          .miscellaneous_services,
                                                      size: 30,
                                                    ),
                                              const SizedBox(height: 5),
                                              Text(
                                                displayName,
                                                style: AppFontStyle2.blinker(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w600,
                                                  height: 12 / 9,
                                                  color: Colorfile.servicename,
                                                ),
                                                textAlign: TextAlign.center,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        );
                                      });
                                    },
                                  ),
                                ],
                              ),
                            );
                          }),
                          // Dummy Category Section
                          // Dummy Category Section
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Obx(
                                        () => Text(
                                          languageController.isToggled.value
                                              ? dummyCategory[
                                                  'category_name_in_local_language']
                                              : dummyCategory['category_name'],
                                          style: AppFontStyle2.blinker(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                          child: Container(
                                            height: 1,
                                            color: const Color(0xFF757575),
                                          ),
                                        ),
                                      ),
                                      Text(
                                        'Within 12 hours',
                                        style: AppFontStyle2.blinker(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w400,
                                          color: Colorfile.lightgrey,
                                        ),
                                        textAlign: TextAlign.end,
                                      )
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: dummyCategory['service'].length,
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                    childAspectRatio: 1.4,
                                  ),
                                  itemBuilder: (context, serviceIndex) {
                                    var service =
                                        dummyCategory['service'][serviceIndex];
                                    String serviceIcon = service['icon'] ?? '';
                                    return Obx(() {
                                      String displayName = languageController
                                              .isToggled.value
                                          ? (service[
                                                  'service_name_in_local_language'] ??
                                              service['service_name'] ??
                                              '')
                                          : (service['service_name'] ?? '');
                                      return InkWell(
                                        onTap: () {
                                          final id = service['id'].toString();
                                          final serviceName =
                                              service['service_name'] ?? '';
                                          final tblName =
                                              service['tbl_name'] ?? '';
                                          final serviceNameInLocalLanguage =
                                              service['service_name_in_local_language'] ??
                                                  serviceName;

                                          // Navigation logic based on tbl_name
                                          switch (tblName) {
                                            case "tbl_e_property_valuation":
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      EPropertyValuationPage(
                                                    id: id,
                                                    packageId: "",
                                                    serviceName: serviceName,
                                                    tblName: tblName,
                                                    isToggled:
                                                        languageController
                                                            .isToggled.value,
                                                    serviceNameInLocalLanguage:
                                                        serviceNameInLocalLanguage,
                                                    lead_id: '',
                                                    customer_id:
                                                        widget.customer_id,
                                                    package_lead_id: '',
                                                  ),
                                                ),
                                              );
                                              break;
                                            case "tbl_aapli_chawadi":
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      AapliChawadiPage(
                                                    id: id,
                                                    packageId: "",
                                                    serviceName: serviceName,
                                                    tblName: tblName,
                                                    isToggled:
                                                        languageController
                                                            .isToggled.value,
                                                    serviceNameInLocalLanguage:
                                                        serviceNameInLocalLanguage,
                                                    lead_id: '',
                                                    customer_id:
                                                        widget.customer_id,
                                                    package_lead_id: '',
                                                  ),
                                                ),
                                              );
                                              break;
                                            case "tbl_area_converter":
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      AreaConverterPage(
                                                    id: id,
                                                    packageId: "",
                                                    serviceName: serviceName,
                                                    tblName: tblName,
                                                    isToggled:
                                                        languageController
                                                            .isToggled.value,
                                                    serviceNameInLocalLanguage:
                                                        serviceNameInLocalLanguage,
                                                    lead_id: '',
                                                    customer_id:
                                                        widget.customer_id,
                                                    package_lead_id: '',
                                                  ),
                                                ),
                                              );
                                              break;
                                            case "tbl_property_mutation":
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      DigitallySign1(
                                                    id: id,
                                                    packageId: "",
                                                    serviceName: serviceName,
                                                    tblName: tblName,
                                                    isToggled:
                                                        languageController
                                                            .isToggled.value,
                                                    serviceNameInLocalLanguage:
                                                        serviceNameInLocalLanguage,
                                                    lead_id: '',
                                                    customer_id:
                                                        widget.customer_id,
                                                    package_lead_id: '',
                                                  ),
                                                ),
                                              );
                                              break;
                                            default:
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Obx(
                                                    () => Text(
                                                      languageController
                                                              .isToggled.value
                                                          ? "या निवडीसाठी सेवा उपलब्ध नाही."
                                                          : "Service not available for this selection.",
                                                    ),
                                                  ),
                                                ),
                                              );
                                          }
                                        },
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            serviceIcon.isNotEmpty
                                                ? Image.asset(
                                                    serviceIcon,
                                                    height: 25,
                                                    width: 25,
                                                    fit: BoxFit.contain,
                                                    errorBuilder:
                                                        (ctx, _, __) =>
                                                            const Icon(
                                                      Icons.broken_image,
                                                      size: 25,
                                                    ),
                                                  )
                                                : const Icon(
                                                    Icons
                                                        .miscellaneous_services,
                                                    size: 30,
                                                  ),
                                            const SizedBox(height: 5),
                                            Text(
                                              displayName,
                                              style: AppFontStyle2.blinker(
                                                fontSize: 9,
                                                fontWeight: FontWeight.w600,
                                                height: 12 / 9,
                                                color: Colorfile.servicename,
                                              ),
                                              textAlign: TextAlign.center,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      );
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 18,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Obx(
                                  () => Text(
                                    languageController.isToggled.value
                                        ? 'पॅकेजेस'
                                        : 'Packages',
                                    style: AppFontStyle2.blinker(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colorfile.lightblack,
                                    ),
                                  ),
                                ),
                                Obx(
                                  () => TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              AllPackagesPage(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      languageController.isToggled.value
                                          ? 'सर्व पहा'
                                          : 'View All',
                                      style: AppFontStyle2.blinker(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: Colorfile.bordertheme,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Obx(
                            () => packageController.isLoading.value
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.only(
                                      left: 15.0,
                                      right: 20,
                                      bottom: 15,
                                    ),
                                    child: SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                                      0.25 >
                                                  200
                                              ? 200
                                              : MediaQuery.of(
                                                    context,
                                                  ).size.height *
                                                  0.25,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: packageController
                                                .allPackages.length +
                                            (packageController
                                                    .isLoadingMore.value
                                                ? 1
                                                : 0),
                                        itemBuilder: (context, index) {
                                          if (index ==
                                                  packageController
                                                      .allPackages.length &&
                                              packageController
                                                  .isLoadingMore.value) {
                                            return const Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                            );
                                          }

                                          final package = packageController
                                              .allPackages[index];
                                          if (package.packages.isEmpty) {
                                            return const SizedBox.shrink();
                                          }

                                          return Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        PackageDetailsPage(
                                                      package_id: package
                                                          .packages.first.id,
                                                      customer_id:
                                                          AppUtility.login_id,
                                                      isToggled: isToggled,
                                                      lead_id: '',
                                                    ),
                                                  ),
                                                );
                                                print(
                                                  "Tapped on: ${package.packages.first.packageName}",
                                                );
                                              },
                                              child: Container(
                                                width: MediaQuery.of(
                                                              context,
                                                            ).size.width *
                                                            0.8 >
                                                        290
                                                    ? 290
                                                    : MediaQuery.of(
                                                          context,
                                                        ).size.width *
                                                        0.8,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  border: Border.all(
                                                    color: const Color(
                                                      0xFFE5E7EB,
                                                    ),
                                                    width: 0.5,
                                                  ),
                                                  color: Colors.white,
                                                ),
                                                child: SingleChildScrollView(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(
                                                          8.0,
                                                        ),
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                            50,
                                                          ),
                                                          child:
                                                              CachedNetworkImage(
                                                            imageUrl: packageController
                                                                    .baseUrl
                                                                    .value +
                                                                (package
                                                                        .packages
                                                                        .first
                                                                        .icon ??
                                                                    ''),
                                                            width: 40,
                                                            height: 40,
                                                            fit: BoxFit.cover,
                                                            placeholder: (
                                                              context,
                                                              url,
                                                            ) =>
                                                                const CircularProgressIndicator(),
                                                            errorWidget: (
                                                              context,
                                                              url,
                                                              error,
                                                            ) =>
                                                                Image.asset(
                                                              'assets/images/package1.png',
                                                              width: 40,
                                                              height: 40,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(
                                                          5.0,
                                                        ),
                                                        child: Obx(
                                                          () => Text(
                                                            languageController
                                                                    .isToggled
                                                                    .value
                                                                ? (package
                                                                            .packages
                                                                            .first
                                                                            .packageNameInLocalLanguage
                                                                            .isNotEmpty ??
                                                                        false
                                                                    ? package
                                                                        .packages
                                                                        .first
                                                                        .packageNameInLocalLanguage
                                                                    : PackageStrings
                                                                        .getPackageName(
                                                                        package
                                                                            .packages
                                                                            .first
                                                                            .packageName,
                                                                        true,
                                                                      ))
                                                                : package
                                                                    .packages
                                                                    .first
                                                                    .packageName,
                                                            style: AppFontStyle2
                                                                .blinker(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color:
                                                                  const Color(
                                                                0xFF353B43,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(height: 1),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                          horizontal: 8.0,
                                                        ),
                                                        child: Obx(
                                                          () => Text(
                                                            languageController
                                                                    .isToggled
                                                                    .value
                                                                ? (package
                                                                            .packages
                                                                            .first
                                                                            .shortDescriptionInLocalLanguage
                                                                            .isNotEmpty ??
                                                                        false
                                                                    ? package
                                                                        .packages
                                                                        .first
                                                                        .shortDescriptionInLocalLanguage
                                                                    : PackageStrings
                                                                        .getShortDescription(
                                                                        package
                                                                            .packages
                                                                            .first
                                                                            .shortDescription,
                                                                        true,
                                                                      ))
                                                                : package
                                                                    .packages
                                                                    .first
                                                                    .shortDescription,
                                                            style: AppFontStyle2
                                                                .blinker(
                                                              fontSize: 9,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              color:
                                                                  const Color(
                                                                0xFF4B5563,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(height: 5),
                                                      Wrap(
                                                        spacing: 6,
                                                        runSpacing: 6,
                                                        children: (package
                                                                    .packages
                                                                    .first
                                                                    .serviceNames ??
                                                                '')
                                                            .split(',')
                                                            .map((
                                                          serviceName,
                                                        ) {
                                                          return Obx(() {
                                                            String serviceNameText = languageController
                                                                    .isToggled
                                                                    .value
                                                                ? ((package.packages.first.serviceNamesLocal.isNotEmpty ??
                                                                            false) &&
                                                                        package.packages.first
                                                                                .serviceNamesLocal
                                                                                .split(
                                                                                  ',',
                                                                                )
                                                                                .length >
                                                                            (package.packages.first.serviceNames ??
                                                                                    '')
                                                                                .split(
                                                                                  ',',
                                                                                )
                                                                                .indexOf(
                                                                                  serviceName,
                                                                                )
                                                                    ? package
                                                                        .packages
                                                                        .first
                                                                        .serviceNamesLocal
                                                                        .split(
                                                                          ',',
                                                                        )[(package.packages.first.serviceNames ??
                                                                                '')
                                                                            .split(
                                                                              ',',
                                                                            )
                                                                            .indexOf(
                                                                              serviceName,
                                                                            )]
                                                                        .trim()
                                                                    : allPackageStrings
                                                                        .getServiceName(
                                                                        serviceName
                                                                            .trim(),
                                                                        true,
                                                                      ))
                                                                : allPackageStrings
                                                                    .getServiceName(
                                                                    serviceName
                                                                        .trim(),
                                                                    false,
                                                                  );

                                                            return Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                left: 7.0,
                                                              ),
                                                              child: Container(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .symmetric(
                                                                  horizontal: 8,
                                                                  vertical: 4,
                                                                ),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color:
                                                                      const Color(
                                                                    0xFFF5F4F1,
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                    5,
                                                                  ),
                                                                  border: Border
                                                                      .all(
                                                                    color:
                                                                        const Color(
                                                                      0xFFE5E7EB,
                                                                    ),
                                                                  ),
                                                                ),
                                                                child: Text(
                                                                  serviceNameText,
                                                                  style: AppFontStyle2
                                                                      .blinker(
                                                                    fontSize:
                                                                        12,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    color:
                                                                        const Color(
                                                                      0xFF757575,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          });
                                                        }).toList(),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFFFFFF),
            boxShadow: [
              BoxShadow(
                color: Color(0x14000000),
                offset: Offset(2, 0),
                blurRadius: 25,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Obx(
            () => BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.home),
                  label: BottomNavigationStrings.getString(
                    'home',
                    languageController.isToggled.value,
                  ),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.support_agent_outlined),
                  label: BottomNavigationStrings.getString(
                    'customerCare',
                    languageController.isToggled.value,
                  ),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.edit_document),
                  label: BottomNavigationStrings.getString(
                    'myOrder',
                    languageController.isToggled.value,
                  ),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.person),
                  label: BottomNavigationStrings.getString(
                    'myProfile',
                    languageController.isToggled.value,
                  ),
                ),
                // BottomNavigationBarItem(
                //   icon: Stack(
                //     alignment: Alignment.center,
                //     children: [
                //       Image.asset(
                //         'assets/images/packageicon.png',
                //         width: 21,
                //         height: 22,
                //       ),
                //     ],
                //   ),
                //   label: BottomNavigationStrings.getString(
                //     'Package',
                //     languageController.isToggled.value,
                //   ),
                // ),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: Colorfile.bordertheme,
              unselectedItemColor: Colorfile.lightgrey,
              onTap: _onItemTapped,
              showUnselectedLabels: true,
              showSelectedLabels: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
          ),
        ),
      ),
    );
  }
}

final Map<String, dynamic> dummyCategory = {
  "category_name": "E-Applications",
  "category_name_in_local_language": "मालमत्ता सेवा",
  "service": [
    {
      "id": "1",
      "service_name": "E-Property Valuation",
      "service_name_in_local_language": "ई-मालमत्ता मूल्यांकन",
      "icon": "assets/images/valuation.png",
      "tbl_name": "tbl_e_property_valuation"
    },
    {
      "id": "2",
      "service_name": "Aapli Chawadi",
      "service_name_in_local_language": "आपली चावडी",
      "icon": "assets/images/chawadi.png",
      "tbl_name": "tbl_aapli_chawadi"
    },
    {
      "id": "3",
      "service_name": "Area Converter",
      "service_name_in_local_language": "क्षेत्र परिवर्तक",
      "icon": "assets/images/area_converter.png",
      "tbl_name": "tbl_area_converter"
    }
  ]
};

class LocalizationStringsinstant {
  static String getString(String key, bool isToggled) {
    final Map<String, Map<String, String>> strings = {
      'instant': {'en': 'Instant', 'local': 'तात्काळ'},
      'within12Hours': {'en': 'Within 12 Hours', 'local': '१२ तासांत'},
      'within24Hours': {'en': 'Within 24 Hours', 'local': '२४ तासांत'},
    };

    final language = isToggled ? 'local' : 'en';
    return strings[key]?[language] ?? key;
  }
}

class BottomNavigationStrings {
  static String getString(String key, bool isToggled) {
    final Map<String, Map<String, String>> strings = {
      'home': {'en': 'Home', 'local': 'होम'},
      'customerCare': {'en': 'Customer Care', 'local': 'ग्राहक सेवा'},
      'myOrder': {'en': 'My Order', 'local': 'माझी ऑर्डर'},
      'packages': {'en': 'Packages', 'local': 'पॅकेजेस'},
      'myProfile': {'en': 'My Profile', 'local': 'माझे प्रोफाइल'},
    };

    final language = isToggled ? 'local' : 'en';
    return strings[key]?[language] ?? key;
  }
}

class PackageStrings {
  static String getPackageName(String packageName, bool isToggled) {
    final Map<String, Map<String, String>> packageTranslations = {
      'package1': {'en': 'package1', 'local': 'पॅकेज १'},
      'Basic Package': {'en': 'Basic Package', 'local': 'मूलभूत पॅकेज'},
      'Premium Package': {'en': 'Premium Package', 'local': 'प्रिमियम पॅकेज'},
    };

    final language = isToggled ? 'local' : 'en';
    return packageTranslations[packageName]?[language] ?? packageName;
  }

  static String getShortDescription(String description, bool isToggled) {
    final Map<String, Map<String, String>> descriptionTranslations = {
      'package': {'en': 'package', 'local': 'पॅकेज'},
      'Includes basic services': {
        'en': 'Includes basic services',
        'local': 'मूलभूत सेवा समाविष्ट करते',
      },
      'Comprehensive package with additional benefits': {
        'en': 'Comprehensive package with additional benefits',
        'local': 'अतिरिक्त लाभांसह व्यापक पॅकेज',
      },
    };

    final language = isToggled ? 'local' : 'en';
    return descriptionTranslations[description]?[language] ?? description;
  }

  static String getTag(String tag, bool isToggled) {
    final Map<String, Map<String, String>> tagTranslations = {
      'doc2': {'en': 'doc2', 'local': 'दस्तऐवज २'},
      'Aadhar Card': {'en': 'Aadhar Card', 'local': 'आधार कार्ड'},
      'PAN Card': {'en': 'PAN Card', 'local': 'पॅन कार्ड'},
      'Property Documents': {
        'en': 'Property Documents',
        'local': 'मालमत्ता दस्तऐवज',
      },
    };

    final language = isToggled ? 'local' : 'en';
    return tagTranslations[tag]?[language] ?? tag;
  }
}
