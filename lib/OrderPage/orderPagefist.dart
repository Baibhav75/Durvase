import 'package:flutter/material.dart';
import '../service/Auth_servcie.dart';
import '../model/getcategory_model.dart';
import 'sub_categories_page.dart';

class OrderPageFst extends StatefulWidget {
  const OrderPageFst({super.key});

  @override
  _OrderPageFstState createState() => _OrderPageFstState();
}

class _OrderPageFstState extends State<OrderPageFst> {
  Future<List<Category>>? _categoriesFuture;

  final List<Map<String, dynamic>> orders = [
    {
      'id': '#ORD-7842',
      'date': 'Nov 28, 2024',
      'status': 'Delivered',
      'statusColor': Colors.green,
      'items': 3,
      'total': 245.00,
      'itemsList': [
        {
          'name': 'Wireless Headphones',
          'price': 99.99,
          'quantity': 1,
          'image': '🎧',
        },
        {'name': 'Phone Case', 'price': 25.99, 'quantity': 2, 'image': '📱'},
      ],
    },
    {
      'id': '#ORD-7839',
      'date': 'Nov 25, 2024',
      'status': 'Processing',
      'statusColor': Colors.orange,
      'items': 2,
      'total': 156.50,
      'itemsList': [
        {'name': 'Smart Watch', 'price': 156.50, 'quantity': 1, 'image': '⌚'},
      ],
    },
    {
      'id': '#ORD-7835',
      'date': 'Nov 20, 2024',
      'status': 'Shipped',
      'statusColor': Colors.blue,
      'items': 4,
      'total': 342.75,
      'itemsList': [
        {'name': 'Laptop Bag', 'price': 89.99, 'quantity': 1, 'image': '💼'},
        {'name': 'USB Cable', 'price': 12.99, 'quantity': 3, 'image': '🔌'},
      ],
    },
    {
      'id': '#ORD-7828',
      'date': 'Nov 15, 2024',
      'status': 'Cancelled',
      'statusColor': Colors.red,
      'items': 1,
      'total': 45.00,
      'itemsList': [
        {'name': 'Mouse Pad', 'price': 45.00, 'quantity': 1, 'image': '🖱️'},
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _categoriesFuture = AuthService().getCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'My Orders',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blue[700],
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildHeaderStats(),
          ),
          SliverToBoxAdapter(
            child: _buildCategoriesSection(),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Recent Orders',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey[900],
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildOrderCard(orders[index]),
                childCount: orders.length,
              ),
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildHeaderStats() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[700],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Total Orders', '12', Icons.shopping_bag),
          _buildStatItem('Pending', '2', Icons.pending_actions),
          _buildStatItem('Delivered', '8', Icons.check_circle),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildCategoriesSection() {
    return FutureBuilder<List<Category>>(
      future: _categoriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: 150,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: 5,
              itemBuilder: (context, index) => Container(
                width: 76,
                margin: const EdgeInsets.only(right: 16),
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 50,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink(); // Hide section if failed or empty
        }

        final categories = snapshot.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Shop by Category',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.grey[900],
                      letterSpacing: -0.5,
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[500])
                ],
              ),
            ),
            SizedBox(
              height: 125,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  return Container(
                    width: 76,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SubCategoriesPage(category: cat),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(18),
                        child: Column(
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: cat.image.isNotEmpty
                                    ? Image.network(
                                        'https://durvasaayurved.online${cat.image}',
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Icon(
                                          Icons.category,
                                          color: Colors.blue[300],
                                          size: 30,
                                        ),
                                      )
                                    : Icon(
                                        Icons.category,
                                        color: Colors.blue[300],
                                        size: 30,
                                      ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              cat.categoryName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderHeader(order),
            const SizedBox(height: 16),
            Column(
              children: List.generate(
                order['itemsList'].length,
                (index) => _buildOrderItem(order['itemsList'][index]),
              ),
            ),
            const SizedBox(height: 16),
            Divider(height: 1, color: Colors.grey[300]),
            const SizedBox(height: 12),
            _buildOrderFooter(order),
            const SizedBox(height: 12),
            _buildOrderButtons(order),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderHeader(Map<String, dynamic> order) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              order['id'],
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 4),
            Text(order['date'], style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: order['statusColor'].withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: order['statusColor'].withOpacity(0.2)),
          ),
          child: Text(
            order['status'],
            style: TextStyle(
              color: order['statusColor'],
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(item['image'], style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Qty: ${item['quantity']}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            '\$${item['price'].toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderFooter(Map<String, dynamic> order) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${order['items']} item${order['items'] > 1 ? 's' : ''}',
          style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Total: \$${order['total'].toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.grey[900],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Includes tax',
              style: TextStyle(color: Colors.grey[500], fontSize: 11),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOrderButtons(Map<String, dynamic> order) {
    if (order['status'] != 'Delivered' && order['status'] != 'Cancelled') {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _trackOrder(order),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue[700],
                side: BorderSide(color: Colors.blue[700]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Track Order', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _viewOrderDetails(order),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('View Details', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      );
    }

    if (order['status'] == 'Delivered') {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _reorder(order),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.green[600],
                side: BorderSide(color: Colors.green[600]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Reorder', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _rateOrder(order),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Rate Order', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      );
    }

    if (order['status'] == 'Cancelled') {
      return Center(
        child: SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => _reorder(order),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.blue[700],
              side: BorderSide(color: Colors.blue[700]!),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('Order Again', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_outlined, 'Home', false),
              _buildNavItem(Icons.shopping_bag, 'Orders', true),
              _buildNavItem(Icons.person_outline, 'Profile', false),
              _buildNavItem(Icons.settings_outlined, 'Settings', false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isActive ? Colors.blue[700] : Colors.grey[500],
          size: 26,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isActive ? Colors.blue[700] : Colors.grey[500],
          ),
        ),
      ],
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Orders', style: TextStyle(fontWeight: FontWeight.bold)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFilterOption('All Orders', true),
            _buildFilterOption('Pending', false),
            _buildFilterOption('Processing', false),
            _buildFilterOption('Shipped', false),
            _buildFilterOption('Delivered', false),
            _buildFilterOption('Cancelled', false),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Apply Filters'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOption(String text, bool isSelected) {
    return ListTile(
      title: Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
      leading: Radio(
        value: isSelected,
        groupValue: true,
        onChanged: (value) {},
        activeColor: Colors.blue[700],
      ),
      onTap: () {},
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }

  void _trackOrder(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Track Order ${order['id']}', style: const TextStyle(fontWeight: FontWeight.bold)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTrackingStep('Order Placed', true, Icons.check_circle, Colors.green),
            _buildTrackingStep('Order Confirmed', true, Icons.check_circle, Colors.green),
            _buildTrackingStep(
              'Processing',
              order['status'] != 'Processing',
              order['status'] == 'Processing' ? Icons.refresh : Icons.check_circle,
              order['status'] == 'Processing' ? Colors.orange : Colors.green,
            ),
            _buildTrackingStep(
              'Shipped',
              order['status'] == 'Delivered',
              order['status'] == 'Shipped' ? Icons.local_shipping : Icons.check_circle,
              order['status'] == 'Shipped' ? Colors.blue : Colors.green,
            ),
            _buildTrackingStep('Delivered', false, Icons.radio_button_unchecked, Colors.grey),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingStep(String text, bool isCompleted, IconData icon, Color color) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color, size: 28),
      title: Text(
        text,
        style: TextStyle(
          color: isCompleted ? Colors.grey[800] : Colors.grey[500],
          fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  void _viewOrderDetails(Map<String, dynamic> order) {
    debugPrint('View details for order: ${order['id']}');
  }

  void _reorder(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reorder Items', style: TextStyle(fontWeight: FontWeight.bold)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Text('Add all items from order ${order['id']} to cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Items added to cart successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Add to Cart'),
          ),
        ],
      ),
    );
  }

  void _rateOrder(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Rate Order ${order['id']}', style: const TextStyle(fontWeight: FontWeight.bold)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('How was your experience?', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (index) => Icon(
                  Icons.star,
                  color: index < 4 ? Colors.amber : Colors.grey[300],
                  size: 32,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Add comment (optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                contentPadding: EdgeInsets.all(12),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Thank you for your feedback!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Submit Review'),
          ),
        ],
      ),
    );
  }
}
