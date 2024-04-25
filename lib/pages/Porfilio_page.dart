import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class Porfilio extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Portfolio'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            PortfolioSummary(),
            YourCoins(),
            // ... other widgets
          ],
        ),
      ),
    );
  }
}

class PortfolioSummary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(8),
      ),
      margin: EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'Holding value',
            style: TextStyle(color: Colors.white70),
          ),
          SizedBox(height: 8),
          Text(
            '\$2,420.69',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          // ... other texts and buttons
        ],
      ),
    );
  }
}

class YourCoins extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your coins',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          CoinTile(
            crypto: 'Ethereum',
            amount: '\$315.00',
            percentage: '-11.00%',
  iconData: MdiIcons.ethereum, // Notez le changement ici
          ),
          CoinTile(
            crypto: 'Tether',
            amount: '\$108.15',
            percentage: '+0.06%',
  iconData: MdiIcons.currencyUsd, // Et ici
          ),
          // ... other CoinTile widgets
        ],
      ),
    );
  }
}

class CoinTile extends StatelessWidget {
  final String crypto;
  final String amount;
  final String percentage;
  final IconData iconData;

  const CoinTile({
    Key? key,
    required this.crypto,
    required this.amount,
    required this.percentage,
    required this.iconData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.grey[200], // Added a background color for visibility
        child: Icon(iconData, size: 24.0), // Adjust the icon size as needed
      ),
      title: Text(crypto),
      subtitle: Text(amount),
      trailing: Text(
        percentage,
        style: TextStyle(
          color: percentage.startsWith('-') ? Colors.red : Colors.green,
        ),
      ),
    );
  }
}
