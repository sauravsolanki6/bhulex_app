// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:dropdown_search/dropdown_search.dart';
// import 'package:my_bhulekh_app/colors/custom_color.dart';
// import 'package:my_bhulekh_app/colors/order_fonts.dart';
// import 'package:my_bhulekh_app/language/hindi.dart';
// import 'package:my_bhulekh_app/profile/profile.dart' show ProfilePage;
// import '../controller/order/my_order_controller.dart';
// import '../controller/order/language controller.dart'; // Import LanguageController
// import '../customfiles/bottom_navigation_controller.dart';
// import '../customfiles/custom_bottom_navigation_bar.dart';
// import '../homepage.dart';
// import 'order_detail.dart';
// import '../My_package/package_details_new.dart';

// class MyOrderScreen extends StatefulWidget {
//   final String? customer_id;
//   final String? package_id;
//   // Add constructor
//   const MyOrderScreen({this.customer_id, super.key, this.package_id});

//   @override
//   State<MyOrderScreen> createState() => _MyOrderScreenState();
// }

// class _MyOrderScreenState extends State<MyOrderScreen> {
//   final BottomNavigationController navigationController =
//       Get.find<BottomNavigationController>();
//   final OrderController orderController = Get.find<OrderController>();
//   final LanguageController languageController =
//       Get.find<LanguageController>(); // Access global LanguageController
//   final ScrollController _scrollController = ScrollController();

//   int _selectedIndex = 2;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       orderController.refreshOrders(
//         isToggled: languageController.isToggled.value,
//       );
//     });

//     _scrollController.addListener(() {
//       if (_scrollController.position.pixels >=
//               _scrollController.position.maxScrollExtent - 100 &&
//           !orderController.isLoadingMore.value) {
//         orderController.loadMoreOrders(
//           isToggled: languageController.isToggled.value,
//         );
//       }
//     });
//   }
//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }

//   Map<String, dynamic> getStatusDetails(String leadStatus, bool isToggled) {
//     final Map<String, Map<String, Map<String, String>>> statusTranslations = {
//       "0": {
//         "en": {"text": "Pending"},
//         "local": {"text": "प्रलंबित"},
//       },
//       "1": {
//         "en": {"text": "Order Confirmed"},
//         "local": {"text": "ऑर्डर पुष्ट"},
//       },
//       "2": {
//         "en": {"text": "Approved"},
//         "local": {"text": "मान्य"},
//       },
//       "3": {
//         "en": {"text": "Rejected"},
//         "local": {"text": "नाकारले"},
//       },
//     };

//     final language = isToggled ? 'local' : 'en';
//     final status =
//         statusTranslations[leadStatus] ??
//         {
//           "en": {"text": "Unknown"},
//           "local": {"text": "अज्ञात"},
//         };

//     switch (leadStatus) {
//       case "0":
//         return {
//           "text": status[language]!["text"],
//           "color": Colors.orange.shade100,
//           "textColor": const Color(0xFFEA580C),
//         };
//       case "1":
//         return {
//           "text": status[language]!["text"],
//           "color": Colors.green.shade100,
//           "textColor": const Color(0xFF149845),
//         };
//       case "2":
//         return {
//           "text": status[language]!["text"],
//           "color": Colors.green.shade100,
//           "textColor": const Color(0xFF149845),
//         };
//       case "3":
//         return {
//           "text": status[language]!["text"],
//           "color": Colors.red.shade100,
//           "textColor": const Color(0xFFD32F2F),
//         };
//       default:
//         return {
//           "text": status[language]!["text"],
//           "color": Colors.grey.shade100,
//           "textColor": Colors.grey,
//         };
//     }
//   }

//   void _showFilterDialog() {
//     String? selectedId; // To store the selected serviceId
//     String? selectedType; // To distinguish the type

