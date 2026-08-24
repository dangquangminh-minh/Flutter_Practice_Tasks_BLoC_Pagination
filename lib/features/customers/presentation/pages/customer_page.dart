import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/customer_bloc.dart';
import '../bloc/customer_event.dart';
import '../bloc/customer_state.dart';

import '../../data/repositories/customer_repository.dart';
import '../../data/data_sources/customer_remote_data_source.dart';
import 'package:go_router/go_router.dart';

class CustomerPage extends StatefulWidget {
  const CustomerPage({super.key});

  @override
  State<CustomerPage> createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();


    context.read<CustomerBloc>().add(FetchCustomersInitial()); // vừa dô trag là nhả event để lấy dl

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) { // cuộn gần xuống ds 200px thì nahr event tải thêm 
        context.read<CustomerBloc>().add(LoadMoreCustomers());
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose(); // hủy khi thoát màn hình để k tràn bn
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Danh sách Khách hàng')),
      body: BlocConsumer<CustomerBloc, CustomerState>(
        listener: (context, state) {

          if (state.errorMessage.isNotEmpty && state.customers.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar( 
              SnackBar(content: Text(state.errorMessage), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          // tải dl khi ch có k.hàng  nào , thì hiện vòng xoay
          if (state.isLoadingInitial && state.customers.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // lỗi khi tải lần đầu thì hiện nút thử lại
          if (state.errorMessage.isNotEmpty && state.customers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.errorMessage),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => context.read<CustomerBloc>().add(FetchCustomersInitial()),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // thanh tìm kiếm và nút s.xếp
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(

                          hintText: 'Tìm kiếm khách hàng...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 0),

                        ),
                        onChanged: (query) {
                          context.read<CustomerBloc>().add(SearchCustomersChanged(query));// nahr event khi n.dùng t.kiếm
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    // nút s.xếp
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.filter_list),
                      tooltip: 'Sắp xếp',
                      onSelected: (value) {
                        context.read<CustomerBloc>().add(CustomerSortOrderChanged(value));
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'asc',
                          child: Text(

                            'Tên A-Z',
                            style: TextStyle(
                              color: state.sortOrder == 'asc' ? Colors.blue : null,
                              fontWeight: state.sortOrder == 'asc' ? FontWeight.bold : null,
                            ),
                          ),
                        ),
                        PopupMenuItem(
                          value: 'desc',
                          child: Text(
                            'Tên Z-A',
                            style: TextStyle(
                              color: state.sortOrder == 'desc' ? Colors.blue : null,
                              fontWeight: state.sortOrder == 'desc' ? FontWeight.bold : null,
                            ),
                          ),
                        ),
                        const PopupMenuItem(
                          value: '',
                          child: Text('Mặc định'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // thanh lọc 
              SizedBox(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [

                    ChoiceChip( // chỉ đc chọn 1 cái lọc 
                      label: const Text('Tất cả'),
                      selected: state.filterRole == '',
                      showCheckmark: true,
                      onSelected: (_) => context.read<CustomerBloc>().add(CustomerFilterRoleChanged('')),
                    ),

                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('admin'),
                      selected: state.filterRole == 'admin',
                      showCheckmark: true,
                      onSelected: (_) => context.read<CustomerBloc>().add(CustomerFilterRoleChanged('admin')),
                    ),


                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('user'),
                      selected: state.filterRole == 'user',
                      showCheckmark: true,
                      onSelected: (_) => context.read<CustomerBloc>().add(CustomerFilterRoleChanged('user')),
                    ),

                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('moderator'), // DummyJSON thi thoảng có role này
                      selected: state.filterRole == 'moderator',
                      showCheckmark: true,
                      onSelected: (_) => context.read<CustomerBloc>().add(CustomerFilterRoleChanged('moderator')),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              

              // ds
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,

                  // chừa  1 slg phần tử để hiện vòng xoay
                  itemCount: state.customers.length + (state.isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index < state.customers.length) {
                      final customer = state.customers[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(customer.image),
                        ),
                        title: Text(customer.fullName),
                        subtitle: Text('${customer.email} • ${customer.role}'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          // chuyển sang m.hình c.tiết
                          context.push('/customer-detail/${customer.id}');
                        },
                      );
                    }
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

//  cung cấp bloc cho page của customer
class CustomerFeatureEntry extends StatelessWidget {
  const CustomerFeatureEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CustomerBloc(
        CustomerRepository(
          remoteDataSource: CustomerRemoteDataSource(),
        ),
      )..add(FetchCustomersInitial()),
      child: const CustomerPage(),
    );
  }
}