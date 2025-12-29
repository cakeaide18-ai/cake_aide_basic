import 'package:flutter/material.dart';
import 'package:cake_aide_basic/models/quote.dart';
import 'package:cake_aide_basic/repositories/quote_repository.dart';
import 'package:cake_aide_basic/screens/quotes/add_quote_screen.dart';
import 'package:cake_aide_basic/screens/quotes/quote_details_screen.dart';
import 'package:cake_aide_basic/theme.dart';
import 'package:cake_aide_basic/widgets/quote_icon.dart';

class QuotesScreen extends StatefulWidget {
  const QuotesScreen({super.key});

  @override
  State<QuotesScreen> createState() => _QuotesScreenState();
}

class _QuotesScreenState extends State<QuotesScreen> {
  final QuoteRepository _quoteRepository = QuoteRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Quote Calculator'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: GradientDecorations.primaryGradient,
          ),
        ),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Quote>>(
        stream: _quoteRepository.getQuotesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error loading quotes: ${snapshot.error}'),
                ],
              ),
            );
          }

          final quotes = snapshot.data ?? [];

          if (quotes.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: quotes.length,
            itemBuilder: (context, index) {
              final quote = quotes[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuoteDetailsScreen(quote: quote),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Center(
                            child: QuoteIcon(size: 24),
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                quote.name,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                quote.description.length > 40 
                                  ? '${quote.description.substring(0, 40)}...' 
                                  : quote.description,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    '${quote.currencySymbol}${quote.totalCost.toStringAsFixed(2)}',
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const Spacer(),
                                  if (quote.recipes.isNotEmpty)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.green[100],
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                         child: Text(
                                          '${quote.recipes.length} Recipe${quote.recipes.length > 1 ? 's' : ''}',
                                          style: TextStyle(
                                            fontSize: 10,
                                             color: Colors.green[800],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                           Icon(
                            Icons.chevron_right,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                           ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddQuoteScreen(),
            ),
          );
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.purple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Center(
              child: QuoteIcon(size: 60),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Quotes Yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first price quote',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddQuoteScreen(),
                ),
              ).then((_) => setState(() {}));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.add),
            label: const Text('Create Quote'),
          ),
        ],
      ),
    );
  }
}