//     Get.dialog(
//       AlertDialog(
//         title: Text(
//           languageController.isToggled.value
//               ? 'ऑर्डर फिल्टर करा'
//               : 'Filter Orders',
//           style: AppFontStyle2.blinker(
//             fontSize: 18,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         content: DropdownSearch<String>(
//           popupProps: PopupProps.menu(
//             showSearchBox: true,
//             searchFieldProps: TextFieldProps(
//               decoration: InputDecoration(
//                 labelText:
//                     languageController.isToggled.value
//                         ? 'सेवा शोधा'
//                         : 'Search Service',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//             ),
//           ),
//           items:
//               orderController.packageService
//                   .map((item) {
//                     if (item.serviceName != null &&
//                         item.serviceName!.isNotEmpty) {
//                       return languageController.isToggled.value &&
//                               item.serviceNameInLocalLanguage != null &&
//                               item.serviceNameInLocalLanguage!.isNotEmpty
//                           ? item.serviceNameInLocalLanguage!
//                           : item.serviceName!;
//                     }
//                     return 'Unknown';
//                   })
//                   .toSet()
//                   .toList(),
//           onChanged: (value) {
//             final selectedItem = orderController.packageService.firstWhere(
//               (item) {
//                 if (item.serviceName != null && item.serviceName!.isNotEmpty) {
//                   return (languageController.isToggled.value &&
//                           item.serviceNameInLocalLanguage != null &&
//                           item.serviceNameInLocalLanguage!.isNotEmpty
//                       ? item.serviceNameInLocalLanguage == value
//                       : item.serviceName == value);
//                 }
//                 return false;
//               },
//               orElse: () => orderController.packageService[0], // Fallback
//             );

//             if (selectedItem.serviceName != null &&
//                 selectedItem.serviceName!.isNotEmpty) {

//               selectedId = selectedItem.id;
//               selectedType = 'service';
//             }

//             log('Selected: $value, ID: $selectedId, Type: $selectedType');
//           },
//           dropdownDecoratorProps: DropDownDecoratorProps(
//             dropdownSearchDecoration: InputDecoration(
//               labelText:
//                   languageController.isToggled.value
//                       ? 'सेवा निवडा'
//                       : 'Select Service',
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(),
//             child: Text(
//               languageController.isToggled.value ? 'रद्द करा' : 'Cancel',
//               style: AppFontStyle2.blinker(color: Colors.grey),
//             ),
//           ),
//           TextButton(
//             onPressed: () {
//               if (selectedId != null && selectedType != null) {
//                 orderController.offset.value = 0;
//                 orderController.allOrders.clear();
//                 if (selectedType == 'service') {
//                   orderController.fetchOrders(
//                     customOffset: 0,
//                     serviceId: selectedId,
//                     isToggled: languageController.isToggled.value,
//                   );
//                 }
//               }
//               Get.back();
//             },
//             child: Text(
//               languageController.isToggled.value ? 'लागू करा' : 'Apply',
//               style: AppFontStyle2.blinker(color: Colors.blue),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//     switch (index) {
//       case 0:
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => HomePage2(customer_id: '', customerId: ''),
//           ),
//         );
//         break;
//       case 1:
//         print("Customer Care tapped");
//         break;
//       case 2:
//         break;
//       case 3:
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder:
//                 (context) =>
//                     ProfilePage(isToggled: languageController.isToggled.value),
//           ),
//         );
//         break;
//       case 4:
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder:
//                 (context) => PackageScreen(
//                   customerId: '',
//                   package_id: '',
//                   tbl_name: '',
//                   customerid: '',
//                 ),
//           ),
//         );
//         break;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Obx(
//           () => Text(
//             languageController.isToggled.value ? "माझी ऑर्डर" : "My Order",
//             style: AppFontStyle2.blinker(
//               fontWeight: FontWeight.w600,
//               color: const Color(0xFF36322E),
//               fontSize: 18,
//             ),
//           ),
//         ),
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.filter_list, color: Colors.black),
//             onPressed: _showFilterDialog,
//           ),
//         ],
//       ),
//       backgroundColor: const Color(0xFFF8F8F8),
//       body: RefreshIndicator(
//         onRefresh:
//             () => orderController.refreshOrders(
//               isToggled: languageController.isToggled.value,
//             ),
//         child: Obx(
//           () =>
//               orderController.isLoading.value &&
//                       orderController.allOrders.isEmpty
//                   ? const Center(child: CircularProgressIndicator())
//                   : orderController.allOrders.isEmpty
//                   ? _buildNoDataScreen()
//                   : ListView.builder(
//                     controller: _scrollController,
//                     padding: const EdgeInsets.all(20),
//                     itemCount:
//                         orderController.allOrders.length +
//                         (orderController.isLoadingMore.value ? 1 : 0),
//                     itemBuilder: (context, index) {
//                       if (index == orderController.allOrders.length &&
//                           orderController.isLoadingMore.value) {
//                         return const Padding(
//                           padding: EdgeInsets.all(8.0),
//                           child: Center(child: CircularProgressIndicator()),
//                         );
//                       }

//                       final order = orderController.allOrders[index];
//                       final statusDetails = getStatusDetails(
//                         order.leadStatus,
//                         languageController.isToggled.value,
//                       );

