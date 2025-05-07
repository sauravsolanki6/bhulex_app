import 'dart:convert';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Core/AppImages.dart';
import '../colors/order_fonts.dart';
import '../network/url.dart';
import '../profile/profile.dart';

class NetworkChecker {
  bool _wasDisconnected = false;

  void startMonitoring(BuildContext context) {
    // Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
    //   // Check if there's no connectivity
    //   if (result == ConnectivityResult.none) {
    //     _wasDisconnected = true;
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       const SnackBar(
    //         content: Text('No internet'),
    //         backgroundColor: Colors.red,
    //         duration: Duration(seconds: 5),
    //       ),
    //     );
    //     print('No internet');
    //   } else {
    //     if (_wasDisconnected) {
    //       _wasDisconnected = false;
    //       ScaffoldMessenger.of(context).showSnackBar(
    //         const SnackBar(
    //           content: Text('Internet is back'),
    //           backgroundColor: Colors.green,
    //           duration: Duration(seconds: 2),
    //         ),
    //       );
    //       print('Internet is back');
    //     }
    //   }
    // });
  }
}

class informationscreen extends StatefulWidget {
  const informationscreen({super.key});

  @override
  _informationscreenState createState() => _informationscreenState();
}

class _informationscreenState extends State<informationscreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final NetworkChecker _networkChecker = NetworkChecker();
  String? Selectedstate;
  String? Selectedcity;
  List<Map<String, dynamic>> stateData = [];
  List<Map<String, dynamic>> cityData = [];
  String? Selectedstateid;
  String? SelectedcityId;
  bool isLoading = true;
  bool istoggled = false;

  @override
  void initState() {
    super.initState();
    _fetchState();
    _networkChecker.startMonitoring(context);
    _loadMobileNumber();
  }

