import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../service/session_manager.dart';
import '../service/api_serviceProfile.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

// Global cart items list (kept for compatibility if used elsewhere)
List<Map<String, dynamic>> globalCartItems = [];

class _CartScreenState extends State<CartScreen> {
  List<dynamic> apiCartItems = [];
  bool isLoading = true;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    _fetchCartData();
  }

  Future<void> _fetchCartData() async {
    setState(() {
      isLoading = true;
      errorMessage = "";
    });

    try {
      final loginData = await SessionManager.getLoginData();
      if (loginData != null && loginData.mobile != null) {
        final profileData = await ApiService.fetchProfile(loginData.mobile!);
        if (profileData != null && profileData.data1 != null && profileData.data1!.isNotEmpty) {
          final userId = profileData.data1!.first.userId;
          if (userId != null) {
            final response = await http.get(Uri.parse(
                'https://durvasaayurved.com/api/GetCart/Cart?UserId=$userId'));
            if (response.statusCode == 200) {
              final jsonResponse = jsonDecode(response.body);
              if (jsonResponse['status'] == true &&
                  jsonResponse['data'] != null) {
                setState(() {
                  apiCartItems = jsonResponse['data'];
                });
              } else {
                setState(() {
                  errorMessage =
                      jsonResponse['message'] ?? 'Failed to load cart';
                  apiCartItems = [];
                });
              }
            } else {
              setState(() {
                errorMessage = "Server error: ${response.statusCode}";
              });
            }
          } else {
            setState(() {
              errorMessage = "User ID not found";
            });
          }
        } else {
          setState(() {
            errorMessage = "Profile data not found";
          });
        }
      } else {
        setState(() {
          errorMessage = "User not logged in";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error: $e";
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  double get totalPrice {
    double total = 0;
    for (var item in apiCartItems) {
      double price = (item["SellingPrice"] ?? 0).toDouble();
      int qty = item["QTY"] ?? 1;
      total += price * qty;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("My Cart"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchCartData,
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty && apiCartItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        errorMessage,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchCartData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : apiCartItems.isEmpty
                  ? const Center(
                      child: Text(
                        "Your cart is empty",
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: apiCartItems.length,
                            itemBuilder: (context, index) {
                              final item = apiCartItems[index];

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(
                                          item["Image"] != null
                                              ? 'https://durvasaayurved.com${item["Image"]}'
                                              : '',
                                          width: 90,
                                          height: 90,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error,
                                                  stackTrace) =>
                                              const Icon(
                                                  Icons.image_not_supported,
                                                  size: 50,
                                                  color: Colors.grey),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item["ProductName"] ?? 'Unknown',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Text(
                                                  "₹${item["SellingPrice"]}",
                                                  style: const TextStyle(
                                                    color: Colors.green,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  "₹${item["ListedPrice"]}",
                                                  style: const TextStyle(
                                                    decoration: TextDecoration
                                                        .lineThrough,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            Row(
                                              children: [
                                                const Text(
                                                  "Qty: ",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                Text(
                                                  "${item["QTY"] ?? 1}",
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 5,
                                color: Colors.black12,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    "Total",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    "₹${totalPrice.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.deepPurple,
                                  ),
                                  onPressed: () {},
                                  child: const Text(
                                    "Proceed to Checkout",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
    );
  }
}