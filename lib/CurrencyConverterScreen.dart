import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travelmate/services/firebase_service.dart';

class CurrencyConverterScreen extends StatefulWidget {
  const CurrencyConverterScreen({super.key});

  @override
  State<CurrencyConverterScreen> createState() =>
      _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController amountController = TextEditingController();

  String fromCurrency = 'USD';
  String toCurrency = 'PKR';
  double result = 0.0;

  final List<Map<String, String>> currencies = [
    {'code': 'USD', 'name': 'US Dollar'},
    {'code': 'EUR', 'name': 'Euro'},
    {'code': 'GBP', 'name': 'British Pound'},
    {'code': 'PKR', 'name': 'Pakistani Rupee'},
    {'code': 'INR', 'name': 'Indian Rupee'},
    {'code': 'JPY', 'name': 'Japanese Yen'},
    {'code': 'AUD', 'name': 'Australian Dollar'},
    {'code': 'CAD', 'name': 'Canadian Dollar'},
    {'code': 'CHF', 'name': 'Swiss Franc'},
    {'code': 'CNY', 'name': 'Chinese Yuan'},
  ];

  void _performConversion(Map<String, dynamic> rates) {
    if (amountController.text.isEmpty) {
      setState(() => result = 0.0);
      return;
    }

    double amount = double.tryParse(amountController.text) ?? 0.0;

    // Logic: Convert input to USD base, then to target currency
    double fromRate = (rates[fromCurrency] ?? 1.0).toDouble();
    double toRate = (rates[toCurrency] ?? 1.0).toDouble();

    setState(() {
      result = (amount / fromRate) * toRate;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/image/bgimg.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.white.withOpacity(0.7)),
          SafeArea(
            child: StreamBuilder<DocumentSnapshot>(
              stream: _firebaseService.getExchangeRates(),
              builder: (context, snapshot) {
                // Default fallback rates while loading or if data is missing
                Map<String, dynamic> exchangeRates = {
                  'USD': 1.0,
                  'EUR': 0.92,
                  'GBP': 0.79,
                  'PKR': 278.50,
                  'INR': 83.12,
                };

                if (snapshot.hasData && snapshot.data!.exists) {
                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  exchangeRates = data['rates'] ?? exchangeRates;
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 30),
                      _buildConverterCard(exchangeRates),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.green),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        const Center(
          child: Text(
            "Currency Converter",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConverterCard(Map<String, dynamic> rates) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Amount",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          _buildInput(() => _performConversion(rates)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildCurrencyDropdown(true, (val) {
                  setState(() => fromCurrency = val!);
                  _performConversion(rates);
                }),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Icon(Icons.swap_horiz, color: Colors.green, size: 30),
              ),
              Expanded(
                child: _buildCurrencyDropdown(false, (val) {
                  setState(() => toCurrency = val!);
                  _performConversion(rates);
                }),
              ),
            ],
          ),
          const SizedBox(height: 30),
          const Text(
            "Converted Amount",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          _buildResultField(),
        ],
      ),
    );
  }

  Widget _buildInput(VoidCallback onChanged) {
    return TextField(
      controller: amountController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: (_) => onChanged(),
      decoration: InputDecoration(
        hintText: "Enter value",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

  Widget _buildCurrencyDropdown(bool isFrom, Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black26),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: isFrom ? fromCurrency : toCurrency,
          isExpanded: true,
          items: currencies
              .map(
                (c) =>
                    DropdownMenuItem(value: c['code'], child: Text(c['code']!)),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildResultField() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Text(
        result.toStringAsFixed(2),
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.green,
        ),
      ),
    );
  }
}
