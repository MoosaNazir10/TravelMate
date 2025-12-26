import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travelmate/services/firebase_service.dart';
import 'expense_models.dart';
import 'AddExpenseScreen.dart';

class ExpenseTrackerScreen extends StatefulWidget {
  const ExpenseTrackerScreen({super.key});

  @override
  State<ExpenseTrackerScreen> createState() => _ExpenseTrackerScreenState();
}

class _ExpenseTrackerScreenState extends State<ExpenseTrackerScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  final List<ExpenseCategory> categories = [
    ExpenseCategory(
      id: 'food',
      name: 'Food & Drinks',
      icon: Icons.restaurant,
      color: const Color(0xFFFF6B6B),
    ),
    ExpenseCategory(
      id: 'transport',
      name: 'Transport',
      icon: Icons.directions_car,
      color: const Color(0xFF4ECDC4),
    ),
    ExpenseCategory(
      id: 'accommodation',
      name: 'Accommodation',
      icon: Icons.hotel,
      color: const Color(0xFF45B7D1),
    ),
    ExpenseCategory(
      id: 'tickets',
      name: 'Tickets & Tours',
      icon: Icons.confirmation_number,
      color: const Color(0xFFFFA07A),
    ),
    ExpenseCategory(
      id: 'shopping',
      name: 'Shopping',
      icon: Icons.shopping_bag,
      color: const Color(0xFF98D8C8),
    ),
    ExpenseCategory(
      id: 'flights',
      name: 'Flights',
      icon: Icons.flight,
      color: const Color(0xFF9B59B6),
    ),
    ExpenseCategory(
      id: 'other',
      name: 'Other',
      icon: Icons.coffee,
      color: const Color(0xFF95A5A6),
    ),
  ];

  // Helper to get category details by ID
  ExpenseCategory _getCategory(String id) {
    return categories.firstWhere(
      (cat) => cat.id == id,
      orElse: () => categories.last,
    );
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
          Container(color: Colors.white.withOpacity(0.7)),

          SafeArea(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firebaseService.getExpenses(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.green),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState();
                }

                // Map Firestore docs to Expense objects
                List<Expense> expenses = snapshot.data!.docs
                    .map((doc) => Expense.fromFirestore(doc))
                    .toList();

                double totalExpense = expenses.fold(
                  0,
                  (sum, item) => sum + item.amount,
                );

                return Column(
                  children: [
                    _buildHeader(),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildSummaryCard(totalExpense, expenses),
                            const SizedBox(height: 24),
                            _buildExpenseList(expenses),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddExpenseScreen(categories: categories),
            ),
          );
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.green),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              "Expense Tracker",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(double total, List<Expense> expenses) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          const Text(
            "Total Spending",
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          Text(
            "Rs ${total.toStringAsFixed(2)}",
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 0,
                centerSpaceRadius: 40,
                sections: _buildChartSections(expenses),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildChartSections(List<Expense> expenses) {
    Map<String, double> categoryTotals = {};
    for (var expense in expenses) {
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }

    return categoryTotals.entries.map((entry) {
      final category = _getCategory(entry.key);
      return PieChartSectionData(
        color: category.color,
        value: entry.value,
        title: '', // Hide title for cleaner look
        radius: 50,
      );
    }).toList();
  }

  Widget _buildExpenseList(List<Expense> expenses) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Recent Expenses",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...expenses.map((expense) {
          final category = _getCategory(expense.category);
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: category.color.withOpacity(0.1),
                  child: Icon(category.icon, color: category.color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense.description,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "${expense.date.day}/${expense.date.month}/${expense.date.year}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black38,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  "${expense.currency} ${expense.amount.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                  onPressed: () => _firebaseService.deleteExpense(expense.id),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.account_balance_wallet_outlined,
            size: 80,
            color: Colors.black26,
          ),
          const SizedBox(height: 16),
          const Text(
            "No expenses yet!",
            style: TextStyle(fontSize: 18, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          const Text(
            "Tap + to add your first travel expense.",
            style: TextStyle(color: Colors.black38),
          ),
        ],
      ),
    );
  }
}
