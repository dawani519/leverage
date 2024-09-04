import 'package:flutter/material.dart';
import 'package:leverage/pages/chat.dart';
import 'package:leverage/pages/more.dart';
import 'package:leverage/pages/sell_page.dart';
import 'package:leverage/pages/more/profile_page.dart';
import 'package:leverage/pages/transact.dart';
import 'package:leverage/pages/more/transactions_page.dart';
import 'package:leverage/pages/deposit.dart';
import 'package:leverage/pages/withdraw.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePageContent(),
    const ChatPage(),
    const TransactPage(),
    const MorePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
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
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
      ),
      body: _pages[_selectedIndex],
    );
  }
}

class HomePageContent extends StatelessWidget {
  const HomePageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        if (scrollNotification is ScrollUpdateNotification) {
          ScrollableState? scrollableState = Scrollable.of(context);
          if (scrollableState != null) {
            bool isScrolled = scrollableState.position.pixels > 0;
            MarketplaceHeader.of(context)?.setScrolled(isScrolled);
          }
        }
        return false;
      },
      child: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            title: const Text(
              'Leverage',
              style: TextStyle(fontSize: 20),
            ),
            centerTitle: true,
            backgroundColor: Colors.white,
            floating: true,
            pinned: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  Navigator.pushNamed(context, '/notification');
                },
              ),
            ],
            leading: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
              child: const CircleAvatar(
                radius: 12,
                backgroundColor: Colors.blue,
                child: Text(
                  'JD',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
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
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7, // Make the card taller
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemBuilder: (BuildContext context, int gridIndex) {
                      return ProductItem(index: gridIndex);
                    },
                    itemCount: 20, // Number of product items to display
                  ),
                );
              },
              childCount: 1, // Set childCount to a single GridView container
            ),
          ),
        ],
      ),
    );
  }
}

class BalanceContainer extends StatefulWidget {
  const BalanceContainer({super.key});

  @override
  _BalanceContainerState createState() => _BalanceContainerState();
}

class _BalanceContainerState extends State<BalanceContainer> {
  bool _isBalanceVisible = true;
  final double _balance = 50000.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: 320,
      decoration: BoxDecoration(
        color: Colors.white,
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
                  const Text(
                    'Balance',
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _isBalanceVisible ? '₦$_balance' : '₦••••••',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(_isBalanceVisible ? Icons.visibility : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            _isBalanceVisible = !_isBalanceVisible;
                          });
                        },
                      ),
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
                      MaterialPageRoute(builder: (context) => const AdeFlutterExample()),
                    );
                  },
                  child: Column(
                    children: const [
                      CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Icon(Icons.add, color: Colors.white),
                      ),
                      SizedBox(height: 2),
                      Text('Deposit'),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    MaterialPageRoute(builder: (context) => const WithdrawPage());// Implement the withdrawal functionality here
                  },
                  child: Column(
                    children: const [
                      CircleAvatar(
                        backgroundColor: Colors.green,
                        child: Icon(Icons.send, color: Colors.white),
                      ),
                      SizedBox(height: 2),
                      Text('Withdraw'),
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
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TransactionsPage()),
                    );
                    // Navigate to transactions page or show all transactions
                  },
                  child: const Text(
                    'See All',
                    style: TextStyle(
                      color: Colors.blue,
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
  bool _isSearchExpanded = false;

  void setScrolled(bool scrolled) {
    if (_isScrolled != scrolled) {
      setState(() {
        _isScrolled = scrolled;
      });
    }
  }

  void _toggleSearch() {
    setState(() {
      _isSearchExpanded = !_isSearchExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _isScrolled ? Colors.white : Colors.grey,
      padding: const EdgeInsets.all(5.0),
      child: Row(
        children: [
          // Marketplace title section
          const Row(
            children: [
              Icon(Icons.store, size: 30, color: Colors.blue),
              SizedBox(width: 5),
              Text(
                'Marketplace',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const Spacer(), // Spacer to push search and sell button to the right
          // Search bar and sell button section
          _isSearchExpanded
              ? Expanded(
            child: TextField(
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search...',
                border: InputBorder.none,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _toggleSearch,
                ),
              ),
            ),
          )
              : IconButton(
            icon: const Icon(Icons.search, size: 30),
            onPressed: _toggleSearch,
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SellPage()),
              );
            },
            child: const Text('Sell'),
          ),
        ],
      ),
    );
  }
}

class ProductItem extends StatelessWidget {
  final int index;

  const ProductItem({required this.index, super.key});

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
              child: Image.asset(
                'assets/images/product_$index.png', // Placeholder image path
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
                  'Product Item $index',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4.0),
                Text(
                  '₦${index * 1000}', // Placeholder price
                  style: const TextStyle(color: Colors.green),
                ),
                const SizedBox(height: 4.0),
                Text(
                  'Location $index', // Placeholder location
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

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _SliverAppBarDelegate({required this.child});

  @override
  double get minExtent => 49;

  @override
  double get maxExtent => 49;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _SliverAppBarDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}
