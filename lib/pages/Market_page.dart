import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Market extends StatelessWidget {
   
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wishlist UI',
      home: WishlistScreen(),
    );
  }
}
class WishlistScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wishlist'),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ShoppingCartScreen()),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: 4,
        itemBuilder: (context, index) {
          // WishlistItemCard needs to be properly defined elsewhere in your code.
          return WishlistItemCard(
            title: 'Learning How To Fetch API with Laravel',
            price: '\$98.00',
            rating: 4.7,
            reviewCount: 11021,
            imagePath: 'assets/images/teach-you-flutter-dart-android-ios-app-development.png', // This should be a parameter in your WishlistItemCard.
          );
        },
      ),
    );
  }
}
class WishlistItemCard extends StatelessWidget {
  final String title;
  final String price;
  final double rating;
  final int reviewCount;
  final String imagePath;

  WishlistItemCard({
    required this.title,
    required this.price,
    required this.rating,
    required this.reviewCount,
    required this.imagePath,
  });


  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(imagePath),
          Text(title, style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
          Text(price, style: TextStyle(fontSize: 14.0, color: Colors.red)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.star, color: Colors.yellow, size: 20.0),
              Text('$rating ($reviewCount reviews)'),
              IconButton(
                icon: Icon(Icons.add_shopping_cart),
                onPressed: () {
                  Provider.of<CartProvider>(context, listen: false).addItem(
                    DateTime.now().toString(),
                    title,
                    double.parse(price.substring(1)),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Cours ajouté au panier!'),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
class ShoppingCartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final cartItems = cartProvider.items.values.toList();
    final total = cartProvider.total;

    return Scaffold(
      appBar: AppBar(
        title: Text('Votre Panier'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return ListTile(
                  title: Text(item.title),
                  subtitle: Text('\$${item.price.toStringAsFixed(2)}'),
                  trailing: Text('Quantité: ${item.quantity}'),
                );
              },
            ),
          ),
          Divider(),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '\$${total.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size.fromHeight(50), // fix height
              ),
            onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PaymentMethodScreen()),
    );
  },
  
              child: Text(
                'Procéder au paiement',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CartItem {
  String id;
  String title;
  double price;
  int quantity;

  CartItem({
    required this.id,
    required this.title,
    required this.price,
    this.quantity = 1, // default value is 1
  });

  // Adding a method to multiply the item's price by its quantity
  double get totalPrice => price * quantity;
}

class CartProvider with ChangeNotifier {
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => _items;

  double get total {
    return _items.values.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  void addItem(String productId, String title, double price) {
    if (_items.containsKey(productId)) {
      // Update quantity if it exists
      _items.update(
        productId,
        (existingCartItem) => CartItem(
          id: existingCartItem.id,
          title: existingCartItem.title,
          price: existingCartItem.price,
          quantity: existingCartItem.quantity + 1, // increment quantity
        ),
      );
    } else {
      _items.putIfAbsent(
        productId,
        () => CartItem(
          id: DateTime.now().toString(),
          title: title,
          price: price,
        ),
      );
    }
    notifyListeners();
  }
}
class PaymentMethodScreen extends StatefulWidget {
  @override
  _PaymentMethodScreenState createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  String? _selectedMethod;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Method'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            RadioListTile<String>(
              title: Text('Bank of America'),
              value: 'boa',
              groupValue: _selectedMethod,
              onChanged: (value) {
                setState(() {
                  _selectedMethod = value;
                });
              },
            ),
            RadioListTile<String>(
              title: Text('Citibank'),
              value: 'citibank',
              groupValue: _selectedMethod,
              onChanged: (value) {
                setState(() {
                  _selectedMethod = value;
                });
              },
            ),
            // ... Ajoutez d'autres méthodes de paiement ici ...
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddNewCardScreen()),
    );
  },
                child: Text('Confirm'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size.fromHeight(50), // fix the height of the button
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class AddNewCardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Card'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Name on Card*',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Card Number*',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Expiration*',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'CVC*',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Postal Code*',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 24),
            CheckboxListTile(
              title: Text('Save payment card to account.'),
              value: true,
              onChanged: (bool? value) {
                // Handle change
              },
            ),
            ElevatedButton(
              child: Text('Add Card'),
                onPressed: () {
        // Ici, vous pourriez vouloir valider les informations de la carte avant de naviguer
        // Simplement pour l'exemple, nous naviguerons directement
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ConfirmOrderScreen()),
        );
      },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ConfirmOrderScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Confirm Order'),
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            ListTile(
              leading: Icon(Icons.credit_card),
              title: Text('American Express'),
              // Vous pouvez ajouter plus de détails ici si nécessaire
            ),
            Divider(),
            // Ajouter le résumé de la commande
            Text('Order summary', style: TextStyle(fontWeight: FontWeight.bold)),
            // Vous pouvez utiliser des widgets ListTile ou des lignes de texte pour les détails
            Text('Original price: \$196.00'),
            Text('Payment fee: \$0.00'),
            Text('Total buy: \$140.00'),
            Divider(),
            // Ajouter les cours achetés
            Text('Purchased course', style: TextStyle(fontWeight: FontWeight.bold)),
            CourseTile(courseName: 'UX Research in Digital Product Design: Master Class', price: '\$98.00'),
            CourseTile(courseName: 'End-to-End Web Design: Figma to Webflow Master', price: '\$98.00'),
            Spacer(),
            ElevatedButton(
              child: Text('Buy Now'),
           onPressed: () {
    // Insérez ici la logique de traitement de l'achat

    // Après le traitement de l'achat, naviguez vers l'écran de succès
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BuySuccessScreen()),
    );
  },
            ),
          ],
        ),
      ),
    );
  }
}

class CourseTile extends StatelessWidget {
  final String courseName;
  final String price;

  const CourseTile({Key? key, required this.courseName, required this.price}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.book),
      title: Text(courseName),
      subtitle: Text(price),
    );
  }
}

class BuySuccessScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Buy Success"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/images/Image.png'), // Assurez-vous que vous avez cette image dans les assets
            Text(
              'Successfully Purchased!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              child: Text(
                'Your class purchase was successful! Enjoy your learning experience!',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Naviguez vers l'écran de démarrage de l'apprentissage
              },
              child: Text('Start Learning'),
            ),
            TextButton(
              onPressed: () {
                // Naviguez de retour à l'écran d'accueil
              },
              child: Text('Back to Home'),
            )
          ],
        ),
      ),
    );
  }
}