  Future<void> _loadMobileNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? mobileNumber = prefs.getString('mobileNumber');
    if (mobileNumber != null && mobileNumber.isNotEmpty) {
      setState(() {
        _mobileController.text = mobileNumber;
      });
      log('Loaded Mobile Number: $mobileNumber');
    } else {
      log('No Mobile Number found in SharedPreferences');
    }
  }

  void information() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? customerId = prefs.getString('customer_id');
    var requestBody = {
      "customer_id": customerId,
      "customer_name": _customerNameController.text,
      "mobile_number": _mobileController.text,
      "email": _emailController.text,
      "city_id": SelectedcityId ?? '',
      "state_id": Selectedstateid ?? '',
    };

    print('Request Body: ${jsonEncode(requestBody)}');
    final String url = URLS().update_customer_profile_apiUrl;
    print('Request URL: $url');

    try {
      var response = await http.post(
        Uri.parse(url),
        body: jsonEncode(requestBody),
        headers: {'Content-Type': 'application/json'},
      );

      print('Response Status Code: ${response.statusCode}');
      log('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Details submitted successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ProfilePage(isToggled: istoggled),
          ),
        );
        print(" Success Response: $responseData");
      } else {
        print(" Error Response: ${response.body}");
      }
    } catch (e) {
      print("Exception occurred during submission: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No internet connection. Please check your network."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _fetchCity(String? selectedStateId) async {
    var requestBody = {"state_id": selectedStateId};
    print('Request Body: ${jsonEncode(requestBody)}');

    final String url = URLS().get_all_city_apiUrl;
    print('Request URL: $url');

    try {
      var response = await http.post(
        Uri.parse(url),
        body: jsonEncode(requestBody),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        log('Response Status Code: ${response.statusCode}');
        log('Response Body: ${response.body}');
        if (data['status'] == 'true') {
          setState(() {
            cityData = List<Map<String, dynamic>>.from(data['data']);
            isLoading = false;
          });
          log('Fetched City Data: ${data['data']}');
        } else {
          print('Failed to load city: ${data['message']}');
        }
      } else {
        print('Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _fetchState() async {
    final String url = URLS().get_all_state_apiUrl;
    print('Request URL: $url');

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      print('Response Status Code: ${response.statusCode}');
      log('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'true') {
          setState(() {
            stateData = List<Map<String, dynamic>>.from(data['data']);
            isLoading = false;
          });
        } else {
          print('Failed to load state: ${data['message']}');
        }
      } else {
        print('Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      isLoading = true;
      Selectedcity = null;
      _customerNameController.clear();
      Selectedstate = null;
      _emailController.clear();
      _cityController.clear();
    });
    await _fetchState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const informationscreen()),
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFDFDFD),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          titleSpacing: 0.0,
          leading: IconButton(
            icon: Image.asset(AppImages.backArrow),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: const Text('Personal Details'),
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
              child: Form(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'PLEASE ENTER YOUR DETAILS',
                      style: GoogleFonts.blinker(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF36322E),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _customerNameController,
                      decoration: InputDecoration(
                        labelText: 'NAME',
                        labelStyle: AppFontStyle.poppins(
                          color: const Color(0xFF36322E),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(
                            color: Color(0xFFD0D0D0),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(
                            color: Color(0xFFD0D0D0),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(
                            color: Color(0xFFD0D0D0),
                          ),
                        ),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[\p{L}\s]', unicode: true),
                        ),
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          String text = newValue.text;
                          text = text.replaceAll(RegExp(r'\s+'), ' ');
                          text = text.trimLeft();
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
                          return 'Please enter name';
                        }
                        final trimmedValue = value.trim();
                        if (!RegExp(r'^[A-Za-z]+(?: [A-Za-z]+)*$')
                            .hasMatch(trimmedValue)) {
                          return 'Only alphabets with a single space between words allowed';
                        }
                        if (RegExp(r'<.*?>|script|alert|on\w+=',
                                caseSensitive: false)
                            .hasMatch(trimmedValue)) {
                          return 'Invalid characters or script content detected';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      textInputAction: TextInputAction.done,
                      controller: _mobileController,
                      keyboardType: TextInputType.number,
                      maxLength: 10,
                      readOnly: true,
                      style: AppFontStyle.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF36322E),
                      ),
                      decoration: InputDecoration(
                        labelText: 'MOBILE NUMBER',
                        labelStyle: AppFontStyle.poppins(
                          color: const Color(0xFF36322E),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(
                            color: Color(0xFFD0D0D0),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(
                            color: Color(0xFFD0D0D0),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(
                            color: Color(0xFFD0D0D0),
                          ),
                        ),
                        counterText: "",
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter mobile number';
                        }
                        if (value.length != 10 ||
                            !RegExp(r'^[0-9]+$').hasMatch(value)) {
                          return 'Enter a valid 10-digit mobile number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      textInputAction: TextInputAction.next,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textCapitalization: TextCapitalization.none,
                      decoration: InputDecoration(
                        labelText: 'E-MAIL ID',
                        labelStyle: AppFontStyle.poppins(
                          color: const Color(0xFF36322E),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6.0),
                          borderSide: const BorderSide(
                            color: Color(0xFFD0D0D0),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6.0),
                          borderSide: const BorderSide(
                            color: Color(0xFFD0D0D0),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6.0),
                          borderSide: const BorderSide(
                            color: Color(0xFFD0D0D0),
                          ),
                        ),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[a-zA-Z0-9@._-]'),
                        ),
                        LengthLimitingTextInputFormatter(50),
                      ],
                      onChanged: (value) {
                        _emailController.value =
                            _emailController.value.copyWith(
                          text: value.toLowerCase(),
                          selection: TextSelection.collapsed(
                            offset: value.length,
                          ),
                        );
                      },
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter email ID';
                        }
                        final trimmedValue = value.trim();
                        if (RegExp(
                                r'<.*?>|script|alert|on\w+=|javascript|vbscript',
                                caseSensitive: false)
                            .hasMatch(trimmedValue)) {
                          return 'Invalid characters or script content detected';
                        }
                        if (!RegExp(r'^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,4}$')
                            .hasMatch(trimmedValue)) {
                          return 'Please enter a valid email ID';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    FormField<String>(
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please select a state';
                        }
                        final trimmedValue = value.trim();
                        if (RegExp(r'<.*?>|script|alert|on\w+=',
                                caseSensitive: false)
                            .hasMatch(trimmedValue)) {
                          return 'Invalid characters or script content detected';
                        }
                        if (!RegExp(r'^[\p{L}\s]+$', unicode: true)
                            .hasMatch(trimmedValue)) {
                          return 'Only alphabets and spaces allowed';
                        }
                        if (trimmedValue.length > 50) {
                          return 'State name must not exceed 50 characters';
                        }
                        return null;
                      },
                      builder: (FormFieldState<String> state) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DropdownSearch<String>(
                              items: stateData
                                  .map<String>(
                                    (item) => item['state_name'].toString(),
                                  )
                                  .toList(),
                              selectedItem: Selectedstate,
                              dropdownDecoratorProps: DropDownDecoratorProps(
                                dropdownSearchDecoration: InputDecoration(
                                  labelText: 'STATE',
                                  labelStyle: AppFontStyle.poppins(
                                    color: const Color(0xFF36322E),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 14,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFD0D0D0),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFD0D0D0),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFD0D0D0),
                                    ),
                                  ),
                                  errorText: state.errorText,
                                ),
                              ),
                              popupProps: PopupProps.menu(
                                showSearchBox: true,
                                searchFieldProps: TextFieldProps(
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'[\p{L}\s]', unicode: true),
                                    ),
                                    LengthLimitingTextInputFormatter(50),
                                  ],
                                  decoration: const InputDecoration(
                                    hintText: 'Search State...',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              onChanged: (value) async {
                                setState(() {
                                  Selectedstate = value;
                                  Selectedcity = null;
                                  state.didChange(value);
                                });
                                final matchedState = stateData.firstWhere(
                                  (item) => item['state_name'] == value,
                                  orElse: () => {},
                                );
                                Selectedstateid = matchedState.isNotEmpty
                                    ? matchedState['id']?.toString()
                                    : '';
                                log("Selected state ID: $Selectedstateid");
                                _fetchCity(Selectedstateid);
                              },
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    FormField<String>(
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please select a city/village';
                        }
                        final trimmedValue = value.trim();
                        if (RegExp(r'<.*?>|script|alert|on\w+=',
                                caseSensitive: false)
                            .hasMatch(trimmedValue)) {
                          return 'Invalid characters or script content detected';
                        }
                        if (!RegExp(r'^[\p{L}\s]+$', unicode: true)
                            .hasMatch(trimmedValue)) {
                          return 'Only alphabets and spaces allowed';
                        }
                        if (trimmedValue.length > 50) {
                          return 'City name must not exceed 50 characters';
                        }
                        return null;
                      },
                      builder: (FormFieldState<String> state) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DropdownSearch<String>(
                              items: cityData
                                  .map<String>(
                                    (item) => item['city_name'].toString(),
                                  )
                                  .toList(),
                              selectedItem: Selectedcity,
                              dropdownDecoratorProps: DropDownDecoratorProps(
                                dropdownSearchDecoration: InputDecoration(
                                  labelText: 'CITY/VILLAGE',
                                  labelStyle: AppFontStyle.poppins(
                                    color: const Color(0xFF36322E),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 14,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFD0D0D0),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFD0D0D0),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFD0D0D0),
                                    ),
                                  ),
                                  errorText: state.errorText,
                                ),
                              ),
                              popupProps: PopupProps.menu(
                                showSearchBox: true,
                                searchFieldProps: TextFieldProps(
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'[\p{L}\s]', unicode: true),
                                    ),
                                    LengthLimitingTextInputFormatter(50),
                                  ],
                                  decoration: const InputDecoration(
                                    hintText: 'Search City/Village...',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              onChanged: (newValue) {
                                setState(() {
                                  Selectedcity = newValue;
                                  final selectedCityData = cityData.firstWhere(
                                    (city) => city['city_name'] == newValue,
                                    orElse: () => {},
                                  );
                                  SelectedcityId = selectedCityData.isNotEmpty
                                      ? selectedCityData['id']?.toString()
                                      : null;
                                  log("Selected city ID: $SelectedcityId");
                                  state.didChange(newValue);
                                });
                              },
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                    Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF57C03),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate() &&
                              Selectedstate != null &&
                              Selectedcity != null) {
                            information();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Please enter all fields',
                                  style: AppFontStyle.poppins(
                                    color: Colors.white,
                                  ),
                                ),
                                backgroundColor: Colors.red,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        child: Text(
                          'SUBMIT',
                          style: AppFontStyle.poppins(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
