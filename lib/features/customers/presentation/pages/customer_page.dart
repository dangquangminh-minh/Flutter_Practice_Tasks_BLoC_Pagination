import 'package:bai_01/features/customers/data/data_sources/customer_local_data_source.dart';
import 'package:bai_01/features/customers/domain/models/customer_model.dart';
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
  final TextEditingController _searchController = TextEditingController();
  @override
  void initState() {
    super.initState();

    if (context.read<CustomerBloc>().state.customers.isEmpty) { // chỉ nahr event khi ds trống
      context.read<CustomerBloc>().add(FetchCustomersInitial());
    }

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      
      appBar: AppBar(title: const Text('Danh sách Khách hàng')),
      
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () => _showCustomerForm(context), // gọi hàm mở dialog thêm mới
        child: const Icon(Icons.add),
      ),
      
     body: BlocConsumer<CustomerBloc, CustomerState>(
        listenWhen: (previous, current) {
          return previous.errorMessage != current.errorMessage && current.errorMessage.isNotEmpty;
        },
        listener: (context, state) {
          if (state.errorMessage.isNotEmpty) {
            final realMessage = state.errorMessage.split('|').first.trim();
            
            // đổi màu xanh, đỏ tùy theo thông báo
            final isError = state.errorMessage.toLowerCase().contains('lỗi') || 
                            state.errorMessage.toLowerCase().contains('không');

            ScaffoldMessenger.of(context).hideCurrentSnackBar();          
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(realMessage, style: const TextStyle(color: Colors.white)), 
                backgroundColor: isError ? Colors.red : Colors.green,
                duration: const Duration(seconds: 2),
              ),
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
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm khách hàng...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: ValueListenableBuilder<TextEditingValue>(
                            valueListenable: _searchController,
                            builder: (context, value, child) {
                              return value.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.cancel, size: 20, color: Colors.grey),
                                      onPressed: () {
                                        _searchController.clear();
                                        context.read<CustomerBloc>().add(SearchCustomersChanged('')); 
                                      },
                                    )
                                  : const SizedBox.shrink();
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
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
                      icon: Icon(Icons.filter_list, color: Colors.deepPurple.shade700),
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
                    
                    ChoiceChip(
                      label: const Text('Tất cả'),
                      selected: state.filterRole == '',
                      showCheckmark: true,
                      selectedColor: isDark ? Colors.deepPurple.shade900 : Colors.deepPurple.shade50,
                      backgroundColor: isDark ? Colors.grey.shade800 : Colors.white,
                      side: BorderSide(
                        color: (state.filterRole == '')
                            ? (isDark ? Colors.deepPurple.shade300 : Colors.deepPurple.shade200)
                            : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                      ),
                      labelStyle: TextStyle(
                        color: (state.filterRole == '')
                            ? (isDark ? Colors.deepPurple.shade200 : Colors.deepPurple.shade700)
                            : (isDark ? Colors.white70 : Colors.black87),
                        fontWeight: (state.filterRole == '') ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (_) => context.read<CustomerBloc>().add(CustomerFilterRoleChanged('')),
                    ),

                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('admin'),
                      selected: state.filterRole == 'admin',
                      showCheckmark: true,
                      selectedColor: isDark ? Colors.deepPurple.shade900 : Colors.deepPurple.shade50,
                      backgroundColor: isDark ? Colors.grey.shade800 : Colors.white,
                      side: BorderSide(
                        color: (state.filterRole == 'admin')
                            ? (isDark ? Colors.deepPurple.shade300 : Colors.deepPurple.shade200)
                            : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                      ),
                      labelStyle: TextStyle(
                        color: (state.filterRole == 'admin')
                            ? (isDark ? Colors.deepPurple.shade200 : Colors.deepPurple.shade700)
                            : (isDark ? Colors.white70 : Colors.black87),
                        fontWeight: (state.filterRole == 'admin') ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (_) => context.read<CustomerBloc>().add(CustomerFilterRoleChanged('admin')),
                    ),


                    const SizedBox(width: 8),
                   ChoiceChip(
                      label: const Text('user'),
                      selected: state.filterRole == 'user',
                      showCheckmark: true,
                      selectedColor: isDark ? Colors.deepPurple.shade900 : Colors.deepPurple.shade50,
                      backgroundColor: isDark ? Colors.grey.shade800 : Colors.white,
                      side: BorderSide(
                        color: (state.filterRole == 'user')
                            ? (isDark ? Colors.deepPurple.shade300 : Colors.deepPurple.shade200)
                            : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                      ),
                      labelStyle: TextStyle(
                        color: (state.filterRole == 'user')
                            ? (isDark ? Colors.deepPurple.shade200 : Colors.deepPurple.shade700)
                            : (isDark ? Colors.white70 : Colors.black87),
                        fontWeight: (state.filterRole == 'user') ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (_) => context.read<CustomerBloc>().add(CustomerFilterRoleChanged('user')),
                    ),

                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('moderator'), 
                      selected: state.filterRole == 'moderator',
                      showCheckmark: true,
                      selectedColor: isDark ? Colors.deepPurple.shade900 : Colors.deepPurple.shade50,
                      backgroundColor: isDark ? Colors.grey.shade800 : Colors.white,
                      side: BorderSide(
                        color: (state.filterRole == 'moderator')
                            ? (isDark ? Colors.deepPurple.shade300 : Colors.deepPurple.shade200)
                            : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                      ),
                      labelStyle: TextStyle(
                        color: (state.filterRole == 'moderator')
                            ? (isDark ? Colors.deepPurple.shade200 : Colors.deepPurple.shade700)
                            : (isDark ? Colors.white70 : Colors.black87),
                        fontWeight: (state.filterRole == 'moderator') ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (_) => context.read<CustomerBloc>().add(CustomerFilterRoleChanged('moderator')),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              

              // ds
              Expanded(
                // ktra ds rỗng 
                child: state.customers.isEmpty
                    ?  Center(
                        // ui show ra khi ds rỗng
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off_rounded, size: 80, color: Colors.grey.shade300),                           
                            const SizedBox(height: 16),
                            const Text(
                              'Không tìm thấy khách hàng',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Không có dữ liệu nào khớp với từ khóa bạn vừa nhập.\nVui lòng thử một từ khóa khác.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                            ),
                            const SizedBox(height: 24),
                            // nút xóa tìm kiếm
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.blueAccent.shade100),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                _searchController.clear();
                                context.read<CustomerBloc>().add(SearchCustomersChanged(''));
                                context.read<CustomerBloc>().add(CustomerFilterRoleChanged(''));
                              },
                              icon: const Icon(Icons.clear, color: Colors.blueAccent),
                              label: const Text('Xóa tìm kiếm', style: TextStyle(color: Colors.blueAccent)),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        // chừa thêm 1 chỗ dưới đáy để hiện vòng xoay hoặc retry
                        itemCount: state.customers.length + ((state.isLoadingMore || state.errorMessage.isNotEmpty) ? 1 : 0),
                        
                        separatorBuilder: (context, index) => Divider(color: Colors.grey.shade200, height: 1),

                        itemBuilder: (context, index) {
                          // dl k.hàng
                          if (index < state.customers.length) {
                            final customer = state.customers[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(customer.image),
                              ),
                              title: Text(customer.fullName),
                              subtitle: Text('${customer.email} • ${customer.role}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  //menu sửa, xóa
                                  PopupMenuButton<String>(
                                    onSelected: (value) {
                                      if (value == 'edit') {
                                        _showCustomerForm(context, customerToEdit: customer);
                                      } else if (value == 'delete') {
                                        // Hiện bảng xác nhận trước khi xóa
                                        showDialog(
                                          context: context,
                                          builder: (confirmContext) => AlertDialog(
                                            title: const Text('Xác nhận xóa'),
                                            content: Text('Bạn có chắc muốn xóa "${customer.fullName}" không?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(confirmContext), 
                                                child: const Text('Hủy'),
                                              ),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                                onPressed: () {
                                                  // Bắn sự kiện xóa vào CustomerBloc của chúng ta
                                                  context.read<CustomerBloc>().add(DeleteCustomerRequested(customer.id));
                                                  Navigator.pop(confirmContext);
                                                },
                                                child: const Text('Xóa', style: TextStyle(color: Colors.white)),
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(value: 'edit', child: Text('Sửa')),
                                      const PopupMenuItem(value: 'delete', child: Text('Xóa', style: TextStyle(color: Colors.red))),
                                    ],
                                  ),
                                  const SizedBox(width: 8),
                                ],
                              ),
                              onTap: () {
                                context.push('/customer-detail/${customer.id}');
                              },
                            );
                          }

                          // khi tải dl thì hiện vòng xoay
                          if (state.isLoadingMore) {
                            return const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          // hiện nút retry nếu  lỗi mạng
                          if (state.errorMessage.isNotEmpty) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                              child: Column(
                                children: [
                                  Text(state.errorMessage, style: const TextStyle(color: Colors.red)),
                                  const SizedBox(height: 8),
                                  ElevatedButton.icon(
                                    onPressed: () => context.read<CustomerBloc>().add(LoadMoreCustomers()), // Bấm vào để gọi lại event load more
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('Thử lại'),
                                  ),
                                ],
                              ),
                            );
                          }
                          
                          return const SizedBox.shrink();
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
// hàm hiển thị dialog thêm,xóa,sửaa
  void _showCustomerForm(BuildContext context, {Customer? customerToEdit}) {
    final firstNameController = TextEditingController(text: customerToEdit?.firstName ?? '');
    final lastNameController = TextEditingController(text: customerToEdit?.lastName ?? '');
    final emailController = TextEditingController(text: customerToEdit?.email ?? '');
    final formKey = GlobalKey<FormState>();
    
    //nếu thêm mới thì mặc định là user
    String selectedRole = customerToEdit?.role ?? 'user'; 

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(customerToEdit == null ? 'Thêm khách hàng mới' : 'Cập nhật thông tin'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: firstNameController,
                decoration: const InputDecoration(labelText: 'Họ (First Name)'),
                validator: (value) => value == null || value.isEmpty ? 'Không được để trống' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: lastNameController,
                decoration: const InputDecoration(labelText: 'Tên (Last Name)'),
                validator: (value) => value == null || value.isEmpty ? 'Không được để trống' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Vui lòng nhập Email';
                  
                  // ktra email vs đầy đủ duôi @gmail.com
                  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailRegex.hasMatch(value.trim())) {
                    return 'Email không hợp lệ (VD: ten@domain.com)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // dropdown
              DropdownButtonFormField<String>(
                initialValue: selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Vai trò',
                  border: UnderlineInputBorder(),
                ),
                items: ['admin', 'user', 'moderator'].map((role) {
                  return DropdownMenuItem(value: role, child: Text(role));
                }).toList(),
                onChanged: (val) {
                  if (val != null) selectedRole = val;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy', style: TextStyle(color: Colors.deepPurple)), 
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.deepPurple,
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), 
            ),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final firstName = firstNameController.text.trim();
                final lastName = lastNameController.text.trim();
                final email = emailController.text.trim();

                if (customerToEdit == null) {
                  // Bắn sự kiện Thêm mới lên CustomerBloc
                  context.read<CustomerBloc>().add(AddCustomerRequested(
                    firstName: firstName,
                    lastName: lastName,
                    email: email,
                    role: selectedRole,
                    image: 'https://robohash.org/default.png?set=set4', 
                  ));
                } else {
                  // nahr event cập nhât lên
                  context.read<CustomerBloc>().add(UpdateCustomerRequested(
                    id: customerToEdit.id,
                    firstName: firstName,
                    lastName: lastName,
                    email: email,
                    role: selectedRole,
                  ));
                }
                Navigator.pop(dialogContext); 
              }
            },
            child: Text(customerToEdit == null ? 'Thêm' : 'Lưu'),
          ),
        ],
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
          localDataSource: CustomerLocalDataSource(),
        ),
      ),
      child: const CustomerPage(),
    );
  }

  
}