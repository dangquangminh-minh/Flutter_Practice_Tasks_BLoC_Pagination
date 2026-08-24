import 'package:flutter/material.dart';

import '../../domain/models/customer_model.dart';
import '../../data/data_sources/customer_remote_data_source.dart';

class CustomerDetailPage extends StatelessWidget {
  final int customerId;

  const CustomerDetailPage({super.key, required this.customerId});

  @override
  Widget build(BuildContext context) {
    final dataSource = CustomerRemoteDataSource();

    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết Khách hàng')),


      body: FutureBuilder<Customer>(
        future: dataSource.fetchCustomerDetail(customerId),
        builder: (context, snapshot) {

          // chờ api phản hồi , hiện vòng xoay
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // api lỗi , hiện t.báo
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }

            //t.công , lấy data vẽ lên ui
          final customer = snapshot.data!;


          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                CircleAvatar(

                  radius: 50,
                  backgroundImage: NetworkImage(customer.image),
                ),
                const SizedBox(height: 16),
                Text(
                  customer.fullName,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                Chip(label: Text('Role: ${customer.role}')),
                const Divider(height: 32),
                
                // h.thi ttin k có gắn pass ,bank dô
                ListTile(
                  leading: const Icon(Icons.email),
                  title: const Text('Email'),
                  subtitle: Text(customer.email),
                ),
                ListTile(
                  leading: const Icon(Icons.phone),
                  title: const Text('Điện thoại'),
                  subtitle: Text(customer.phone),
                ),


                ListTile(
                  leading: const Icon(Icons.business),
                  title: const Text('Công ty / Chức vụ'),
                  subtitle: Text(customer.companyTitle),
                ),
                ListTile(
                  leading: const Icon(Icons.location_city),
                  title: const Text('Thành phố'),
                  subtitle: Text(customer.addressCity),
                ),
                
                
              ],
            ),
          );
        },
      ),
    );
  }
}