import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:leverage/pages/chat.dart';
import 'package:leverage/pages/more.dart';
import 'package:leverage/pages/sell_page.dart';
import 'package:leverage/pages/more/profile_page.dart';
import 'package:leverage/pages/transact.dart';
import 'package:leverage/pages/more/transactions_page.dart';
import 'package:leverage/pages/deposit.dart';
import 'package:leverage/pages/withdraw.dart';
import 'package:leverage/pages/marketplace/product_details_page.dart';
import 'package:leverage/pages/search_page/searchpage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  DateTime? _lastBackPressTime;

  final List<Widget> _pages = [
    const HomePageContent(),
    ChatPage(),
    const TransactPage(),
    const MorePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<bool> _onWillPop() async {
    if (_selectedIndex != 0) {
      setState(() {
        _selectedIndex = 0;
      });
      return false;
    }

    DateTime now = DateTime.now();
    if (_lastBackPressTime == null || now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
      _lastBackPressTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Press back again to exit'),
          duration: Duration(seconds: 2),
        ),
      );
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F7FA),
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
              backgroundColor: Color(0xFFF2F7FA),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.wallet),
              label: 'Transact',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.more),
              label: 'More',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0XFF2F4170),
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          onTap: _onItemTapped,
        ),
        body: _pages[_selectedIndex],
      ),
    );
  }
}

