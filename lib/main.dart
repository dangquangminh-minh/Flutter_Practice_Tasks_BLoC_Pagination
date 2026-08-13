import 'package:flutter/material.dart';


import 'bai_01/post_page.dart'; 
import 'bai_02/page.dart';

import "bai_03/page.dart";
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Thực tập BLoC',
      debugShowCheckedModeBanner: false, // Tắt dải ruy-băng chữ Debug ở góc màn hình
      home: const MenuPage(), // Đặt trang chủ là màn hình Menu
    );
  }
}

// 2. Màn hình Menu chính
class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thực Hành BLoC - 6 Bài'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- BÀI 1 ---
          ElevatedButton(
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
            onPressed: () {
              // Khi bấm vào sẽ điều hướng sang file post_page.dart
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Bai1()),
              );
            },
            child: const Text(
              'Bài 1: Danh sách bài viết với BLoC', 
              style: TextStyle(fontSize: 16),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // --- BÀI 2---
          ElevatedButton(
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
            onPressed: () {
             Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Bai2()),
              );
            },
            child: const Text(
              'Bài 2: Phân trang bằng nút Xem thêm', 
              style: TextStyle(fontSize: 16),
            ),
          ),

          const SizedBox(height: 16),
          
           // --- BÀI 3 ---
          ElevatedButton(
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
            onPressed: () {
              
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Bai3()),
              );
            },
            child: const Text(
              'Bài 3: Infinite Scroll với BLoC', 
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}