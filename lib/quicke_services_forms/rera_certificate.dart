// ignore_for_file: camel_case_types

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;


import 'package:shared_preferences/shared_preferences.dart';

import '../My_package/package_order_details.dart';
import '../colors/order_fonts.dart';
import '../form_internet.dart';
import '../language/hindi.dart';
import '../validations_chan_lang/rera.dart';
import 'pay.dart';

class ReraCertificate extends StatefulWidget {
  final String id;
  final String serviceName;
  final String packageId;
  final String lead_id;
  final String customer_id;
  final String tblName;
  final bool isToggled; // Added for language toggle
  final String serviceNameInLocalLanguage; // Added for local service name
  final String package_lead_id;
  const ReraCertificate({
    super.key,
    required this.packageId,
    required this.id,
    required this.serviceName,
    required this.tblName,
    required this.isToggled,
    required this.serviceNameInLocalLanguage,
    required this.lead_id,
    required this.customer_id,
    required this.package_lead_id,
    //required this.packageid,
  });

  @override
  _ReraCertificateState createState() => _ReraCertificateState();
}

class _ReraCertificateState extends State<ReraCertificate> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = true;
  final NetworkChecker _networkChecker = NetworkChecker(); // Add NetworkChecker

  final TextEditingController _projectController = TextEditingController();
  final TextEditingController _builderController = TextEditingController();

  @override
  void dispose() {
    _projectController.dispose();
    _builderController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _networkChecker.startMonitoring(context); // Start network monitoring

    // checkNetworkConnection();
  }

  Future<void> _onRefresh() async {
    setState(() {
      isLoading = true;
      _projectController.clear();
      _builderController.clear();
    });
  }

  Future<void> submitQuickServiceForm(
    BuildContext context,
    Map<String, dynamic> formData,
  ) async {
    const String url =
        'https://seekhelp.in/bhulex/submit_quick_service_enquiry_form';
    print('Request URL: $url');
    print('Request Body: ${jsonEncode(formData)}');

    try {
      var response = await http.post(
        Uri.parse(url),
        body: jsonEncode(formData),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print("Form submitted successfully: $responseData");
        // Check if packageId is empty
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
              builder:
                  (context) => PackageService(
                    package_Id: widget.packageId,
                    lead_id: widget.lead_id,
                    customerid: widget.customer_id,
                    tbl_name: '',
                  ),
            ),
          );
        }
      } else {
        print("Failed to submit form: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Form submission failed. Please try again."),
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
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String displayServiceName =
        widget.isToggled
            ? widget.serviceNameInLocalLanguage
            : widget.serviceName;

    return Scaffold(
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    ReraCertificateStrings.getString(
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
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _projectController,
                    decoration: InputDecoration(
                      hintText: ReraCertificateStrings.getString(
                        'projectName',
                        widget.isToggled,
                      ),

                      hintStyle: AppFontStyle2.blinker(
                        color: Color(0xFF36322E),
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: Color(0xFFC5C5C5)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: Color(0xFFC5C5C5)),
                      ),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^[\u0900-\u097F\u0966-\u096F a-zA-Z\s/]+$'),
                      ),
                      TextInputFormatter.withFunction((oldValue, newValue) {
                        String text = newValue.text;
                        // Replace multiple spaces with single space
                        text = text.replaceAll(RegExp(r'\s+'), ' ');
                        // Remove leading space
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
                        return ValidationMessagesrera.getMessage(
                          'pleaseEnterProjectName',
                          widget.isToggled,
                        );
                      }
                      final trimmedValue = value.trim();
                      if (RegExp(
                        r'<.*?>|script|alert|on\w+=',
                        caseSensitive: false,
                      ).hasMatch(trimmedValue)) {
                        return ValidationMessagesrera.getMessage(
                          'invalidCharacters',
                          widget.isToggled,
                        );
                      }
                      // if (!RegExp(
                      //   r'^[\p{L}]+( [\p{L}]+)*$',
                      //   unicode: true,
                      // ).hasMatch(trimmedValue)) {
                      //   return ValidationMessagesrera.getMessage(
                      //     'onlyAlphabetsAndSingleSpaces',
                      //     widget.isToggled,
                      //   );
                      // }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _builderController,
                    decoration: InputDecoration(
                      hintText: ReraCertificateStrings.getString(
                        'builderName',
                        widget.isToggled,
                      ),

                      hintStyle: AppFontStyle2.blinker(
                        color: Color(0xFF36322E),
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: Color(0xFFC5C5C5)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: Color(0xFFC5C5C5)),
                      ),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^[\u0900-\u097F\u0966-\u096F a-zA-Z\s/]+$'),
                      ),
                      TextInputFormatter.withFunction((oldValue, newValue) {
                        String text = newValue.text;
                        // Replace multiple spaces with single space
                        text = text.replaceAll(RegExp(r'\s+'), ' ');
                        // Remove leading space
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
                        return ValidationMessagesrera.getMessage(
                          'pleaseEnterBuilderName',
                          widget.isToggled,
                        );
                      }
                      final trimmedValue = value.trim();
                      if (RegExp(
                        r'<.*?>|script|alert|on\w+=',
                        caseSensitive: false,
                      ).hasMatch(trimmedValue)) {
                        return ValidationMessagesrera.getMessage(
                          'invalidCharacters',
                          widget.isToggled,
                        );
                      }
                      // if (!RegExp(
                      //   r'^[\p{L}]+( [\p{L}]+)*$',
                      //   unicode: true,
                      // ).hasMatch(trimmedValue)) {
                      //   return ValidationMessagesrera.getMessage(
                      //     'onlyAlphabetsAndSingleSpaces',
                      //     widget.isToggled,
                      //   );
                      // }
                      return null;
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 50.0),
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF57C03),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            final String? stateId = prefs.getString('state_id');
                            final String? customerId = prefs.getString(
                              'customer_id',
                            );

                            Map<String, dynamic> formData = {
                              "customer_id": customerId,
                              "lead_id": widget.package_lead_id,
                              "package_id":
                                  widget.packageId ??
                                  "", // Send empty string if null                              "state_id": stateId,
                              "project_name": _projectController.text.trim(),
                              "builder_name": _builderController.text.trim(),
                              "tbl_name": widget.tblName,
                            };

                            submitQuickServiceForm(context, formData);
                          }
                        },
                        child: Center(
                          child: Text(
                            ReraCertificateStrings.getString(
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
                  SizedBox(height: MediaQuery.of(context).size.height * 0.43),
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
                        ReraCertificateStrings.getString(
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
