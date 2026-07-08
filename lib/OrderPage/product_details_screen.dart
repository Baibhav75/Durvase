import 'package:flutter/material.dart';
import '../model/product_model.dart';
import '../service/Auth_servcie.dart';
import 'OrderSummaryScreen.dart';
import 'card_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String productId;
  final String productName;
  final String userId;


  const ProductDetailsScreen({
    super.key,
    required this.productId,
    required this.productName,
    required this.userId,

  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  late Future<ProductDetailsData?> _productDetailsFuture;
  final PageController _pageController = PageController();

  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _fetchProductDetails();
  }

  void _fetchProductDetails() {
    _productDetailsFuture = AuthService().getProductDetails(widget.productId);
  }

  int _calculateDiscount(String mrpStr, String sellingStr) {
    try {
      double mrp = double.parse(mrpStr);
      double selling = double.parse(sellingStr);
      if (mrp > 0 && mrp > selling) {
        return (((mrp - selling) / mrp) * 100).round();
      }
    } catch (e) {
      // Ignore parse errors
    }
    return 0;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          widget.productName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[700],
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.shopping_cart,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CartScreen(),
                ),
              ).then((_) {
                // Refresh ProductDetailsScreen when returning
                setState(() {});
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<ProductDetailsData?>(
        future: _productDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  const Text(
                    'Failed to load details',
                    style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _fetchProductDetails();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          final product = snapshot.data!;
          int discount = _calculateDiscount(product.mrp, product.sellingPrice);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Header
                Container(
                  color: Colors.white,
                  width: double.infinity,
                  height: 300,
              child: Builder(
                builder: (context) {

                  final images = [
                    product.image1,
                    product.image2,
                    product.image3,
                    product.image4,
                    product.image5,
                  ]
                      .where((e) => e != null && e.toString().isNotEmpty)
                      .cast<String>()
                      .toList();

                  return Column(
                    children: [

                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: images.length,
                          onPageChanged: (index) {
                            setState(() {
                              _currentPage = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            return InteractiveViewer(
                              child: Image.network(
                                "https://durvasaayurved.com${images[index]}",
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) =>
                                const Icon(Icons.image_not_supported, size: 100),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          images.length,
                              (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentPage == index ? 20 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? Colors.blue
                                  : Colors.grey.shade400,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                    ],
                  );
                },
              ),

                ),
                const SizedBox(height: 16),

                // Product Info
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.productName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Category: ${product.categoryName} > ${product.subCategoryName}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Unit: ${product.unit}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Price Section
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '₹${product.sellingPrice}',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (discount > 0) ...[
                            Text(
                              '₹${product.mrp}',
                              style: TextStyle(
                                fontSize: 16,
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey[500],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.green),
                              ),
                              child: Text(
                                '$discount% OFF',
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ]
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Description
                if (product.description != null && product.description!.isNotEmpty) ...[
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Product Description',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          product.description!,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[800],
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 100), // padding for bottom bar
              ],
            ),
          );
        },
      ),
      bottomSheet: FutureBuilder<ProductDetailsData?>(
        future: _productDetailsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return const SizedBox.shrink();
          }
          final product = snapshot.data!;
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child:Row(
              children: [

                Expanded(
                  child: SizedBox(
                    height: 55,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.shopping_cart),
                      label: Text(
                        globalCartItems.any(
                              (item) => item['productId'] == product.productId,
                        )
                            ? "GO TO CART"
                            : "ADD TO CART",
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.deepPurple,
                        side: const BorderSide(color: Colors.deepPurple),
                      ),
                      onPressed: () {

                        bool inCart = globalCartItems.any(
                              (item) => item['productId'] == product.productId,
                        );

                        if (inCart) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CartScreen(),
                            ),
                          );
                          return;
                        }

                        globalCartItems.add({
                          "productId": product.productId,
                          "name": product.productName,
                          "price": double.tryParse(product.sellingPrice) ?? 0,
                          "mrp": double.tryParse(product.mrp) ?? 0,
                          "qty": 1,
                          "image":
                          "https://durvasaayurved.online${product.image1}",
                        });

                        setState(() {});
                      },
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: SizedBox(
                    height: 55,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.flash_on),
                      label: const Text("BUY NOW"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {

                        if (!globalCartItems.any(
                                (item) => item['productId'] == product.productId)) {

                          globalCartItems.add({
                            "productId": product.productId,
                            "name": product.productName,
                            "price": double.tryParse(product.sellingPrice) ?? 0,
                            "mrp": double.tryParse(product.mrp) ?? 0,
                            "qty": 1,
                            "image":
                            "https://durvasaayurved.online${product.image1}",
                          });

                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>  OrderSummaryScreen( userId: widget.userId),
                          ),
                        );

                      },
                    ),
                  ),
                ),

              ],
            ),
          );
        },
      ),
    );
  }
}
