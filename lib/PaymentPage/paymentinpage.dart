import 'package:flutter/material.dart';

class PaymentPageFst extends StatelessWidget {
  const PaymentPageFst({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Durvasa Herbal Corporation India"),
        backgroundColor: Colors.green[700],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),

          // Top Row with Two Containers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Left Container
              Container(
                height: 100,
                width: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "₹ 0.00",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text("DEC-2020"),
                    ],
                  ),
                ),
              ),

              // Right Container
              Container(
                height: 100,
                width: 150,
                decoration: BoxDecoration(
                  color: Colors.amber[600],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "₹ 0.00",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text("JAN-2021"),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          // Centered Text Below Containers
          const Text(
            "Current Month Transactions",
            style: TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 20),

          // Rest of your content
          Expanded(
            child: Center(
              child: Text(
                "Transaction details here...",
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ),
        ],
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.green,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: "Notifications",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.language), label: "More"),
        ],
      ),
    );
  }
}
