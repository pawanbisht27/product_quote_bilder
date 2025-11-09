import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/quote_item.dart';
import 'preview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class QuoteFormScreen extends StatefulWidget {
  const QuoteFormScreen({super.key});

  @override
  State<QuoteFormScreen> createState() => _QuoteFormScreenState();
}

class _QuoteFormScreenState extends State<QuoteFormScreen>
    with SingleTickerProviderStateMixin {
  final _currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹ ');
  final _clientNameCtrl = TextEditingController();
  final _clientAddressCtrl = TextEditingController();
  final _clientRefCtrl = TextEditingController();

  List<QuoteItem> items = [QuoteItem()];
  bool taxInclusive = false;

  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    _clientNameCtrl.dispose();
    _clientAddressCtrl.dispose();
    _clientRefCtrl.dispose();
    for (var item in items) {
      item.dispose();
    }
    super.dispose();
  }

  void addItem() {
    setState(() {
      items.add(QuoteItem());
    });
  }

  void removeItem(int index) {
    setState(() {
      if (items.length > 1) {
        items[index].dispose();
        items.removeAt(index);
      }
    });
  }

  double get subtotal => items.fold(0.0, (p, e) => p + e.taxableAmount);
  double get totalTax => items.fold(0.0, (p, e) => p + e.taxAmount);
  double get grandTotal => subtotal + totalTax;

  Future<void> saveDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'clientName': _clientNameCtrl.text,
      'clientAddress': _clientAddressCtrl.text,
      'clientRef': _clientRefCtrl.text,
      'taxInclusive': taxInclusive,
      'items': items.map((e) => e.toJson()).toList(),
    };
    await prefs.setString('quoteDraft', jsonEncode(data));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Draft saved locally')));
  }

  Future<void> loadDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString('quoteDraft');
    if (s == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('No draft found')));
      return;
    }
    final j = jsonDecode(s);
    setState(() {
      _clientNameCtrl.text = j['clientName'] ?? '';
      _clientAddressCtrl.text = j['clientAddress'] ?? '';
      _clientRefCtrl.text = j['clientRef'] ?? '';
      taxInclusive = j['taxInclusive'] ?? false;
      items = (j['items'] as List)
          .map((e) => QuoteItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Draft loaded')));
  }

  Widget itemCard(int index) {
    final item = items[index];

    void updateFromFields() {
      setState(() {});
    }

    InputDecoration fieldDecoration(String label) {
      return InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      );
    }

    Widget numberField(TextEditingController ctrl, String label) {
      return SizedBox(
        width: 120,
        child: TextField(
          controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: fieldDecoration(label),
          onChanged: (_) => updateFromFields(),
        ),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: item.nameCtrl,
                  decoration: fieldDecoration('Product / Service'),
                  onChanged: (_) => updateFromFields(),
                ),
              ),
              IconButton(
                onPressed: () => removeItem(index),
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              )
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              numberField(item.qtyCtrl, 'Qty'),
              numberField(item.rateCtrl, 'Rate'),
              numberField(item.discountCtrl, 'Discount'),
              numberField(item.taxCtrl, 'Tax %'),
            ],
          ),
          const SizedBox(height: 10),
          // Totals
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(item.name.isEmpty ? '—' : item.name,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Tax: ${_currencyFormat.format(item.taxAmount)}'),
                  Text('Total: ${_currencyFormat.format(item.total)}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  Future<void> _showSendSuccess() async {
    await _animController.forward();
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Send Result',
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (_, __, ___) => Center(
        child: ScaleTransition(
          scale:
          CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
          child: Container(
            width: 300,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                )
              ],
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.check_circle_outline,
                  size: 72, color: Colors.green),
              const SizedBox(height: 8),
              const Text('Quote Sent',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  _animController.reverse();
                  Navigator.of(context).pop();
                },
                child: const Text('Done'),
              )
            ]),
          ),
        ),
      ),
      transitionBuilder: (_, anim, __, child) =>
          FadeTransition(opacity: anim, child: child),
    ).then((_) => _animController.reset());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade600, Colors.indigo.shade600],
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Product Quote Builder',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Client Info
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 12,
                    )
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _clientNameCtrl,
                            decoration: const InputDecoration(
                                labelText: 'Client Name',
                                fillColor: Color(0xFFF5F5F5),
                                filled: true),
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 140,
                          child: TextField(
                            controller: _clientRefCtrl,
                            decoration: const InputDecoration(
                                labelText: 'Reference',
                                fillColor: Color(0xFFF5F5F5),
                                filled: true),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _clientAddressCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Client Address',
                          fillColor: Color(0xFFF5F5F5),
                          filled: true),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Line Items
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Line Items',
                      style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      const Text('Tax inclusive'),
                      Switch(
                        value: taxInclusive,
                        onChanged: (v) => setState(() => taxInclusive = v),
                        activeColor: Colors.blue.shade500,
                        inactiveThumbColor: Colors.grey.shade600,
                        inactiveTrackColor: Colors.grey.shade300,
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: addItem,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Item'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade500,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...items.map((e) => itemCard(items.indexOf(e))).toList(),

              const SizedBox(height: 20),

              // Totals
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05), blurRadius: 12)
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subtotal',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(_currencyFormat.format(subtotal)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Tax',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(_currencyFormat.format(totalTax)),
                      ],
                    ),
                    const Divider(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Grand Total',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(
                          _currencyFormat.format(grandTotal),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => QuotePreviewScreen(
                                  clientName: _clientNameCtrl.text,
                                  clientAddress: _clientAddressCtrl.text,
                                  clientRef: _clientRefCtrl.text,
                                  items: items,
                                  subtotal: subtotal,
                                  totalTax: totalTax,
                                  grandTotal: grandTotal,
                                ),
                              ));
                            },
                            child: const Text('Preview'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: saveDraft,
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // Bottom Buttons (Load Draft and Send Quote)
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            child: Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.08), blurRadius: 10)
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextButton.icon(
                      onPressed: loadDraft,
                      icon: const Icon(Icons.download_outlined),
                      label: const Text('Load Draft'),
                    ),
                  ),
                  const VerticalDivider(width: 10, thickness: 1),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await _showSendSuccess();
                      },
                      icon: const Icon(Icons.send_outlined),
                      label: const Text('Send Quote'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}