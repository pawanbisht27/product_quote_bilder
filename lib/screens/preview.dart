import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/quote_item.dart';

class QuotePreviewScreen extends StatelessWidget {
  final String clientName;
  final String clientAddress;
  final String clientRef;
  final List<QuoteItem> items;
  final double subtotal;
  final double totalTax;
  final double grandTotal;

  const QuotePreviewScreen({
    super.key,
    required this.clientName,
    required this.clientAddress,
    required this.clientRef,
    required this.items,
    required this.subtotal,
    required this.totalTax,
    required this.grandTotal,
  });

  @override
  Widget build(BuildContext context) {
    final nf = NumberFormat.currency(locale: 'en_IN', symbol: '₹ ');
    return Scaffold(
      appBar: AppBar(title: const Text('Quote Preview')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 18)
              ],
            ),
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('MERU TECHNOSOFT',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        SizedBox(height: 6),
                        Text('Quote Number'),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                            'Date: ${DateTime.now().toLocal().toString().split(' ').first}'),
                        const SizedBox(height: 6),
                        const Text('PB-001'),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 14),

                // Client Information
                Text('Bill To:', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(clientName),
                const SizedBox(height: 4),
                Text(clientAddress),
                const SizedBox(height: 12),

                // Table Header , Items
                Table(
                  border: TableBorder.all(width: 1, color: Colors.grey.shade200),
                  columnWidths: const {
                    0: FlexColumnWidth(4),
                    1: FlexColumnWidth(1.2),
                    2: FlexColumnWidth(1.5),
                    3: FlexColumnWidth(1.2),
                    4: FlexColumnWidth(1.6)
                  },
                  children: [
                    TableRow(
                      decoration: BoxDecoration(color: Colors.blue.shade50),
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Description',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Qty',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Rate',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Tax',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Total',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    ...items.map(
                          (it) => TableRow(
                        children: [
                          Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(it.name.isEmpty ? '-' : it.name)),
                          Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(it.quantity.toString())),
                          Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(nf.format(it.rate))),
                          Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('${it.taxPercent}%')),
                          Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(nf.format(it.total))),
                        ],
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 16),

                // Totals
                Align(
                  alignment: Alignment.centerRight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Subtotal: ${nf.format(subtotal)}'),
                      Text('Total Tax: ${nf.format(totalTax)}'),
                      const SizedBox(height: 8),
                      Text('Grand Total: ${nf.format(grandTotal)}',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Send')));
                        },
                        icon: const Icon(Icons.send_outlined),
                        label: const Text('Send'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}