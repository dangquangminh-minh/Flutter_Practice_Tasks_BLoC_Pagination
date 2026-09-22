import 'package:bai_01/features/app/presentation/app_router.dart';
import 'package:bai_01/features/carts/data/repositories/cart_repository.dart';
import 'package:bai_01/features/carts/presentation/bloc/cart_bloc/cart_bloc.dart';
import 'package:bai_01/features/carts/presentation/bloc/cart_bloc/cart_event.dart';
import 'package:bai_01/features/carts/presentation/pages/customer_carts_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/customer_bloc.dart';
import '../bloc/customer_event.dart';
import '../bloc/customer_state.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomerDetailPage extends StatefulWidget {
  final int customerId;

  const CustomerDetailPage({super.key, required this.customerId});

  @override
  State<CustomerDetailPage> createState() => _CustomerDetailPageState();
}

class _CustomerDetailPageState extends State<CustomerDetailPage> {
  @override
  void initState() {
    super.initState();
    // bắn event lấy dl k.hàng
    context.read<CustomerBloc>().add(GetCustomerDetailEvent(widget.customerId));
  }

  // hàm gọi điện , email ,nhắn tin
  Future<void> _launchAction(String action, String data) async {
    final Uri url = Uri.parse('$action:$data');
    try {
      if (!await launchUrl(url)) {
        debugPrint('Không thể mở $url');
      }
    } catch (e) {
      debugPrint('Lỗi url_launcher: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết Khách hàng')),
      body: BlocBuilder<CustomerBloc, CustomerState>(
        builder: (context, state) {
          
          //loading chờ api
          if (state.isLoadingDetail) {
            return const Center(child: CircularProgressIndicator());
          }

          // xử lý lỗi
          if (state.detailErrorMessage.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Lỗi: ${state.detailErrorMessage}'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      //bắn event khi bấm thử lại để lấy lại ds k.hàng
                      context.read<CustomerBloc>().add(GetCustomerDetailEvent(widget.customerId));
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          //ui vẽ thành côg
          if (state.customerDetail != null) {
            final customer = state.customerDetail!;
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

                  const SizedBox(height: 24),
                  //các nút
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // điện thoại
                      _buildQuickActionButton(
                        icon: Icons.call, 
                        color: Colors.green, 
                        onTap: () => _launchAction('tel', customer.phone),
                      ),
                      const SizedBox(width: 24),
                      // nhắn tin
                      _buildQuickActionButton(
                        icon: Icons.message, 
                        color: Colors.orange, 
                        onTap: () => _launchAction('sms', customer.phone),
                      ),
                      const SizedBox(width: 24),
                      // gửi mail
                      _buildQuickActionButton(
                        icon: Icons.email, 
                        color: Colors.blue, 
                        onTap: () => _launchAction('mailto', customer.email),
                      ),
                    ],
                  ),
                    const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // nút : đơn hàng
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.shopping_cart),
                        label: const Text('Đơn Hàng', style: TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BlocProvider(
                                create: (context) => CartBloc(
                                  context.read<CartRepository>(), 
                                )..add(LoadCartsByUserEvent(customer.id)),
                                child: CustomerCartsPage(userId: customer.id),
                              ),
                            ),
                          );
                        },
                      ),
                      
                      // nút : hỗ trọw
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          backgroundColor: Colors.orangeAccent,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.support_agent),
                        label: const Text('Hỗ Trợ', style: TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: () {
                          context.push(AppRouter.helpSupport, extra: customer.id); 
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  const Divider(height: 32),

                  ListTile(
                    //hiển thị tt không có pass hay bank 
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
          }

          
          return const SizedBox.shrink();
        },
      ),
    );
  }

  // ui 3 nút thao tác nhanh
  Widget _buildQuickActionButton({required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1), 
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }
}