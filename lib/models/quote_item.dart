import 'package:flutter/material.dart';

class QuoteItem {
  final TextEditingController nameCtrl;
  final TextEditingController qtyCtrl;
  final TextEditingController rateCtrl;
  final TextEditingController discountCtrl;
  final TextEditingController taxCtrl;

  QuoteItem({
    String name = '',
    int quantity = 0,
    double rate = 0.0,
    double discount = 0.0,
    double taxPercent = 0.0,
  })  : nameCtrl = TextEditingController(text: name),
        qtyCtrl = TextEditingController(text: quantity.toString()),
        rateCtrl = TextEditingController(text: rate.toString()),
        discountCtrl = TextEditingController(text: discount.toString()),
        taxCtrl = TextEditingController(text: taxPercent.toString());

  String get name => nameCtrl.text;
  int get quantity => int.tryParse(qtyCtrl.text) ?? 0;
  double get rate => double.tryParse(rateCtrl.text) ?? 0.0;
  double get discount => double.tryParse(discountCtrl.text) ?? 0.0;
  double get taxPercent => double.tryParse(taxCtrl.text) ?? 0.0;

  double get taxableAmount => (rate - discount) * quantity;
  double get taxAmount => taxableAmount * (taxPercent / 100);
  double get total => taxableAmount + taxAmount;

  Map<String, dynamic> toJson() => {
    'name': name,
    'quantity': quantity,
    'rate': rate,
    'discount': discount,
    'taxPercent': taxPercent,
  };

  factory QuoteItem.fromJson(Map<String, dynamic> j) {
    return QuoteItem(
      name: j['name'] ?? '',
      quantity: (j['quantity'] ?? 0) as int,
      rate: (j['rate'] ?? 0.0).toDouble(),
      discount: (j['discount'] ?? 0.0).toDouble(),
      taxPercent: (j['taxPercent'] ?? 0.0).toDouble(),
    );
  }

  void dispose() {
    nameCtrl.dispose();
    qtyCtrl.dispose();
    rateCtrl.dispose();
    discountCtrl.dispose();
    taxCtrl.dispose();
  }
}