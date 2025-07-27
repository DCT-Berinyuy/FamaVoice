import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:famavoice/models/price_model.dart';

class PriceService {
  Future<List<Price>> loadPrices() async {
    final String response = await rootBundle.loadString('assets/data/prices.json');
    final data = await json.decode(response);
    return (data['prices'] as List)
        .map((priceJson) => Price.fromJson(priceJson))
        .toList();
  }
}