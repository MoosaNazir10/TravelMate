import 'package:flutter/material.dart';

class CurrencyConverterScreen extends StatefulWidget {
  const CurrencyConverterScreen({super.key});

  @override
  State<CurrencyConverterScreen> createState() => _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  // Exchange rates with USD as base
  final Map<String, double> exchangeRates = {
    'USD': 1.0,
    'EUR': 0.92,
    'GBP': 0.79,
    'PKR': 278.50,
    'INR': 83.12,
    'JPY': 149.50,
    'AUD': 1.52,
    'CAD': 1.36,
    'CHF': 0.88,
    'CNY': 7.24,
  };

  final Map<String, String> currencyNames = {
    'USD': 'US Dollar',
    'EUR': 'Euro',
    'GBP': 'British Pound',
    'PKR': 'Pakistani Rupee',
    'INR': 'Indian Rupee',
    'JPY': 'Japanese Yen',
    'AUD': 'Australian Dollar',
    'CAD': 'Canadian Dollar',
    'CHF': 'Swiss Franc',
    'CNY': 'Chinese Yuan',
  };

  String fromCurrency = 'USD';
  String toCurrency = 'PKR';
  final TextEditingController amountController = TextEditingController();
  double convertedAmount = 0.0;

  @override
  void initState() {
    super.initState();
    amountController.addListener(_convertCurrency);
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  void _convertCurrency() {
    final amount = double.tryParse(amountController.text);
    if (amount != null) {
      setState(() {
        // Convert from source to USD, then USD to target
        final amountInUSD = amount / exchangeRates[fromCurrency]!;
        convertedAmount = amountInUSD * exchangeRates[toCurrency]!;
      });
    } else {
      setState(() {
        convertedAmount = 0.0;
      });
    }
  }

  void _swapCurrencies() {
    setState(() {
      final temp = fromCurrency;
      fromCurrency = toCurrency;
      toCurrency = temp;
      _convertCurrency();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/image/bgimg.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Overlay
          Container(color: Colors.white.withOpacity(0.7)),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back arrow
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.green),
                    onPressed: () => Navigator.pop(context),
                  ),

                  const SizedBox(height: 10),

                  // Title
                  const Center(
                    child: Text(
                      "Currency\nConverter",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // FROM
                  const Text(
                    "From:",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),

                  buildDropdown(fromCurrency, true),

                  const SizedBox(height: 20),

                  // AMOUNT
                  buildInput("Amount"),

                  const SizedBox(height: 30),

                  // Swap icon
                  Center(
                    child: GestureDetector(
                      onTap: _swapCurrencies,
                      child: const Icon(
                        Icons.swap_vert,
                        size: 36,
                        color: Colors.green,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // TO
                  const Text(
                    "To:",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),

                  buildDropdown(toCurrency, false),

                  const SizedBox(height: 20),

                  // RESULT
                  buildResult(convertedAmount.toStringAsFixed(2)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Dropdown UI
  Widget buildDropdown(String value, bool isFrom) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 55,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black38),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.green),
          items: exchangeRates.keys.map((String currency) {
            return DropdownMenuItem<String>(
              value: currency,
              child: Text(
                '$currency - ${currencyNames[currency]}',
                style: const TextStyle(fontSize: 16),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                if (isFrom) {
                  fromCurrency = newValue;
                } else {
                  toCurrency = newValue;
                }
                _convertCurrency();
              });
            }
          },
        ),
      ),
    );
  }

  // Input field
  Widget buildInput(String hint) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black38),
      ),
      child: TextField(
        controller: amountController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  // Result field
  Widget buildResult(String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black38),
      ),
      child: Center(
        child: Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