class HomePageContent extends StatelessWidget {
  const HomePageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        if (scrollNotification.metrics.pixels > 0) {
          MarketplaceHeader.of(context)?.setScrolled(true);
        } else {
          MarketplaceHeader.of(context)?.setScrolled(false);
        }
        return false;
      },
      child: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            centerTitle: true,
            backgroundColor: const Color(0xFFF2F7FA),
            floating: true,
            pinned: true,

            // Profile icon on the left
            leading: IconButton(
              icon: const Icon(Icons.person),
              color: Color(0XFF2F4170), // Your color for icons
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
            ),

            // Notification icon on the right
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications),
                color: Color(0XFF2F4170), // Your color for icons
                onPressed: () {
                  Navigator.pushNamed(context, '/notification');
                },
              ),
            ],
          ),

          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: BalanceContainer(),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverAppBarDelegate(
              child: const MarketplaceHeader(),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                return Container(
                  padding: const EdgeInsets.all(10.0),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('products').snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final products = snapshot.data!.docs;

                      // Adjust this to display products correctly
                      return GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: products.length,
                        itemBuilder: (BuildContext context, int gridIndex) {
                          var productData = products[gridIndex].data() as Map<String, dynamic>;
                          return GestureDetector(
                            onTap: () {
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
                                    sellerId: productData['sellerId'],
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
                );
              },
              childCount: 1,
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
                const SizedBox(height: 0.0),
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

class BalanceContainer extends StatefulWidget {
  const BalanceContainer({Key? key}) : super(key: key);

  @override
  _BalanceContainerState createState() => _BalanceContainerState();
}

class _BalanceContainerState extends State<BalanceContainer> {
  bool _isBalanceVisible = true;
  final double _walletBalance = 50000.0;
  final double _escrowBalance = 30000.0;
  int _selectedPage = 0;

  // Declare these variables as late but do not initialize them here
  late String formattedWalletBalance;
  late String formattedEscrowBalance;

  @override
  void initState() {
    super.initState();
    // Initialize the formatted strings here
    formattedWalletBalance = _formatNumber(_walletBalance);
    formattedEscrowBalance = _formatNumber(_escrowBalance);
  }

  // Custom function to format numbers with commas
  String _formatNumber(double number) {
    return number.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (Match match) => '${match[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PageView(
            onPageChanged: (index) {
              setState(() {
                _selectedPage = index;
              });
            },
            children: [
              _buildBalanceCard(
                title: 'Wallet Balance',
                balance: _isBalanceVisible ? formattedWalletBalance : '*****',
                isVisible: _isBalanceVisible, // Pass isVisible here
                onVisibilityToggle: () {
                  setState(() {
                    _isBalanceVisible = !_isBalanceVisible;
                  });
                },
              ),
              _buildBalanceCard(
                title: 'Escrow Balance',
                balance: _isBalanceVisible ? formattedEscrowBalance : '*****',
                isVisible: _isBalanceVisible, // Pass isVisible here
                onVisibilityToggle: () {
                  setState(() {
                    _isBalanceVisible = !_isBalanceVisible;
                  });
                },
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSwipeIndicator(isSelected: _selectedPage == 0),
              const SizedBox(width: 4),
              _buildSwipeIndicator(isSelected: _selectedPage == 1),
            ],
          ),
        ),
      ],
    );
  }

  // Build balance card with dynamic title and balance
  Widget _buildBalanceCard({
    required String title,
    required String balance,
    required bool isVisible,
    required VoidCallback onVisibilityToggle,
  }) {
    return Container(
      height: 200,
      width: 320,
      decoration: BoxDecoration(
        color: const Color(0XFF2F4170),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Color(0xFFF2F7FA),
                              fontSize: 14,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                isVisible ? '₦$balance' : '₦••••••',
                                style: const TextStyle(
                                  color: Color(0xFFF2F7FA),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: Icon(isVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off),
                                onPressed: onVisibilityToggle,
                                color: Color(0xFFF2F7FA),
                              ),
                            ],
                          ),
                        ],
                      ),
                      // Swipe indicator in top right
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DepositPage(title: 'Deposit Page', email: '',),
                      ),
                    );
                  },
                  child: const Column(
                    children: [
                      CircleAvatar(
                        backgroundColor: Color(0xFFF2F7FA),
                        child: Icon(Icons.add, color: Color(0XFF2F4170)),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Deposit',
                        style: TextStyle(
                          color: Color(0xFFF2F7FA),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const WithdrawPage()),
                    );
                  },
                  child: const Column(
                    children: [
                      CircleAvatar(
                        backgroundColor: Color(0xFFF2F7FA),
                        child: Icon(Icons.send, color: Color(0XFF2F4170)),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Withdraw',
                        style: TextStyle(
                          color: Color(0xFFF2F7FA),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent transactions',
                  style: TextStyle(
                    color: Color(0xFFF2F7FA),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const TransactionsPage()),
                    );
                  },
                  child: const Text(
                    'See All',
                    style: TextStyle(
                      color: Color(0xFFF2F7FA),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Swipe indicator dot builder
  Widget _buildSwipeIndicator({required bool isSelected}) {
    return Container(
      width: 8,
      height: 3,
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue[900] : Colors.blue[300],
        shape: BoxShape.rectangle
      ),
    );
  }
}



class MarketplaceHeader extends StatefulWidget {
  const MarketplaceHeader({super.key});

  static _MarketplaceHeaderState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MarketplaceHeaderState>();

  @override
  _MarketplaceHeaderState createState() => _MarketplaceHeaderState();
}

class _MarketplaceHeaderState extends State<MarketplaceHeader> {
  bool _isScrolled = false;
  bool _isForYouSelected = true;

  void setScrolled(bool scrolled) {
    if (_isScrolled != scrolled) {
      setState(() {
        _isScrolled = scrolled;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      color: _isScrolled ? const Color(0xFFF2F7FA) : const Color(0xFFF2F7FA),
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // First Row: Marketplace, Search, Sell
          Row(
            children: [
              const Icon(Icons.store, size: 30, color: Color(0XFF2F4170)),
              const SizedBox(width: 3,),
              const Text(
                'Marketplace',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0XFF2F4170),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.search, size: 30, color: Color(0XFF2F4170)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SearchPage()),
                  );
                },
              ),
              const SizedBox(width: 15),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SellPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0XFF2F4170),
                ),
                child: const Text(
                  'Sell',
                  style: TextStyle(color: Color(0xFFF2F7FA)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 0), // Spacing between rows

          // Second Row: For You and Category buttons
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isForYouSelected = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isForYouSelected
                      ? const Color(0XFF2F4170)  // Dark blue when selected
                      : const Color(0xFFF2F7FA), // Light color when unselected
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text(
                  'For You',
                  style: TextStyle(
                    color: _isForYouSelected
                        ? const Color(0xFFF2F7FA)   // White text when selected
                        : const Color(0XFF2F4170), // Dark blue text when unselected
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isForYouSelected = false;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: !_isForYouSelected
                      ? const Color(0XFF2F4170)  // Dark blue when selected
                      : const Color(0xFFF2F7FA), // Light color when unselected
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text(
                  'Category',
                  style: TextStyle(
                    color: !_isForYouSelected
                        ? const Color(0xFFF2F7FA)   // White text when selected
                        : const Color(0XFF2F4170), // Dark blue text when unselected
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _SliverAppBarDelegate({required this.child});

  @override
  double get minExtent => 112;

  @override
  double get maxExtent => 112;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _SliverAppBarDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}