//                       return Container(
//                         margin: const EdgeInsets.only(
//                           bottom: 15,
//                         ), // Fixed to bottom
//                         padding: const EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(10),
//                           border: Border.all(color: Colors.grey.shade300),
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text(
//                                   "${languageController.isToggled.value ? 'ऑर्डर आयडी' : 'Order ID'} : ${order.id}",
//                                   style: AppFontStyle2.blinker(
//                                     fontWeight: FontWeight.w500,
//                                     fontSize: 17,
//                                   ),
//                                 ),
//                                 Container(
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 12,
//                                     vertical: 4,
//                                   ),
//                                   decoration: BoxDecoration(
//                                     color: statusDetails["color"],
//                                     borderRadius: BorderRadius.circular(8),
//                                   ),
//                                   child: Text(
//                                     statusDetails["text"],
//                                     style: AppFontStyle2.blinker(
//                                       color: statusDetails["textColor"],
//                                       fontWeight: FontWeight.w500,
//                                       fontSize: 16,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 8),
//                             _buildRow(
//                               languageController.isToggled.value
//                                   ? (order.package_name.isNotEmpty
//                                       ? "पॅकेज नाव"
//                                       : "सेवा नाव") // Use "Package Name" in Marathi if package_name exists
//                                   : (order.package_name.isNotEmpty
//                                       ? "Package Name"
//                                       : "Service Name"), // Use "Package Name" in English if package_name exists
//                               order.package_name.isNotEmpty
//                                   ? (languageController.isToggled.value
//                                       ? order
//                                               .package_name_in_local_language
//                                               .isNotEmpty
//                                           ? order
//                                               .package_name_in_local_language // Show local package name if available
//                                           : order
//                                               .package_name // Fallback to English package name
//                                       : order
//                                           .package_name) // Show English package name
//                                   : (order.serviceNameLocal != null &&
//                                           languageController.isToggled.value
//                                       ? order.serviceNameLocal!
//                                       : localizationOrderdetailsStrings
//                                           .getServiceName(
//                                             order.serviceName,
//                                             languageController.isToggled.value,
//                                           )), // Fallback to service name logic if no package_name
//                             ),
//                             if (order.leadStatus == "1" ||
//                                 order.leadStatus == "3")
//                               Container(
//                                 padding: const EdgeInsets.all(10),
//                                 decoration: BoxDecoration(
//                                   color: Colors.yellow.shade50,
//                                   borderRadius: BorderRadius.circular(8),
//                                 ),
//                                 child: Text(
//                                   languageController.isToggled.value
//                                       ? "टीप: तुमची ऑर्डर प्रक्रियेत आहे. ती पुष्ट झाल्यावर आम्ही तुम्हाला सूचित करू. तुमच्या संयमाबद्दल धन्यवाद!"
//                                       : "Note: Your order is being processed. We will notify you once it is confirmed. Thank you for your patience!",
//                                   style: AppFontStyle2.blinker(
//                                     fontSize: 11,
//                                     color: Colors.black87,
//                                     fontWeight: FontWeight.w400,
//                                   ),
//                                 ),
//                               ),
//                             if (order.leadStatus == "2")
//                               Padding(
//                                 padding: const EdgeInsets.only(top: 8.0),
//                                 child: SizedBox(
//                                   width: double.infinity,
//                                   child: OutlinedButton(
//                                     onPressed: () {
//                                       print(order.id);
//                                       Navigator.pushReplacement(
//                                         context,
//                                         MaterialPageRoute(
//                                           builder:
//                                               (context) => OrderDetail(
//                                                 order: {
//                                                   "orderId": order.id,
//                                                   "serviceName":
//                                                       order.serviceNameLocal !=
//                                                                   null &&
//                                                               languageController
//                                                                   .isToggled
//                                                                   .value
//                                                           ? order
//                                                               .serviceNameLocal!
//                                                           : localizationOrderStrings
//                                                               .getServiceName(
//                                                                 order
//                                                                     .serviceName,
//                                                                 languageController
//                                                                     .isToggled
//                                                                     .value,
//                                                               ),
//                                                   "status":
//                                                       statusDetails["text"],
//                                                   "customerId":
//                                                       orderController
//                                                           .customerId
//                                                           .value,
//                                                   "tbl_name": order.tblName,
//                                                 },
//                                                 customerid: '',
//                                                 package_Id: '',
//                                               ),
//                                         ),
//                                       );
//                                     },
//                                     child: Text(
//                                       languageController.isToggled.value
//                                           ? 'तपशील पहा'
//                                           : 'View Details',
//                                       style: AppFontStyle2.blinker(
//                                         color: const Color(0xFF36322E),
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.w500,
//                                       ),
//                                     ),
//                                     style: OutlinedButton.styleFrom(
//                                       side: const BorderSide(
//                                         color: Color(0xFF36322E),
//                                       ),
//                                       shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(8),
//                                       ),
//                                       padding: const EdgeInsets.symmetric(
//                                         vertical: 10,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                           ],
//                         ),
//                       );
//                     },
//                   ),
//         ),
//       ),
//       bottomNavigationBar: Container(
//         decoration: const BoxDecoration(
//           color: Color(0xFFFFFFFF),
//           boxShadow: [
//             BoxShadow(
//               color: Color(0x14000000),
//               offset: Offset(2, 0),
//               blurRadius: 25,
//               spreadRadius: 0,
//             ),
//           ],
//         ),
//         child: Obx(
//           () => BottomNavigationBar(
//             type: BottomNavigationBarType.fixed,
//             items: [
//               BottomNavigationBarItem(
//                 icon: const Icon(Icons.home),
//                 label: BottomNavigationStrings.getString(
//                   'home',
//                   languageController.isToggled.value,
//                 ),
//               ),
//               BottomNavigationBarItem(
//                 icon: const Icon(Icons.support_agent_outlined),
//                 label: BottomNavigationStrings.getString(
//                   'customerCare',
//                   languageController.isToggled.value,
//                 ),
//               ),
//               BottomNavigationBarItem(
//                 icon: const Icon(Icons.edit_document),
//                 label: BottomNavigationStrings.getString(
//                   'myOrder',
//                   languageController.isToggled.value,
//                 ),
//               ),
//               BottomNavigationBarItem(
//                 icon: const Icon(Icons.person),
//                 label: BottomNavigationStrings.getString(
//                   'myProfile',
//                   languageController.isToggled.value,
//                 ),
//               ),
//               BottomNavigationBarItem(
//                 icon: Stack(
//                   alignment: Alignment.center,
//                   children: [
//                     // Icon(Icons.person),
//                     Image.asset(
//                       'assets/images/package.png',
//                       width: 21,
//                       height: 22,
//                     ),
//                   ],
//                 ),
//                 label: BottomNavigationStrings.getString(
//                   'Package',
//                   languageController.isToggled.value,
//                 ),
//               ),
//               // BottomNavigationBarItem(
//               //   icon: const Icon(Icons.person),
//               //   label: BottomNavigationStrings.getString(
//               //     'package',
//               //     languageController.isToggled.value,
//               //   ),
//               // ),
//             ],
//             currentIndex: _selectedIndex,
//             selectedItemColor: Colorfile.bordertheme,
//             unselectedItemColor: Colorfile.lightgrey,
//             onTap: _onItemTapped,
//             showUnselectedLabels: true,
//             showSelectedLabels: true,
//             backgroundColor: Colors.transparent,
//             elevation: 0,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildNoDataScreen() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.inbox, size: 80, color: Colors.grey.shade400),
//           const SizedBox(height: 16),
//           Text(
//             languageController.isToggled.value
//                 ? "कोणत्याही ऑर्डर सापडल्या नाहीत"
//                 : "No Orders Found",
//             style: AppFontStyle2.blinker(
//               fontSize: 20,
//               fontWeight: FontWeight.w500,
//               color: Colors.grey.shade600,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             languageController.isToggled.value
//                 ? "असे दिसते की दाखवण्यासाठी कोणत्याही ऑर्डर नाहीत."
//                 : "It seems there are no orders to display.",
//             style: AppFontStyle2.blinker(
//               fontSize: 14,
//               color: Colors.grey.shade500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 1.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 120,
//             child: Text(
//               label,
//               style: AppFontStyle2.blinker(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w400,
//                 color: const Color(0xFF36322E),
//               ),
//               textAlign: TextAlign.left,
//             ),
//           ),
//           const Text(":", style: TextStyle(fontSize: 16)),
//           const SizedBox(width: 4),
//           Expanded(
//             child: Text(
//               value,
//               style: AppFontStyle2.blinker(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w400,
//                 color: const Color(0xFF36322E),
//               ),
//               softWrap: true,
//               textAlign: TextAlign.left,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../colors/custom_color.dart';
import '../colors/order_fonts.dart';
import '../controller/order/my_order_controller.dart';
import '../controller/order/language controller.dart';
import '../customfiles/bottom_navigation_controller.dart';
import '../customfiles/custom_bottom_navigation_bar.dart';
import '../homepage.dart';
import '../language/hindi.dart';
import '../no internet.dart';
import '../profile/profile.dart';
import 'order_detail.dart';
import '../My_package/package_details_new.dart';

class MyOrderScreen extends StatefulWidget {
  final String? customer_id;
  final String? package_id;
  const MyOrderScreen({this.customer_id, super.key, this.package_id});

  @override
  State<MyOrderScreen> createState() => _MyOrderScreenState();
}

class _MyOrderScreenState extends State<MyOrderScreen> {
  final BottomNavigationController navigationController =
      Get.find<BottomNavigationController>();
  final OrderController orderController = Get.find<OrderController>();
  final LanguageController languageController = Get.find<LanguageController>();
  final ScrollController _scrollController = ScrollController();
  bool hasConnection = true;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  int _selectedIndex = 2;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initConnectivity();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 100 &&
          !orderController.isLoadingMore.value &&
          hasConnection) {
        orderController.loadMoreOrders(
          isToggled: languageController.isToggled.value,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  void _initConnectivity() {
    _checkConnectivity().then((isConnected) {
      if (!mounted) return;
      setState(() {
        hasConnection = isConnected;
      });
      if (isConnected) {
        orderController.refreshOrders(
          isToggled: languageController.isToggled.value,
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NoInternetPage()),
        ).then((result) {
          if (!mounted) return;
          if (result == true) {
            setState(() {
              hasConnection = true;
            });
            orderController.refreshOrders(
              isToggled: languageController.isToggled.value,
            );
          }
        });
      }
    });

    // _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
    //   ConnectivityResult result,
    // ) {
    //   _checkConnectivity().then((isConnected) {
    //     if (!mounted) return;
    //     if (isConnected != hasConnection) {
    //       setState(() {
    //         hasConnection = isConnected;
    //       });
    //       if (isConnected) {
    //         orderController.refreshOrders(
    //           isToggled: languageController.isToggled.value,
    //         );
    //         if (ModalRoute.of(context)?.settings.name == '/no_internet') {
    //           Navigator.pop(context, true);
    //         }
    //       } else if (ModalRoute.of(context)?.settings.name != '/no_internet') {
    //         Navigator.push(
    //           context,
    //           MaterialPageRoute(builder: (context) => NoInternetPage()),
    //         ).then((result) {
    //           if (!mounted) return;
    //           if (result == true) {
    //             setState(() {
    //               hasConnection = true;
    //             });
    //             orderController.refreshOrders(
    //               isToggled: languageController.isToggled.value,
    //             );
    //           }
    //         });
    //       }
    //     }
    //   });
    // });
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
      ).timeout(Duration(seconds: 5));
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
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Map<String, dynamic> getStatusDetails(String leadStatus, bool isToggled) {
    final Map<String, Map<String, Map<String, String>>> statusTranslations = {
      "0": {
        "en": {"text": "Pending"},
        "local": {"text": "प्रलंबित"},
      },
      "1": {
        "en": {"text": "Order Confirmed"},
        "local": {"text": "ऑर्डर पुष्ट"},
      },
      "2": {
        "en": {"text": "Approved"},
        "local": {"text": "मान्य"},
      },
      "3": {
        "en": {"text": "Rejected"},
        "local": {"text": "नाकारले"},
      },
    };

    final language = isToggled ? 'local' : 'en';
    final status = statusTranslations[leadStatus] ??
        {
          "en": {"text": "Unknown"},
          "local": {"text": "अज्ञात"},
        };

    switch (leadStatus) {
      case "0":
        return {
          "text": status[language]!["text"],
          "color": Colors.orange.shade100,
          "textColor": const Color(0xFFEA580C),
        };
      case "1":
        return {
          "text": status[language]!["text"],
          "color": Colors.green.shade100,
          "textColor": const Color(0xFF149845),
        };
      case "2":
        return {
          "text": status[language]!["text"],
          "color": Colors.green.shade100,
          "textColor": const Color(0xFF149845),
        };
      case "3":
        return {
          "text": status[language]!["text"],
          "color": Colors.red.shade100,
          "textColor": const Color(0xFFD32F2F),
        };
      default:
        return {
          "text": status[language]!["text"],
          "color": Colors.grey.shade100,
          "textColor": Colors.grey,
        };
    }
  }

  // void _showFilterDialog() {
  //   String? selectedId;
  //   String? selectedType;

  //   Get.dialog(
  //     AlertDialog(
  //       title: Text(
  //         languageController.isToggled.value
  //             ? 'ऑर्डर फिल्टर करा'
  //             : 'Filter Orders',
  //         style: AppFontStyle2.blinker(
  //           fontSize: 18,
  //           fontWeight: FontWeight.w500,
  //         ),
  //       ),
  //       content: DropdownSearch<String>(
  //         popupProps: PopupProps.menu(
  //           showSearchBox: true,
  //           searchFieldProps: TextFieldProps(
  //             decoration: InputDecoration(
  //               labelText:
  //                   languageController.isToggled.value
  //                       ? 'सेवा शोधा'
  //                       : 'Search Service',
  //               border: OutlineInputBorder(
  //                 borderRadius: BorderRadius.circular(8),
  //               ),
  //             ),
  //           ),
  //         ),
  //         items:
  //             orderController.packageService
  //                 .map((item) {
  //                   if (item.serviceName != null &&
  //                       item.serviceName!.isNotEmpty) {
  //                     return languageController.isToggled.value &&
  //                             item.serviceNameInLocalLanguage != null &&
  //                             item.serviceNameInLocalLanguage!.isNotEmpty
  //                         ? item.serviceNameInLocalLanguage!
  //                         : item.serviceName!;
  //                   }
  //                   return 'Unknown';
  //                 })
  //                 .toSet()
  //                 .toList(),
  //         onChanged: (value) {
  //           final selectedItem = orderController.packageService.firstWhere((
  //             item,
  //           ) {
  //             if (item.serviceName != null && item.serviceName!.isNotEmpty) {
  //               return (languageController.isToggled.value &&
  //                       item.serviceNameInLocalLanguage != null &&
  //                       item.serviceNameInLocalLanguage!.isNotEmpty
  //                   ? item.serviceNameInLocalLanguage == value
  //                   : item.serviceName == value);
  //             }
  //             return false;
  //           }, orElse: () => orderController.packageService[0]);

  //           if (selectedItem.serviceName != null &&
  //               selectedItem.serviceName!.isNotEmpty) {
  //             selectedId = selectedItem.id;
  //             selectedType = 'service';
  //           }

  //           log('Selected: $value, ID: $selectedId, Type: $selectedType');
  //         },
  //         dropdownDecoratorProps: DropDownDecoratorProps(
  //           dropdownSearchDecoration: InputDecoration(
  //             labelText:
  //                 languageController.isToggled.value
  //                     ? 'सेवा निवडा'
  //                     : 'Select Service',
  //             border: OutlineInputBorder(
  //               borderRadius: BorderRadius.circular(8),
  //             ),
  //           ),
  //         ),
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Get.back(),
  //           child: Text(
  //             languageController.isToggled.value ? 'रद्द करा' : 'Cancel',
  //             style: AppFontStyle2.blinker(color: Colors.grey),
  //           ),
  //         ),
  //         TextButton(
  //           onPressed: () {
  //             if (selectedId != null && selectedType != null) {
  //               orderController.offset.value = 0;
  //               orderController.allOrders.clear();
  //               if (selectedType == 'service') {
  //                 orderController.fetchOrders(
  //                   customOffset: 0,
  //                   serviceId: selectedId,
  //                   isToggled: languageController.isToggled.value,
  //                 );
  //               }
  //             }
  //             Get.back();
  //           },
  //           child: Text(
  //             languageController.isToggled.value ? 'लागू करा' : 'Apply',
  //             style: AppFontStyle2.blinker(color: Colors.blue),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  void _showFilterDialog() {
    Get.dialog(
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          String? selectedServiceId;

          return AlertDialog(
            title: Text(
              languageController.isToggled.value
                  ? 'सेवा फिल्टर करा'
                  : 'Filter Orders by Service',
              style: AppFontStyle.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            content: Obx(
              () => orderController.packageService.isEmpty
                  ? const Text(
                      'No services available to filter.',
                      style: TextStyle(fontSize: 16),
                    )
                  : DropdownSearch<String>(
                      popupProps: PopupProps.menu(
                        showSearchBox: true,
                        searchFieldProps: TextFieldProps(
                          decoration: InputDecoration(
                            labelText: languageController.isToggled.value
                                ? 'सेवा शोधा'
                                : 'Search Service',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      items: orderController.packageService
                          .where(
                            (item) =>
                                item.id != null &&
                                item.serviceName != null &&
                                item.serviceName!.isNotEmpty,
                          )
                          .map(
                            (item) => languageController.isToggled.value &&
                                    item.serviceNameInLocalLanguage != null &&
                                    item.serviceNameInLocalLanguage!.isNotEmpty
                                ? item.serviceNameInLocalLanguage!
                                : item.serviceName!,
                          )
                          .toSet()
                          .toList(),
                      onChanged: (String? value) {
                        if (value == null) {
                          setState(() {
                            selectedServiceId = null;
                          });
                          return;
                        }

                        final selectedService =
                            orderController.packageService.firstWhere(
                          (item) =>
                              item.id != null &&
                              (languageController.isToggled.value &&
                                          item.serviceNameInLocalLanguage !=
                                              null &&
                                          item.serviceNameInLocalLanguage!
                                              .isNotEmpty
                                      ? item.serviceNameInLocalLanguage
                                      : item.serviceName) ==
                                  value,
                          orElse: () =>
                              orderController.packageService.firstWhere(
                            (item) => item.id != null,
                            orElse: () {
                              print(
                                'No valid service found for value: $value',
                              );
                              return orderController.packageService.first;
                            },
                          ),
                        );

                        setState(() {
                          selectedServiceId = selectedService.id;
                        });

                        print(
                          'Selected Service: $value, ID: $selectedServiceId',
                        );
                      },
                      dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          labelText: languageController.isToggled.value
                              ? 'सेवा निवडा'
                              : 'Select Service',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  languageController.isToggled.value ? 'रद्द करा' : 'Cancel',
                  style: AppFontStyle.poppins(color: Colors.grey),
                ),
              ),
              TextButton(
                onPressed: () {
                  if (!hasConnection) {
                    _showNoInternetPopup();
                    Get.back();
                    return;
                  }

                  orderController.offset.value = 0;
                  orderController.allOrders.clear();

                  print(
                    'Fetching orders with serviceId: $selectedServiceId, customerId: ${widget.customer_id}',
                  );
                  orderController
                      .fetchOrders(
                    customerId: widget.customer_id,
                    customOffset: 0,
                    serviceId: selectedServiceId,
                    isToggled: languageController.isToggled.value,
                  )
                      .then((_) {
                    print(
                      'Orders fetched: ${orderController.allOrders.length}',
                    );
                    if (orderController.allOrders.isEmpty) {
                      print(
                        'No orders found for serviceId: $selectedServiceId',
                      );
                      _scaffoldMessengerKey.currentState?.showSnackBar(
                        SnackBar(
                          content: Text(
                            languageController.isToggled.value
                                ? 'या सेवेसाठी कोणतीही ऑर्डर सापडली नाही'
                                : 'No orders found for this service',
                            style: AppFontStyle.poppins(
                              color: Colors.white,
                            ),
                          ),
                          backgroundColor: Colors.orange,
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }
                  }).catchError((error) {
                    print('Error fetching orders: $error');
                    _scaffoldMessengerKey.currentState?.showSnackBar(
                      SnackBar(
                        content: Text(
                          languageController.isToggled.value
                              ? 'ऑर्डर लोड करताना त्रुटी'
                              : 'Error loading orders',
                          style: AppFontStyle.poppins(color: Colors.white),
                        ),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  });

                  Get.back();
                },
                child: Text(
                  languageController.isToggled.value ? 'लागू करा' : 'Apply',
                  style: AppFontStyle.poppins(color: Colors.blue),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage2(customer_id: '', customerId: ''),
          ),
        );
        break;
      case 1:
        print("Customer Care tapped");
        break;
      case 2:
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
            builder: (context) => PackageScreen(
              customerId: '',
              package_id: '',
              tbl_name: '',
              customerid: '',
            ),
          ),
        );

        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        appBar: AppBar(
          title: Obx(
            () => Text(
              languageController.isToggled.value ? "माझी ऑर्डर" : "My Order",
              style: AppFontStyle2.blinker(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF36322E),
                fontSize: 18,
              ),
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.filter_list,
                color: hasConnection ? Colors.black : Colors.grey,
              ),
              onPressed: hasConnection
                  ? _showFilterDialog
                  : () {
                      _showNoInternetPopup();
                    },
            ),
          ],
        ),
        backgroundColor: const Color(0xFFF8F8F8),
        body: RefreshIndicator(
          onRefresh: () async {
            if (!hasConnection) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NoInternetPage()),
              ).then((result) {
                if (!mounted) return;
                if (result == true) {
                  setState(() {
                    hasConnection = true;
                  });
                  orderController.refreshOrders(
                    isToggled: languageController.isToggled.value,
                  );
                }
              });
              return;
            }
            await orderController.refreshOrders(
              isToggled: languageController.isToggled.value,
            );
          },
          child: Obx(
            () => hasConnection
                ? orderController.isLoading.value &&
                        orderController.allOrders.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : orderController.allOrders.isEmpty
                        ? _buildNoDataScreen()
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(20),
                            itemCount: orderController.allOrders.length +
                                (orderController.isLoadingMore.value ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == orderController.allOrders.length &&
                                  orderController.isLoadingMore.value) {
                                return const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }

                              final order = orderController.allOrders[index];
                              final statusDetails = getStatusDetails(
                                order.leadStatus,
                                languageController.isToggled.value,
                              );

                              return Container(
                                margin: const EdgeInsets.only(bottom: 15),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "${languageController.isToggled.value ? 'ऑर्डर आयडी' : 'Order ID'} : ${order.id}",
                                          style: AppFontStyle2.blinker(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 17,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: statusDetails["color"],
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            statusDetails["text"],
                                            style: AppFontStyle2.blinker(
                                              color: statusDetails["textColor"],
                                              fontWeight: FontWeight.w500,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    _buildRow(
                                      languageController.isToggled.value
                                          ? (order.package_name.isNotEmpty
                                              ? "पॅकेज नाव"
                                              : "सेवा नाव")
                                          : (order.package_name.isNotEmpty
                                              ? "Package Name"
                                              : "Service Name"),
                                      order.package_name.isNotEmpty
                                          ? (languageController.isToggled.value
                                              ? order.package_name_in_local_language
                                                      .isNotEmpty
                                                  ? order
                                                      .package_name_in_local_language
                                                  : order.package_name
                                              : order.package_name)
                                          : (order.serviceNameLocal != null &&
                                                  languageController
                                                      .isToggled.value
                                              ? order.serviceNameLocal!
                                              : localizationOrderdetailsStrings
                                                  .getServiceName(
                                                  order.serviceName,
                                                  languageController
                                                      .isToggled.value,
                                                )),
                                    ),
                                    if (order.leadStatus == "1" ||
                                        order.leadStatus == "3")
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.yellow.shade50,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          languageController.isToggled.value
                                              ? "टीप: तुमची ऑर्डर प्रक्रियेत आहे. ती पुष्ट झाल्यावर आम्ही तुम्हाला सूचित करू. तुमच्या संयमाबद्दल धन्यवाद!"
                                              : "Note: Your order is being processed. We will notify you once it is confirmed. Thank you for your patience!",
                                          style: AppFontStyle2.blinker(
                                            fontSize: 11,
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    if (order.leadStatus == "2")
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: SizedBox(
                                          width: double.infinity,
                                          child: OutlinedButton(
                                            onPressed: () {
                                              print(order.id);
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      OrderDetail(
                                                    order: {
                                                      "orderId": order.id,
                                                      "serviceName": order
                                                                      .serviceNameLocal !=
                                                                  null &&
                                                              languageController
                                                                  .isToggled
                                                                  .value
                                                          ? order
                                                              .serviceNameLocal!
                                                          : localizationOrderStrings
                                                              .getServiceName(
                                                              order.serviceName,
                                                              languageController
                                                                  .isToggled
                                                                  .value,
                                                            ),
                                                      "status":
                                                          statusDetails["text"],
                                                      "customerId":
                                                          orderController
                                                              .customerId.value,
                                                      "tbl_name": order.tblName,
                                                    },
                                                    customerid: '',
                                                    package_Id: '',
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Text(
                                              languageController.isToggled.value
                                                  ? 'तपशील पहा'
                                                  : 'View Details',
                                              style: AppFontStyle2.blinker(
                                                color: const Color(0xFF36322E),
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            style: OutlinedButton.styleFrom(
                                              side: const BorderSide(
                                                color: Color(0xFF36322E),
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                vertical: 10,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          )
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: Center(child: CircularProgressIndicator()),
                    ),
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
                //   icon: const Icon(Icons.person),
                //   label: BottomNavigationStrings.getString(
                //     'package',
                //     languageController.isToggled.value,
                //   ),
                // ),

                BottomNavigationBarItem(
                  icon: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        'assets/images/packageicon.png',
                        width: 21,
                        height: 22,
                      ),
                    ],
                  ),
                  label: BottomNavigationStrings.getString(
                    'Package',
                    languageController.isToggled.value,
                  ),
                ),
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

  Widget _buildNoDataScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            languageController.isToggled.value
                ? "कोणत्याही ऑर्डर सापडल्या नाहीत"
                : "No Orders Found",
            style: AppFontStyle2.blinker(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            languageController.isToggled.value
                ? "असे दिसते की दाखवण्यासाठी कोणत्याही ऑर्डर नाहीत."
                : "It seems there are no orders to display.",
            style: AppFontStyle2.blinker(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppFontStyle2.blinker(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF36322E),
              ),
              textAlign: TextAlign.left,
            ),
          ),
          const Text(":", style: TextStyle(fontSize: 16)),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              value,
              style: AppFontStyle2.blinker(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF36322E),
              ),
              softWrap: true,
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }
}
