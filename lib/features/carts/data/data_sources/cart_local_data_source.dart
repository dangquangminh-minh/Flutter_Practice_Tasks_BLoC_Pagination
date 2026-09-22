
import 'dart:convert';
import 'package:bai_01/features/carts/domain/models/cart_model.dart';
import 'package:shared_preferences/shared_preferences.dart';


class CartLocalDataSource {
  

  CartLocalDataSource();

  // lưu ds giở hàng của user
  Future<void> saveUserCarts(int userId, List<CartModel> carts) async {

    final prefs = await SharedPreferences.getInstance(); 
    
    final jsonList = carts.map((cart) => cart.toJson()).toList();
    await prefs.setString('cached_carts_$userId', jsonEncode(jsonList));
  }

  // lấy ds giỏ hàng ra 
  Future<List<CartModel>?> getCachedUserCarts(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('cached_carts_$userId');
    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => CartModel.fromJson(json)).toList();
    }
    return null;
  }
}