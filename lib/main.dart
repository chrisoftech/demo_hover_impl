import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController amountController = TextEditingController();

  final PermissionHandler _permissionHandler = PermissionHandler();

  static const platform = const MethodChannel('samples.flutter.dev/battery');
  static const _hover = const MethodChannel('samples.flutter.dev/hover');

  // Get battery level.
  String _batteryLevel = 'Unknown battery level.';
  String _responseFromNativeCode = 'Waiting for response';

  String _errorMessage = '';

  String _amount = '';
  String _currentBalance = '';
  String _availableBalance = '';
  String _reference = '';
  String _transactionId = '';
  String _feeCharged = '';

  Future<PermissionStatus> _requestAndGetPermission(
    PermissionGroup permissionGroup,
  ) async {
    PermissionStatus _permission =
        await _permissionHandler.checkPermissionStatus(permissionGroup);
    if (_permission != PermissionStatus.granted &&
        _permission != PermissionStatus.restricted) {
      Map<PermissionGroup, PermissionStatus> permissionStatus =
          await _permissionHandler.requestPermissions([permissionGroup]);
      return permissionStatus[permissionGroup] ?? PermissionStatus.unknown;
    } else {
      return _permission;
    }
  }

  String _handleInvalidPermissions(
    PermissionStatus permissionStatus,
  ) {
    if (permissionStatus == PermissionStatus.denied) {
      return 'PERMISSION_DENIED';
    } else if (permissionStatus == PermissionStatus.restricted) {
      return 'PERMISSION_DISABLED';
    } else {
      return 'UNDEFINED_ERROR';
    }
  }

  Future<dynamic> sendMoneyToIndividual(
      String phoneNumber, String amount) async {
    var sendMap = <String, dynamic>{
      'phoneNumber': phoneNumber,
      'amount': amount,
      'reference': 'Sent $amount to $phoneNumber',
    };
// response waits for result from java code
    String response = "";
    try {
      final _contactAccessPermissionStatus =
          await _requestAndGetPermission(PermissionGroup.phone);

      if (_contactAccessPermissionStatus == PermissionStatus.granted) {
        final _result =
            await _hover.invokeMethod('sendMoneyToIndividual', sendMap);

        print('RESULT DART $_result');

        if (_result != null) {
          final _jsonResult = json.decode(_result);

          if (_jsonResult['STATUS'] == 'succeeded') {
            _amount = _jsonResult['AMOUNT'];
            _currentBalance = _jsonResult['CURRENT_BALANCE'];
            _availableBalance = _jsonResult['AVAILABLE_BALANCE'];
            _reference = _jsonResult['REFERENCE'];
            _transactionId = _jsonResult['TRANSACTION_ID'];
            _feeCharged = _jsonResult['FEE_CHARGED'];
          } else if (_jsonResult['STATUS'] == 'failed') {
            _errorMessage = _jsonResult['MESSAGE'];
          } else {
            _errorMessage = 'No status returned :: Pending';
          }
        }

        // response = _result;
      } else {
        response = _handleInvalidPermissions(_contactAccessPermissionStatus);
      }

      // final String result =
      //     await _hover.invokeMethod('sendMoneyToIndividual', sendMap);
      // response = result;
    } on PlatformException catch (e) {
      response = "Failed to Invoke: '${e.message}'.";
    }
    setState(() {
      _responseFromNativeCode = response;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget _buildNumberTextField() {
      return Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
          child: TextFormField(
            inputFormatters: [
              LengthLimitingTextInputFormatter(10),
            ],
            controller: phoneNumberController,
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter phone number';
              }
              return null;
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Phone Number',
              hintText: '0241234567',
              // prefix: Text('+233 '),
              suffixIcon: Icon(Icons.dialpad),
            ),
            keyboardType: TextInputType.numberWithOptions(),
          ));
    }

    Widget _buildAmountTextField() {
      return Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
          child: TextFormField(
            controller: amountController,
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter amount';
              }
              return null;
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              prefix: Text('GHS '),
              labelText: 'Amount',
            ),
            keyboardType: TextInputType.numberWithOptions(),
          ));
    }

    Widget _buildTuma() {
      return Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              _buildNumberTextField(),
              _buildAmountTextField(),
              RaisedButton(
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    sendMoneyToIndividual(
                      phoneNumberController.text,
                      amountController.text,
                    );
                  }
                },
                child: Text("send Money"),
              ),
              Text(_amount),
              Text(_currentBalance),
              Text(_availableBalance),
              Text(_reference),
              Text(_transactionId),
              Text(_feeCharged),
            ],
          ));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _buildTuma(),
          ],
        ),
      ),
    );
  }
}
