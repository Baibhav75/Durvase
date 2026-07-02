import 'package:flutter/material.dart';

class DoctorPagefst extends StatelessWidget {
  DoctorPagefst({super.key});

  final List<Map<String, dynamic>> doctors = [
    {
      'name': 'Dr. Sarah Johnson',
      'specialization': 'Cardiologist',
      'experience': '15 years',
      'rating': 4.9,
      'reviews': 284,
      'image': '👩‍⚕️',
      'hospital': 'City General Hospital',
      'consultationFee': '\$120',
      'availability': 'Available Today',
    },
    {
      'name': 'Dr. Michael Chen',
      'specialization': 'Neurologist',
      'experience': '12 years',
      'rating': 4.8,
      'reviews': 196,
      'image': '👨‍⚕️',
      'hospital': 'Medical Center',
      'consultationFee': '\$150',
      'availability': 'Available Tomorrow',
    },
    {
      'name': 'Dr. Emily Davis',
      'specialization': 'Pediatrician',
      'experience': '10 years',
      'rating': 4.7,
      'reviews': 173,
      'image': '👩‍⚕️',
      'hospital': 'Children Hospital',
      'consultationFee': '\$100',
      'availability': 'Available Today',
    },
    {
      'name': 'Dr. Robert Wilson',
      'specialization': 'Orthopedic',
      'experience': '18 years',
      'rating': 4.9,
      'reviews': 312,
      'image': '👨‍⚕️',
      'hospital': 'Sports Medicine Center',
      'consultationFee': '\$180',
      'availability': 'Available Now',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Find Doctors',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blue[700],
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Section
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue[700],
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Find Your Doctor',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Book appointments with trusted specialists',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: Colors.grey),
                      SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search doctors, specialties...',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Categories Section
          Container(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.all(16),
              children: [
                _buildCategoryCard('🫀', 'Cardiology', Colors.blue),
                _buildCategoryCard('🧠', 'Neurology', Colors.green),
                _buildCategoryCard('👶', 'Pediatrics', Colors.orange),
                _buildCategoryCard('🦴', 'Orthopedic', Colors.purple),
                _buildCategoryCard('👁️', 'Dermatology', Colors.pink),
              ],
            ),
          ),

          // Doctors List Section
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Top Specialists',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'See All',
                    style: TextStyle(color: Colors.blue[700]),
                  ),
                ),
              ],
            ),
          ),

          // Doctors List
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: doctors.length,
              itemBuilder: (context, index) {
                return _buildDoctorCard(doctors[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(String emoji, String title, Color color) {
    return Container(
      width: 80,
      margin: EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Text(emoji, style: TextStyle(fontSize: 24))),
          ),
          SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorCard(Map<String, dynamic> doctor) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor Avatar
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(doctor['image'], style: TextStyle(fontSize: 24)),
              ),
            ),
            SizedBox(width: 16),

            // Doctor Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        doctor['name'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getAvailabilityColor(doctor['availability']),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          doctor['availability'],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    doctor['specialization'],
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  SizedBox(height: 4),
                  Text(
                    doctor['hospital'],
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 16),
                      SizedBox(width: 4),
                      Text(
                        doctor['rating'].toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(width: 4),
                      Text(
                        '(${doctor['reviews']} reviews)',
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                      Spacer(),
                      Text(
                        doctor['consultationFee'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                          fontSize: 14,
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
  }

  Color _getAvailabilityColor(String availability) {
    switch (availability) {
      case 'Available Now':
        return Colors.green;
      case 'Available Today':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }
}
