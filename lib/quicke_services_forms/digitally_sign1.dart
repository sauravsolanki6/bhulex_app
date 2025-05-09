import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:my_bhulekh_app/colors/order_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Core/AppImages.dart';
import '../My_package/package_order_details.dart';
import '../colors/custom_color.dart';
import '../document_preview.dart';
import '../form_internet.dart';
import '../language/hindi.dart';
import '../network/url.dart';
import '../validations_chan_lang/seventwelveextract.dart';
import 'pay.dart';

class DigitallySign1 extends StatefulWidget {
  final String id;
  final String serviceName;
  final String tblName;
  final String lead_id;
  final String customer_id;
  final String package_lead_id;
  final String packageId;
  final bool isToggled;
  final String serviceNameInLocalLanguage;

  const DigitallySign1({
    super.key,
    required this.id,
    required this.serviceName,
    required this.tblName,
    required this.isToggled,
    required this.serviceNameInLocalLanguage,
    required this.packageId,
    required this.lead_id,
    required this.customer_id,
    required this.package_lead_id,
  });

  @override
  State<DigitallySign1> createState() => _DigitallySign1State();
}

class _DigitallySign1State extends State<DigitallySign1> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _surveyNoController = TextEditingController();
  final TextEditingController _ByNameIncasesurveynoisnotknownController =
      TextEditingController();
  final TextEditingController _mutationNoController = TextEditingController();
  final NetworkChecker _networkChecker = NetworkChecker();
  final TextEditingController _ByKhataNoController = TextEditingController();
  String? Selectedcity;
  String? SelectedId;
  List<Map<String, dynamic>> talukaData = [];
  String? selectedTaluka;
  List<Map<String, dynamic>> CityData = [];
  List<Map<String, dynamic>> villageData = [];
  String? selectedVillageName;
  String? selectedVillageId;
  String? selectedTalukaId;
  String? selectedLanguage;
  bool isLoading = true;

  @override
  void initState() {
    print(widget.tblName);
    super.initState();
    _networkChecker.startMonitoring(context);
    _fetchCity();
  }

  Future<void> submitQuickServiceForm(
    BuildContext context,
    Map<String, dynamic> formData,
  ) async {
    final String url = URLS().submit_quick_service_enquiry_form_apiUrl;
    print("Submitting to URL: $url");
    print("Form Data: ${jsonEncode(formData)}");

    try {
      var response = await http.post(
        Uri.parse(url),
        body: jsonEncode(formData),
        headers: {'Content-Type': 'application/json'},
      );

      print("Response Status Code: ${response.statusCode}");
      log("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        log("Success Response Data: $responseData");

        if (widget.packageId == "") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => payscreen(responseData: responseData),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PackageService(
                package_Id: widget.packageId,
                lead_id: widget.lead_id,
                customerid: widget.customer_id,
                tbl_name: '',
              ),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Form submission failed. Status Code: ${response.statusCode}. Response: ${response.body}",
            ),
          ),
        );
      }
    } on SocketException {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No internet connection. Please check your network.',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _fetchCity() async {
    final String url = URLS().get_all_city_apiUrl;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('state_id', '22');
    print('state_id 22 saved to SharedPreferences');

    var requestBody = {"state_id": "22"};
    print('Request URL: $url');
    print('Request Body: ${jsonEncode(requestBody)}');

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Response Status Code: ${response.statusCode}');
        print('Raw Response Body: "${response.body}"');

        if (data['status'] == 'true') {
          setState(() {
            CityData = List<Map<String, dynamic>>.from(data['data'] ?? []);
            isLoading = false;
          });
          print('Fetched City Data: ${data['data']}');
        } else {
          print('Failed to load city: ${data['message'] ?? 'Unknown error'}');
          setState(() {
            isLoading = false;
          });
        }
      } else {
        print('Failed to load data. Status code: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _fetchTaluka(String cityId) async {
    final String url = URLS().get_all_taluka_apiUrl;
    var requestBody = {"city_id": cityId};
    log('Request Body: ${jsonEncode(requestBody)}');

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Response Status Code: ${response.statusCode}');
        print('Raw Response Body: "${response.body}"');

        if (data['status'] == 'true') {
          setState(() {
            talukaData = List<Map<String, dynamic>>.from(data['data']);
          });
        }
      }
    } catch (e) {
      print('Taluka fetch error: $e');
    }
  }

  void _fetchVillages(String cityId, String talukaId) async {
    final url = URLS().get_all_village_apiUrl;
    var requestBody = {"city_id": cityId, "taluka_id": talukaId};
    log('Request Body: ${jsonEncode(requestBody)}');

    try {
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode(requestBody),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Response Status Code: ${response.statusCode}');
        print('Raw Response Body: "${response.body}"');

        if (data['status'] == 'true') {
          setState(() {
            villageData = List<Map<String, dynamic>>.from(data['data']);
          });
        }
      }
    } catch (e) {
      print("Exception while fetching villages: $e");
    }
  }

  Future<bool> _onWillPop() async {
    bool shouldLeave = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Confirm Exit',
          style: TextStyle(
            color: Colors.orange,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Are you sure you want to go back?',
          style: TextStyle(color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'No',
              style: TextStyle(color: Colors.orange),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Yes',
              style: TextStyle(color: Colors.orange),
            ),
          ),
        ],
      ),
    );

    return shouldLeave ?? false;
  }

  Future<void> _onRefresh() async {
    setState(() {
      isLoading = true;
      Selectedcity = null;
      _surveyNoController.clear();
      _mutationNoController.clear();
      selectedVillageName = null;
      selectedTaluka = null;
      selectedLanguage = null;
      _ByNameIncasesurveynoisnotknownController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    String displayServiceName = widget.isToggled
        ? widget.serviceNameInLocalLanguage
        : widget.serviceName;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: const Color(0xFFFDFDFD),
        appBar: AppBar(
          title: Text(
            displayServiceName,
            style: AppFontStyle2.blinker(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF36322E),
            ),
          ),
          backgroundColor: const Color(0xFFFFFFFF),
          titleSpacing: 0.0,
          elevation: 0,
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(Icons.arrow_back),
          ),
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1.0),
            child: Divider(height: 1, thickness: 1, color: Color(0xFFD9D9D9)),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: _onRefresh,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: SizedBox(
                // height: 1000,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.00,
                        ),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0x40F57C03),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              width: 0.5,
                              color: const Color(0xFFFCCACA),
                            ),
                          ),
                          padding: const EdgeInsets.fromLTRB(14, 14, 18, 14),
                          child: Text(
                            LocalizedStrings.getString(
                              'note',
                              widget.isToggled,
                            ),
                            style: AppFontStyle2.blinker(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF36322E),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        LocalizedStrings.getString(
                          'pleaseEnterYourDetails',
                          widget.isToggled,
                        ),
                        style: AppFontStyle2.blinker(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          height: 1.57,
                          color: const Color(0xFF36322E),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      FormField<String>(
                        validator: (value) {
                          if (Selectedcity == null ||
                              Selectedcity!.trim().isEmpty) {
                            return ValidationMessagesseventweleve.getMessage(
                              'pleaseSelectDistrict',
                              widget.isToggled,
                            );
                          }
                          final trimmedValue = Selectedcity!.trim();
                          if (RegExp(
                            r'<.*?>|script|alert|on\w+=',
                            caseSensitive: false,
                          ).hasMatch(trimmedValue)) {
                            return ValidationMessagesseventweleve.getMessage(
                              'invalidCharacters',
                              widget.isToggled,
                            );
                          }
                          return null;
                        },
                        builder: (FormFieldState<String> state) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DropdownSearch<String>(
                                items: CityData.map<String>((item) {
                                  return widget.isToggled
                                      ? (item['city_name_in_local_language'])
                                          .toString()
                                      : (item['city_name']).toString();
                                }).toList(),
                                selectedItem: Selectedcity,
                                dropdownDecoratorProps: DropDownDecoratorProps(
                                  dropdownSearchDecoration: InputDecoration(
                                    hintText: LocalizedStrings.getString(
                                      'district',
                                      widget.isToggled,
                                    ),
                                    labelText: LocalizedStrings.getString(
                                      'district',
                                      widget.isToggled,
                                    ),
                                    hintStyle: AppFontStyle2.blinker(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      height: 1.57,
                                      color: const Color(0xFF36322E),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 14,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide:
                                          BorderSide(color: Color(0xFFC5C5C5)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide:
                                          BorderSide(color: Color(0xFFC5C5C5)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide:
                                          BorderSide(color: Color(0xFFC5C5C5)),
                                    ),
                                    errorText: state.errorText,
                                  ),
                                ),
                                popupProps: PopupProps.menu(
                                  showSearchBox: true,
                                  searchFieldProps: TextFieldProps(
                                    textCapitalization:
                                        TextCapitalization.words,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(
                                          r'^[a-zA-Z\u0900-\u095F\u0970-\u097F\s]+$',
                                        ),
                                      ),
                                      LengthLimitingTextInputFormatter(50),
                                    ],
                                    decoration: InputDecoration(
                                      hintText: widget.isToggled
                                          ? 'जिल्हा शोधा...'
                                          : 'Search District...',
                                      hintStyle: AppFontStyle2.blinker(),
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color(0xFFC5C5C5)),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color(0xFFC5C5C5)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color(0xFFC5C5C5)),
                                      ),
                                    ),
                                  ),
                                ),
                                dropdownButtonProps: const DropdownButtonProps(
                                  icon: Icon(
                                    Icons.keyboard_arrow_down,
                                    size: 28,
                                    color: Color(0xFF9CA3AF),
                                  ),
                                ),
                                onChanged: (value) {
                                  log('${widget.isToggled}');
                                  setState(() {
                                    Selectedcity = value;

                                    final matchedCity = CityData.firstWhere(
                                      (element) =>
                                          (widget.isToggled
                                              ? (element[
                                                  'city_name_in_local_language'])
                                              : element['city_name']) ==
                                          value,
                                      orElse: () => {},
                                    );

                                    SelectedId = matchedCity.isNotEmpty
                                        ? matchedCity['id'].toString()
                                        : null;

                                    if (SelectedId != null) {
                                      _fetchTaluka(SelectedId!);
                                    }

                                    state.didChange(value);
                                  });
                                },
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      FormField<String>(
                        validator: (value) {
                          if (selectedTaluka == null ||
                              selectedTaluka!.trim().isEmpty) {
                            return ValidationMessagesseventweleve.getMessage(
                              'pleaseSelectTaluka',
                              widget.isToggled,
                            );
                          }
                          final trimmedValue = selectedTaluka!.trim();
                          if (RegExp(
                            r'<.*?>|script|alert|on\w+=',
                            caseSensitive: false,
                          ).hasMatch(trimmedValue)) {
                            return ValidationMessagesseventweleve.getMessage(
                              'invalidCharacters',
                              widget.isToggled,
                            );
                          }
                          return null;
                        },
                        builder: (FormFieldState<String> state) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DropdownSearch<String>(
                                items: talukaData.map<String>((item) {
                                  return widget.isToggled
                                      ? (item['taluka_name_in_local_language'] ??
                                              item['taluka_name'] ??
                                              '')
                                          .toString()
                                      : (item['taluka_name'] ?? '').toString();
                                }).toList(),
                                selectedItem: selectedTaluka,
                                dropdownDecoratorProps: DropDownDecoratorProps(
                                  dropdownSearchDecoration: InputDecoration(
                                    hintText: LocalizedStrings.getString(
                                      'taluka',
                                      widget.isToggled,
                                    ),
                                    labelText: LocalizedStrings.getString(
                                      'taluka',
                                      widget.isToggled,
                                    ),
                                    hintStyle: AppFontStyle2.blinker(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      height: 1.57,
                                      color: const Color(0xFF36322E),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 14,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide:
                                          BorderSide(color: Color(0xFFC5C5C5)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide:
                                          BorderSide(color: Color(0xFFC5C5C5)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide:
                                          BorderSide(color: Color(0xFFC5C5C5)),
                                    ),
                                    errorText: state.errorText,
                                  ),
                                ),
                                popupProps: PopupProps.menu(
                                  showSearchBox: true,
                                  searchFieldProps: TextFieldProps(
                                    textCapitalization:
                                        TextCapitalization.words,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(
                                          r'^[a-zA-Z\u0900-\u095F\u0970-\u097F\s]+$',
                                        ),
                                      ),
                                      LengthLimitingTextInputFormatter(50),
                                    ],
                                    decoration: InputDecoration(
                                      hintText: widget.isToggled
                                          ? 'तालुका शोधा...'
                                          : 'Search Taluka...',
                                      hintStyle: AppFontStyle2.blinker(),
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color(0xFFC5C5C5)),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color(0xFFC5C5C5)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color(0xFFC5C5C5)),
                                      ),
                                    ),
                                  ),
                                ),
                                dropdownButtonProps: const DropdownButtonProps(
                                  icon: Icon(
                                    Icons.keyboard_arrow_down,
                                    size: 28,
                                    color: Color(0xFF9CA3AF),
                                  ),
                                ),
                                onChanged: (value) {
                                  log('${widget.isToggled}');
                                  setState(() {
                                    selectedTaluka = value;
                                    final matchedTaluka = talukaData.firstWhere(
                                      (element) =>
                                          (widget.isToggled
                                              ? (element[
                                                      'taluka_name_in_local_language'] ??
                                                  element['taluka_name'])
                                              : element['taluka_name']) ==
                                          value,
                                      orElse: () => {},
                                    );
                                    selectedTalukaId = matchedTaluka.isNotEmpty
                                        ? matchedTaluka['id'].toString()
                                        : null;
                                    if (selectedTalukaId != null &&
                                        SelectedId != null) {
                                      _fetchVillages(
                                        SelectedId!,
                                        selectedTalukaId!,
                                      );
                                    }
                                    state.didChange(value);
                                  });
                                },
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      FormField<String>(
                        validator: (value) {
                          if (selectedVillageName == null ||
                              selectedVillageName!.trim().isEmpty) {
                            return ValidationMessagesseventweleve.getMessage(
                              'pleaseSelectVillage',
                              widget.isToggled,
                            );
                          }
                          final trimmedValue = selectedVillageName!.trim();
                          if (RegExp(
                            r'<.*?>|script|alert|on\w+=',
                            caseSensitive: false,
                          ).hasMatch(trimmedValue)) {
                            return ValidationMessagesseventweleve.getMessage(
                              'invalidCharacters',
                              widget.isToggled,
                            );
                          }
                          return null;
                        },
                        builder: (FormFieldState<String> state) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DropdownSearch<String>(
                                items: villageData
                                    .map<String>((item) {
                                      final villageName = widget.isToggled
                                          ? (item['village_name_in_local_language'] ??
                                              item['village_name'])
                                          : item['village_name'];
                                      return villageName?.toString() ?? '';
                                    })
                                    .where(
                                      (name) =>
                                          name.trim().isNotEmpty &&
                                          name.toLowerCase() != 'null',
                                    )
                                    .toList(),
                                selectedItem: selectedVillageName,
                                dropdownDecoratorProps: DropDownDecoratorProps(
                                  dropdownSearchDecoration: InputDecoration(
                                    hintText: LocalizedStrings.getString(
                                      'village',
                                      widget.isToggled,
                                    ),
                                    labelText: LocalizedStrings.getString(
                                      'village',
                                      widget.isToggled,
                                    ),
                                    hintStyle: AppFontStyle2.blinker(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      height: 1.57,
                                      color: const Color(0xFF36322E),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 14,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide:
                                          BorderSide(color: Color(0xFFC5C5C5)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide:
                                          BorderSide(color: Color(0xFFC5C5C5)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide:
                                          BorderSide(color: Color(0xFFC5C5C5)),
                                    ),
                                    errorText: state.errorText,
                                  ),
                                ),
                                popupProps: PopupProps.menu(
                                  showSearchBox: true,
                                  searchFieldProps: TextFieldProps(
                                    textCapitalization:
                                        TextCapitalization.words,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(
                                          r'^[a-zA-Z\u0900-\u095F\u0970-\u097F\s]+$',
                                        ),
                                      ),
                                      LengthLimitingTextInputFormatter(50),
                                    ],
                                    decoration: InputDecoration(
                                      hintText: widget.isToggled
                                          ? 'गाव शोधा...'
                                          : 'Search Village...',
                                      hintStyle: AppFontStyle2.blinker(),
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color(0xFFC5C5C5)),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color(0xFFC5C5C5)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color(0xFFC5C5C5)),
                                      ),
                                    ),
                                  ),
                                ),
                                dropdownButtonProps: const DropdownButtonProps(
                                  icon: Icon(
                                    Icons.keyboard_arrow_down,
                                    size: 28,
                                    color: Color(0xFF9CA3AF),
                                  ),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    selectedVillageName = value;

                                    final matchedVillage =
                                        villageData.firstWhere(
                                      (element) =>
                                          (widget.isToggled
                                              ? (element[
                                                      'village_name_in_local_language'] ??
                                                  element['village_name'])
                                              : element['village_name']) ==
                                          value,
                                      orElse: () => {},
                                    );

                                    selectedVillageId =
                                        matchedVillage.isNotEmpty
                                            ? matchedVillage['id'].toString()
                                            : null;

                                    state.didChange(value);
                                  });
                                },
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _surveyNoController,
                        decoration: InputDecoration(
                          hintText: LocalizedStrings.getString(
                            'fieldSurveyNo',
                            widget.isToggled,
                          ),
                          labelText: LocalizedStrings.getString(
                            'fieldSurveyNo',
                            widget.isToggled,
                          ),
                          hintStyle: AppFontStyle2.blinker(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            height: 1.57,
                            color: const Color(0xFF36322E),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(color: Color(0xFFC5C5C5)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(color: Color(0xFFC5C5C5)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(color: Color(0xFFC5C5C5)),
                          ),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(
                              r'^[\u0900-\u097F\u0966-\u096F a-zA-Z0-9\s/]+$',
                            ),
                          ),
                          TextInputFormatter.withFunction((oldValue, newValue) {
                            String text = newValue.text;
                            text = text.replaceAll(RegExp(r'\s+'), ' ');
                            text = text.trim();

                            if (text.length > 1) {
                              final lastChar = text[text.length - 1];
                              final secondLastChar = text[text.length - 2];
                              if (lastChar == ' ' &&
                                  ((RegExp(r'[0-9 /]')
                                              .hasMatch(secondLastChar) &&
                                          RegExp(r'[a-zA-Z /]').hasMatch(
                                            text.substring(0, text.length - 2),
                                          )) ||
                                      (RegExp(r'[a-zA-Z]')
                                              .hasMatch(secondLastChar) &&
                                          RegExp(r'[0-9 /]').hasMatch(
                                            text.substring(0, text.length - 2),
                                          )))) {
                                text = text.substring(
                                  0,
                                  text.length - 1,
                                );
                              }
                            }

                            return text == newValue.text
                                ? newValue
                                : TextEditingValue(
                                    text: text,
                                    selection: TextSelection.collapsed(
                                      offset: text.length,
                                    ),
                                  );
                          }),
                          LengthLimitingTextInputFormatter(50),
                        ],
                        textCapitalization: TextCapitalization.words,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return ValidationMessagesseventweleve.getMessage(
                              'pleaseEnterSurveyNo',
                              widget.isToggled,
                            );
                          }
                          final trimmedValue = value.trim();
                          if (RegExp(
                            r'<.*?>|script|alert|on\w+=',
                            caseSensitive: false,
                          ).hasMatch(trimmedValue)) {
                            return ValidationMessagesseventweleve.getMessage(
                              'invalidCharacters',
                              widget.isToggled,
                            );
                          }
                          return null;
                        },
                        style: AppFontStyle2.blinker(),
                      ),
                      const SizedBox(height: 16),
                      Visibility(
                        visible: widget.tblName != 'tbl_e_mutation_extract',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FormField<String>(
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return ValidationMessagesseventweleve
                                      .getMessage(
                                    'pleaseEnterByName',
                                    widget.isToggled,
                                  );
                                }
                                final trimmedValue = value.trim();
                                if (RegExp(
                                  r'<.*?>|script|alert|on\w+=',
                                  caseSensitive: false,
                                ).hasMatch(trimmedValue)) {
                                  return ValidationMessagesseventweleve
                                      .getMessage(
                                    'invalidCharacters',
                                    widget.isToggled,
                                  );
                                }
                                return null;
                              },
                              builder: (FormFieldState<String> state) {
                                return TextFormField(
                                  controller:
                                      _ByNameIncasesurveynoisnotknownController,
                                  decoration: InputDecoration(
                                    label: RichText(
                                      text: TextSpan(
                                        text: LocalizedStrings.getString(
                                          'byName',
                                          widget.isToggled,
                                        ),
                                        style: AppFontStyle2.blinker(
                                          color: state.hasError
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .error // Natural error color on validation error
                                              : const Color(
                                                  0xFF36322E), // Default color
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        children: [
                                          TextSpan(
                                            text:
                                                ' ${LocalizedStrings.getString('byNameHint', widget.isToggled)}',
                                            style: AppFontStyle.poppins(
                                              color: state.hasError
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .error // Natural error color on validation error
                                                  : const Color(
                                                      0xFF36322E), // Default color
                                              fontSize: 10,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide:
                                          BorderSide(color: Color(0xFFC5C5C5)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide:
                                          BorderSide(color: Color(0xFFC5C5C5)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide:
                                          BorderSide(color: Color(0xFFC5C5C5)),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .error), // Natural error border
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .error), // Natural error border when focused
                                    ),
                                    errorStyle: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .error, // Natural error text color
                                      fontSize: 12,
                                    ),
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(
                                        r'^[\u0900-\u097F\u0966-\u096F a-zA-Z\s/]+$',
                                      ),
                                    ),
                                    TextInputFormatter.withFunction(
                                        (oldValue, newValue) {
                                      String text = newValue.text;
                                      text =
                                          text.replaceAll(RegExp(r'\s+'), ' ');
                                      text = text.trimLeft();

                                      return text == newValue.text
                                          ? newValue
                                          : TextEditingValue(
                                              text: text,
                                              selection:
                                                  TextSelection.collapsed(
                                                offset: text.length,
                                              ),
                                            );
                                    }),
                                    LengthLimitingTextInputFormatter(50),
                                  ],
                                  textCapitalization: TextCapitalization.words,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return ValidationMessagesseventweleve
                                          .getMessage(
                                        'pleaseEnterByName',
                                        widget.isToggled,
                                      );
                                    }
                                    final trimmedValue = value.trim();
                                    if (RegExp(
                                      r'<.*?>|script|alert|on\w+=',
                                      caseSensitive: false,
                                    ).hasMatch(trimmedValue)) {
                                      return ValidationMessagesseventweleve
                                          .getMessage(
                                        'invalidCharacters',
                                        widget.isToggled,
                                      );
                                    }
                                    return null;
                                  },
                                  style: AppFontStyle2.blinker(),
                                  onChanged: (value) {
                                    state.didChange(
                                        value); // Update FormField state on text change
                                  },
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                      Visibility(
                        visible: widget.tblName != 'tbl_bhu_naksha',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              controller: _mutationNoController,
                              decoration: InputDecoration(
                                hintText: LocalizedStrings.getString(
                                  'mutationNo',
                                  widget.isToggled,
                                ),
                                labelText: LocalizedStrings.getString(
                                  'mutationNo',
                                  widget.isToggled,
                                ),
                                hintStyle: AppFontStyle2.blinker(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  height: 1.57,
                                  color: const Color(0xFF36322E),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide:
                                      BorderSide(color: Color(0xFFC5C5C5)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide:
                                      BorderSide(color: Color(0xFFC5C5C5)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide:
                                      BorderSide(color: Color(0xFFC5C5C5)),
                                ),
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(
                                    r'^[\u0900-\u097F\u0966-\u096F a-zA-Z0-9\s/]+$',
                                  ),
                                ),
                                TextInputFormatter.withFunction(
                                    (oldValue, newValue) {
                                  String text = newValue.text;
                                  text = text.replaceAll(RegExp(r'\s+'), ' ');
                                  text = text.trim();

                                  return text == newValue.text
                                      ? newValue
                                      : TextEditingValue(
                                          text: text,
                                          selection: TextSelection.collapsed(
                                            offset: text.length,
                                          ),
                                        );
                                }),
                                LengthLimitingTextInputFormatter(50),
                              ],
                              textCapitalization: TextCapitalization.words,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return ValidationMessagesseventweleve
                                      .getMessage(
                                    'pleaseEnterMutationNo',
                                    widget.isToggled,
                                  );
                                }
                                final trimmedValue = value.trim();
                                if (RegExp(
                                  r'<.*?>|script|alert|on\w+=',
                                  caseSensitive: false,
                                ).hasMatch(trimmedValue)) {
                                  return ValidationMessagesseventweleve
                                      .getMessage(
                                    'invalidCharacters',
                                    widget.isToggled,
                                  );
                                }
                                return null;
                              },
                              style: AppFontStyle2.blinker(),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                      if (widget.tblName == 'tbl_eighta_extract') ...[
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _ByKhataNoController,
                          decoration: InputDecoration(
                            label: RichText(
                              text: TextSpan(
                                text: LocalizedStrings.getString(
                                  'byKhataNo',
                                  widget.isToggled,
                                ),
                                style: AppFontStyle2.blinker(
                                  color: const Color(0xFF36322E),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                                children: [
                                  TextSpan(
                                    text:
                                        ' ${LocalizedStrings.getString('byKhataNoHint', widget.isToggled)}',
                                    style: AppFontStyle2.blinker(
                                      color: const Color(0xFF36322E),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide:
                                  const BorderSide(color: Color(0xFFC5C5C5)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide:
                                  const BorderSide(color: Color(0xFFC5C5C5)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide:
                                  const BorderSide(color: Color(0xFFC5C5C5)),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: const BorderSide(color: Colors.red),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: const BorderSide(color: Colors.red),
                            ),
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(
                                  r'^[\u0900-\u097F\u0966-\u096F a-zA-Z0-9\s/]+$'),
                            ),
                            TextInputFormatter.withFunction(
                                (oldValue, newValue) {
                              String text = newValue.text;
                              text = text.replaceAll(RegExp(r'\s+'), ' ');
                              text = text.trimLeft();
                              return text == newValue.text
                                  ? newValue
                                  : TextEditingValue(
                                      text: text,
                                      selection: TextSelection.collapsed(
                                          offset: text.length),
                                    );
                            }),
                            LengthLimitingTextInputFormatter(50),
                          ],
                          textCapitalization: TextCapitalization.words,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return ValidationMessagesseventweleve.getMessage(
                                'pleaseEnterByKhataNo',
                                widget.isToggled,
                              );
                            }
                            final trimmedValue = value.trim();
                            if (RegExp(r'<.*?>|script|alert|on\w+=',
                                    caseSensitive: false)
                                .hasMatch(trimmedValue)) {
                              return ValidationMessagesseventweleve.getMessage(
                                'invalidCharacters',
                                widget.isToggled,
                              );
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                      Visibility(
                        visible: widget.tblName != 'tbl_e_mutation_extract' &&
                            widget.tblName != 'tbl_bhu_naksha',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // const SizedBox(height: 16),
                            FormField<String>(
                              validator: (value) {
                                if (selectedLanguage == null ||
                                    selectedLanguage!.trim().isEmpty) {
                                  return ValidationMessagesseventweleve
                                      .getMessage(
                                    'pleaseSelectLanguage',
                                    widget.isToggled,
                                  );
                                }
                                return null;
                              },
                              builder: (FormFieldState<String> state) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    DropdownSearch<String>(
                                      items: const ["English", "Marathi"],
                                      selectedItem: selectedLanguage,
                                      dropdownDecoratorProps:
                                          DropDownDecoratorProps(
                                        dropdownSearchDecoration:
                                            InputDecoration(
                                          hintText: LocalizedStrings.getString(
                                            'selectLanguage',
                                            widget.isToggled,
                                          ),
                                          labelText: LocalizedStrings.getString(
                                            'selectLanguage',
                                            widget.isToggled,
                                          ),
                                          hintStyle: AppFontStyle2.blinker(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            height: 1.57,
                                            color: const Color(0xFF36322E),
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
                                                color: Color(0xFFC5C5C5)),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            borderSide: BorderSide(
                                                color: Color(0xFFC5C5C5)),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            borderSide: BorderSide(
                                                color: Color(0xFFC5C5C5)),
                                          ),
                                          errorText: state.errorText,
                                        ),
                                      ),
                                      popupProps: PopupProps.menu(
                                        showSearchBox: true,
                                        searchFieldProps: TextFieldProps(
                                          textCapitalization:
                                              TextCapitalization.words,
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(
                                              RegExp(
                                                r'^[a-zA-Z\s]+$',
                                              ),
                                            ),
                                            LengthLimitingTextInputFormatter(
                                                50),
                                          ],
                                          decoration: InputDecoration(
                                            hintText: widget.isToggled
                                                ? 'भाषा शोधा...'
                                                : 'Search Language...',
                                            hintStyle: AppFontStyle2.blinker(),
                                            border: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Color(0xFFC5C5C5)),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Color(0xFFC5C5C5)),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Color(0xFFC5C5C5)),
                                            ),
                                          ),
                                        ),
                                      ),
                                      dropdownButtonProps:
                                          const DropdownButtonProps(
                                        icon: Icon(
                                          Icons.keyboard_arrow_down,
                                          size: 28,
                                          color: Color(0xFF9CA3AF),
                                        ),
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          selectedLanguage = value;
                                          state.didChange(value);
                                        });
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF26500),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextButton(
                            onPressed: () async {
                              print("formdata");
                              if (_formKey.currentState!.validate()) {
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                final String? stateId = prefs.getString(
                                  'state_id',
                                );
                                final String? customerId = prefs.getString(
                                  'customer_id',
                                );
                                Map<String, dynamic> formData = {
                                  "tbl_name": widget.tblName,
                                  "lead_id": widget.package_lead_id,
                                  "package_id": widget.packageId ?? "",
                                  "customer_id": customerId,
                                  "state_id": stateId,
                                  "city_id": SelectedId,
                                  "taluka_id": selectedTalukaId,
                                  "village_id": selectedVillageId,
                                  "survey_no": _surveyNoController.text,
                                  "name":
                                      _ByNameIncasesurveynoisnotknownController
                                          .text,
                                  "mutation_no": _mutationNoController.text,
                                  "language": selectedLanguage,
                                };
                                submitQuickServiceForm(context, formData);
                              }
                            },
                            child: Center(
                              child: Text(
                                LocalizedStrings.getString(
                                  'next',
                                  widget.isToggled,
                                ),
                                style: AppFontStyle2.blinker(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colorfile.borderDark,
                                ),
                                color: Colorfile.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          DocumentPreviewPage(),
                                    ),
                                  );
                                },
                                child: Center(
                                  child: Text(
                                    LocalizedStrings.getString(
                                      'viewSample',
                                      widget.isToggled,
                                    ),
                                    style: AppFontStyle2.blinker(
                                      color: Colorfile.lightblack,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colorfile.lightwhite,
                                ),
                                color: Colorfile.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: TextButton(
                                onPressed: () {
                                  print("Chat with Us button pressed");
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      AppImages.whatsapp,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      LocalizedStrings.getString(
                                        'chatWithUs',
                                        widget.isToggled,
                                      ),
                                      style: AppFontStyle2.blinker(
                                        color: Colorfile.lightblack,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.05,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
