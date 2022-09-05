// ignore_for_file: avoid_print, unused_field, unrelated_type_equality_checks, unnecessary_new, prefer_typing_uninitialized_variables, unnecessary_string_interpolations, unnecessary_null_comparison, prefer_const_constructors

import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:v2rp1/BE/controller.dart';
import 'package:v2rp1/BE/reqip.dart';
import 'package:v2rp1/BE/resD.dart';
import 'package:v2rp1/FE/VB/vendor_scanner.dart';
import 'package:v2rp1/FE/navbar/navbar.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

class VendorBarcode1 extends StatefulWidget {
  const VendorBarcode1({Key? key}) : super(key: key);

  @override
  State<VendorBarcode1> createState() => _VendorBarcode1State();
}

class _VendorBarcode1State extends State<VendorBarcode1> {
  static var hasilSearch;
  static var conve = MsgHeader.conve;
  static var trxid = MsgHeader.trxid;
  static var datetime = MsgHeader.datetime;
  static TextControllers textControllers = Get.put(TextControllers());
  // static var searchVal = textControllers.vendor1Controller.value.text;
  static var serverKeyValue;

  late List _dataaa = <ResultData>[];

  Future<String> getData() async {
    var searchValue = textControllers.vendor1Controller.value.text;
    var sendSearch = await http.post(Uri.https('www.v2rp.net', '/ptemp/'),
        headers: {'x-v2rp-key': '$conve'},
        body: jsonEncode({
          "trxid": "$trxid",
          "datetime": "$datetime",
          "reqid": "0002",
          "id": "$searchValue"
        }));
    // final resultDataa = resultDataFromMap(sendSearch.body);
    final resultData = json.decode(sendSearch.body);
    serverKeyValue = resultData['serverkey'];
    var responsecode = resultData['responsecode'];
    var responseMessage = resultData['message'];

    if (responsecode == '00') {
      setState(() {
        _dataaa = json.decode(sendSearch.body)['result'];
      });
    } else {
      Get.snackbar(
        'Failed!',
        '$responseMessage',
        icon: Icon(Icons.warning),
        backgroundColor: Colors.red,
        isDismissible: true,
        dismissDirection: DismissDirection.horizontal,
      );
      setState(() {
        _dataaa.clear();
      });
    }

    print(sendSearch.body);

    print(serverKeyValue);
    return "Successfull";
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    return WillPopScope(
      onWillPop: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Are You sure?'),
            content: const Text('Do you want to exit the App?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => SystemNavigator.pop(),
                child: const Text('Yes'),
              ),
            ],
          ),
        );
        throw (e);
      },
      child: isIOS
          ? CupertinoPageScaffold(
              navigationBar: CupertinoNavigationBar(
                transitionBetweenRoutes: true,
                middle: Text("Vendor Barcode"),
                leading: GestureDetector(
                  child: Icon(CupertinoIcons.back),
                  onTap: () {
                    Get.to(Navbar());
                  },
                ),
              ),
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        CupertinoSearchTextField(
                          controller: textControllers.vendor1Controller.value,
                          itemSize: 30,
                          itemColor: HexColor('#F4A62A'),
                          prefixInsets: EdgeInsets.only(left: 8, right: 8),
                          suffixInsets: EdgeInsets.only(right: 8),
                          // suffixMode: OverlayVisibilityMode.notEditing,
                          // suffixIcon: Icon(CupertinoIcons.search),
                          // onSuffixTap: () => Get.to(ScanFixAsset()),
                          onSubmitted: (value) {
                            searchProcess();
                            setState(() {
                              textControllers.vendor1Controller.value.clear();
                            });
                          },
                        ),
                        SizedBox(height: 10),
                        Divider(
                          color: Colors.black,
                        ),
                        SizedBox(height: 10),
                        Container(
                          height: MediaQuery.of(context).size.height * 0.8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: ListView.separated(
                            // shrinkWrap: true,
                            separatorBuilder: (context, index) {
                              return SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.01,
                              );
                            },
                            physics: const BouncingScrollPhysics(),
                            itemCount: _dataaa.length,
                            itemBuilder: (context, index) {
                              return Card(
                                elevation: 5,
                                child: ListTile(
                                  title: Text(
                                    _dataaa[index]['itemname'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(_dataaa[index]['stockid']),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.qr_code_2),
                                    onPressed: () {
                                      Get.to(ScanVb(
                                        idstock: _dataaa[index]['stockid'],
                                        itemname: _dataaa[index]['itemname'],
                                        serverKeyVal: serverKeyValue,
                                      ));
                                    },
                                    color: HexColor('#F4A62A'),
                                    hoverColor: HexColor('#F4A62A'),
                                    splashColor: HexColor('#F4A62A'),
                                  ),
                                  tileColor: Colors.white,
                                  textColor: Colors.black,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : Scaffold(
              appBar: AppBar(
                title: const Text("Vendor Barcode"),
                centerTitle: true,
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                elevation: 1,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Get.to(() => Navbar());
                  },
                ),
              ),
              body: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 16.0,
                    right: 16.0,
                    bottom: 0,
                    top: 15.0,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            'Vendor Barcode Registration',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      TextField(
                        controller: textControllers.vendor1Controller.value,
                        onSubmitted: (value) {
                          searchProcess();
                          setState(() {
                            textControllers.vendor1Controller.value.clear();
                          });
                        },
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.assignment),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.search),
                            color: HexColor('#F4A62A'),
                            onPressed: () async {},
                            splashColor: HexColor('#F4A62A'),
                            tooltip: 'Search',
                            hoverColor: HexColor('#F4A62A'),
                          ),
                          hintText: 'Stock Code / Stock Name',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide:
                                  const BorderSide(color: Colors.black)),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Divider(
                        color: Colors.black,
                        thickness: 0.8,
                        height: 25,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Item List'),
                          const SizedBox(height: 25.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.65,
                                child: ListView.separated(
                                  // shrinkWrap: true,
                                  separatorBuilder: (context, index) {
                                    return SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.01,
                                    );
                                  },
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: _dataaa.length,
                                  itemBuilder: (context, index) {
                                    return Card(
                                      elevation: 5,
                                      child: ListTile(
                                        title: Text(
                                          _dataaa[index]['itemname'],
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle:
                                            Text(_dataaa[index]['stockid']),
                                        trailing: IconButton(
                                          icon: const Icon(Icons.qr_code_2),
                                          onPressed: () {
                                            Get.to(ScanVb(
                                              idstock: _dataaa[index]
                                                  ['stockid'],
                                              itemname: _dataaa[index]
                                                  ['itemname'],
                                              serverKeyVal: serverKeyValue,
                                            ));
                                          },
                                          color: HexColor('#F4A62A'),
                                          hoverColor: HexColor('#F4A62A'),
                                          splashColor: HexColor('#F4A62A'),
                                        ),
                                        tileColor: Colors.white,
                                        textColor: Colors.black,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Future<void> searchProcess() async {
    var searchResult = textControllers.vendor1Controller.value.text;
    try {
      if (searchResult.length >= 3) {
        getData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.white,
            elevation: 10.0,
            shape: Border.all(
                color: const Color.fromARGB(255, 192, 0, 0),
                width: 0.5,
                style: BorderStyle.solid),
            content: const Text(
              "Please Enter Valid Stock Code / Item Name",
              style: TextStyle(
                color: Colors.black,
                fontSize: 16.0,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }
    } catch (e) {
      print(e);
    }
  }
}
