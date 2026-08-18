import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'checkout_screen.dart';
import '../service/Auth_servcie.dart';
import '../service/session_manager.dart';
import '../service/api_serviceProfile.dart';
import '../model/order_summary_model.dart';

class OrderSummaryScreen extends StatefulWidget {
  final String userId;

  const OrderSummaryScreen({super.key, required this.userId});

  @override
  State<OrderSummaryScreen> createState() => _OrderSummaryScreenState();
}

class _OrderSummaryScreenState extends State<OrderSummaryScreen> {
  int _selectedPaymentMethod = 1;

  late Future<OrderSummaryResponse?> orderSummaryFuture;

  @override
  void initState() {
    super.initState();
    orderSummaryFuture = loadOrderSummary();
  }

  Future<OrderSummaryResponse?> loadOrderSummary() async {
    final loginData = await SessionManager.getLoginData();
    if (loginData == null || loginData.mobile == null) {
      throw Exception("Login not found");
    }

    final profile = await ApiService.fetchProfile(loginData.mobile!);
    if (profile == null) {
      throw Exception("Profile not found");
    }

    final employee = profile.firstEmployee;
    if (employee == null || employee.userId == null) {
      throw Exception("User ID not found in profile");
    }

    final trueUserId = employee.userId!;
    print("OrderSummary UserId : $trueUserId");

    return AuthService().getOrderSummary(trueUserId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          "Order Summary",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<OrderSummaryResponse?>(
        future: orderSummaryFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.deepPurple),
            );
          }

          if (snapshot.hasError || snapshot.data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    "Failed to load order summary",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        orderSummaryFuture = loadOrderSummary();
                      });
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                    child: Text("Retry", style: GoogleFonts.poppins(color: Colors.white)),
                  )
                ],
              ),
            );
          }

          final orderSummary = snapshot.data!;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Order Items",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Dynamic Products List from API
                  if (orderSummary.cartItems.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          "No items in summary",
                          style: GoogleFonts.poppins(color: Colors.grey.shade600),
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: orderSummary.cartItems.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = orderSummary.cartItems[index];
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  "https://durvasaayurved.online${item.image}",
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 70,
                                    height: 70,
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.image_not_supported, color: Colors.grey),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.productName,
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        "Qty: ${item.qty}",
                                        style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade800),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "₹${item.sellingPrice}",
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                      color: Colors.green.shade600,
                                    ),
                                  ),
                                  if (item.listedPrice > item.sellingPrice)
                                    Text(
                                      "₹${item.listedPrice}",
                                      style: GoogleFonts.poppins(
                                        decoration: TextDecoration.lineThrough,
                                        fontSize: 12,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 24),
                  Text(
                    "Payment Method",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Payment
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        RadioListTile<int>(
                          value: 1,
                          groupValue: _selectedPaymentMethod,
                          activeColor: Colors.deepPurple,
                          onChanged: (v) => setState(() => _selectedPaymentMethod = v!),
                          title: Text("Cash on Delivery", style: GoogleFonts.poppins()),
                        ),
                        RadioListTile<int>(
                          value: 2,
                          groupValue: _selectedPaymentMethod,
                          activeColor: Colors.deepPurple,
                          onChanged: (v) => setState(() => _selectedPaymentMethod = v!),
                          title: Text("UPI", style: GoogleFonts.poppins()),
                        ),
                        RadioListTile<int>(
                          value: 3,
                          groupValue: _selectedPaymentMethod,
                          activeColor: Colors.deepPurple,
                          onChanged: (v) => setState(() => _selectedPaymentMethod = v!),
                          title: Text("Credit / Debit Card", style: GoogleFonts.poppins()),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  Text(
                    "Price Details",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Price Details
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _row("Listed Price", "₹${orderSummary.summary.listedTotal}"),
                        const SizedBox(height: 10),
                        _row("Selling Price", "₹${orderSummary.summary.sellingTotal}"),
                        const SizedBox(height: 10),
                        if (orderSummary.summary.discount > 0) ...[
                          _row("Discount", "- ₹${orderSummary.summary.discount}", isDiscount: true),
                          const SizedBox(height: 10),
                        ],
                        _row("Delivery Charges", "FREE", isDiscount: true),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Divider(height: 1, thickness: 1),
                        ),
                        _row("Total Amount", "₹${orderSummary.summary.finalTotal}", isTotal: true),
                      ],
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          );
        },
      ),
      bottomSheet: FutureBuilder<OrderSummaryResponse?>(
        future: orderSummaryFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return const SizedBox.shrink();
          }

          final summary = snapshot.data!.summary;

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Total Amount",
                          style: GoogleFonts.poppins(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          "₹${summary.finalTotal}",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          // Note: In your previous change you made Checkout push OrderSummary, 
                          // and here OrderSummary pushes Checkout. This might be a loop,
                          // but I am keeping your button text as you requested to place the order
                          // or proceed to checkout.
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CheckoutScreen(userId: widget.userId),
                            ),
                          );
                        },
                        child: Text(
                          "CHECKOUT", // or PLACE ORDER if they prefer
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _row(String title, String value, {bool isTotal = false, bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
            fontSize: isTotal ? 16 : 14,
            color: isTotal ? Colors.black87 : Colors.grey.shade700,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            fontSize: isTotal ? 18 : 15,
            color: isDiscount ? Colors.green : (isTotal ? Colors.deepPurple : Colors.black87),
          ),
        ),
      ],
    );
  }
}