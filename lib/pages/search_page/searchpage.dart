import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:leverage/pages/marketplace/product_details_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String _searchQuery = '';
  String _sortOption = 'Lowest Price'; // Default sort option

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _onSortOptionSelected(String option) {
    setState(() {
      _sortOption = option;
    });
    Navigator.pop(context); // Close the sort options dialog
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          title: const Text('Lowest Price'),
                          onTap: () => _onSortOptionSelected('Lowest Price'),
                        ),
                        ListTile(
                          title: const Text('Highest Price'),
                          onTap: () => _onSortOptionSelected('Highest Price'),
                        ),
                        ListTile(
                          title: const Text('Location'),
                          onTap: () => _onSortOptionSelected('Location'),
                        ),
                        ListTile(
                          title: const Text('Condition'),
                          onTap: () => _onSortOptionSelected('Condition'),
                        ),
                        ListTile(
                          title: const Text('Offer Shipping'),
                          onTap: () => _onSortOptionSelected('Offer Shipping'),
                        ),
                        ListTile(
                          title: const Text('Offer Leverage Fees'),
                          onTap: () => _onSortOptionSelected('Offer Leverage Fees'),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search products...',
                border: OutlineInputBorder(),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('products')
                  .where('itemName', isGreaterThanOrEqualTo: _searchQuery)
                  .where('itemName', isLessThanOrEqualTo: '$_searchQuery\uf8ff')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final products = snapshot.data!.docs;

                if (products.isEmpty) {
                  return const Center(child: Text('No products found.'));
                }

                // Sort the products based on the selected sort option
                switch (_sortOption) {
                  case 'Lowest Price':
                    products.sort((a, b) => (a['price'] as int).compareTo(b['price'] as int));
                    break;
                  case 'Highest Price':
                    products.sort((a, b) => (b['price'] as int).compareTo(a['price'] as int));
                    break;
                // Implement other sorting options if needed
                }

                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    var productData = products[index].data() as Map<String, dynamic>;
                    return GestureDetector(
                      onTap: () {
                        // Navigate to product details page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailsPage(
                              productName: productData['itemName'],
                              productImages: List<String>.from(productData['imageUrls']),
                              price: productData['price'],
                              location: productData['location'],
                              condition: productData['condition'] ?? 'New',
                              listingType: productData['listingType'] ?? 'For Sale',
                              description: productData['description'] ?? '',
                              offerShipping: productData['offerShipping'] ?? false,
                              offerLeverageFee: productData['offerLeverageFee'] ?? false,
                              sellerId: productData['sellerId'], // Ensure sellerId is passed

                            ),
                          ),
                        );
                      },
                      child: ProductItem(
                        itemName: productData['itemName'],
                        price: productData['price'],
                        location: productData['location'],
                        imageUrl: productData['imageUrls'][0],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ProductItem extends StatelessWidget {
  final String itemName;
  final int price;
  final String location;
  final String imageUrl;

  const ProductItem({
    required this.itemName,
    required this.price,
    required this.location,
    required this.imageUrl,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  itemName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4.0),
                Text(
                  '₦$price',
                  style: const TextStyle(color: Colors.green),
                ),
                const SizedBox(height: 4.0),
                Text(
                  location,
                  style: const TextStyle(color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
