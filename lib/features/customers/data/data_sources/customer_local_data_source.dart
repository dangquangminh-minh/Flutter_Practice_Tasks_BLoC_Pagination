import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/customer_model.dart'; 

class CustomerLocalDataSource {
  static const String _cacheKey = 'CACHED_CUSTOMERS_PAGE_1';
  //tương tự như bên dssp , lưu trang 1 dô
  Future<void> cacheFirstPage(List<Customer> customers) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> jsonList = customers.map((c) => c.toJson()).toList();
    await prefs.setString(_cacheKey, json.encode(jsonList));
  }

  // đọc ds từ máy khi k có mạng
  Future<List<Customer>?> getCachedFirstPage() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_cacheKey); 
    if (jsonString != null) {
      final List decoded = json.decode(jsonString); 
      return decoded.map((e) => Customer.fromJson(e)).toList();
    }
    return null;
  }
}