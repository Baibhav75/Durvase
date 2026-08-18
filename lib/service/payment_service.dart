import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter/foundation.dart';

class PaymentService {
  final Razorpay _razorpay = Razorpay();

  // Test credentials provided by you
  final String keyId = "rzp_test_RUcfrMdneqFPri";
  final String keySecret = "n7Ry0yJlRlbr3OI0MqSNjMtA";

  void initialize({
    required void Function(PaymentSuccessResponse) onSuccess,
    required void Function(PaymentFailureResponse) onError,
    required void Function(ExternalWalletResponse) onWallet,
  }) {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, onSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, onError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, onWallet);
  }

  Future<void> openCheckout({
    required double amount,
    String name = "Durvasa Ayurved",
    String description = "Order Payment",
    String email = "test@gmail.com",
    String contact = "9999999999",
  }) async {
    int amountInPaise = (amount * 100).toInt();
    String? orderId;

    try {
      // GENERATING ORDER_ID DIRECTLY FROM APP FOR TESTING (Without Backend)
      // Razorpay enforces order_id for newer accounts even in test mode.
      final String basicAuth = 'Basic ${base64Encode(utf8.encode('$keyId:$keySecret'))}';
      
      final response = await http.post(
        Uri.parse('https://api.razorpay.com/v1/orders'),
        headers: {
          'Authorization': basicAuth,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "amount": amountInPaise,
          "currency": "INR",
          "receipt": "receipt_${DateTime.now().millisecondsSinceEpoch}",
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        orderId = data['id'];
        debugPrint("Successfully generated Razorpay Order ID: $orderId");
      } else {
        debugPrint("Failed to create Razorpay Order: ${response.body}");
      }
    } catch (e) {
      debugPrint("Error creating order: $e");
    }

    var options = {
      "key": keyId,
      "amount": amountInPaise,
      "currency": "INR",
      "name": name,
      "description": description,
      // Pass the dynamically created order_id to Razorpay options
      if (orderId != null) "order_id": orderId, 
      "prefill": {
        "contact": contact,
        "email": email,
      },
      "theme": {
        "color": "#673AB7", 
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint("Razorpay Error: $e");
    }
  }

  void dispose() {
    _razorpay.clear();
  }
}