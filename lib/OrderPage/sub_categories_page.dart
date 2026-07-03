import 'package:flutter/material.dart';
import '../model/getcategory_model.dart';
import '../model/getsubcategory_model.dart';
import '../service/Auth_servcie.dart';
import 'product_screen.dart';

class SubCategoriesPage extends StatefulWidget {
  final Category category;

  const SubCategoriesPage({super.key, required this.category});

  @override
  State<SubCategoriesPage> createState() => _SubCategoriesPageState();
}

class _SubCategoriesPageState extends State<SubCategoriesPage> {
  Future<List<SubCategory>>? _subCategoriesFuture;

  @override
  void initState() {
    super.initState();
    // Fetch all subcategories and filter them locally by the selected category ID
    _subCategoriesFuture = AuthService().getSubCategories().then(
      (subCats) => subCats.where((s) => s.catId == widget.category.catId).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          widget.category.categoryName,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blue[700],
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<SubCategory>>(
        future: _subCategoriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading subcategories\n${snapshot.error}',
                style: TextStyle(color: Colors.red[400]),
                textAlign: TextAlign.center,
              ),
            );
          }
          
          final subCats = snapshot.data ?? [];
          
          if (subCats.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.category_outlined, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'No subcategories found',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: subCats.length,
            itemBuilder: (context, index) {
              final subCat = subCats[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.subdirectory_arrow_right, color: Colors.blue[700]),
                  ),
                  title: Text(
                    subCat.subCategoryName,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Colors.grey[800],
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      'Code: ${subCat.subCatId}',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductScreen(
                          categoryId: subCat.catId,
                          categoryName: subCat.subCategoryName,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
