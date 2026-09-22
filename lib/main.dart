import 'package:bai_01/features/app/presentation/bloc/theme_bloc.dart';
import 'package:bai_01/features/app/presentation/bloc/theme_state.dart';
import 'package:bai_01/features/carts/data/data_sources/cart_local_data_source.dart';
import 'package:bai_01/features/carts/data/data_sources/cart_remote_data_source.dart';
import 'package:bai_01/features/carts/data/repositories/cart_repository.dart';
import 'package:bai_01/features/carts/presentation/bloc/active_cart_bloc/active_cart_bloc.dart';
import 'package:bai_01/features/customers/data/data_sources/customer_local_data_source.dart';
import 'package:bai_01/features/profile/data/data_sources/profile_data_source.dart';
import 'package:bai_01/features/support/data/data_sources/support_remote_data_source.dart';
import 'package:bai_01/features/support/data/repositories/support_repository.dart';
import 'package:bai_01/features/support/presentation/bloc/support_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'features/app/presentation/app_router.dart';
import 'features/auth/data/data_sources/auth_data_source.dart';
import 'features/products/data/repositories/product_repository.dart';
import 'features/products/data/data_sources/local_data_source.dart';
import 'features/products/data/data_sources/remote_data_source.dart';
import 'features/products/presentation/bloc/cache_retry_bloc.dart'; 
import 'features/auth/presentation/bloc/auth_bloc.dart';


import 'features/profile/presentation/bloc/profile_bloc.dart'; 
import 'features/customers/data/repositories/customer_repository.dart';
import 'features/customers/data/data_sources/customer_remote_data_source.dart';
import 'features/customers/presentation/bloc/customer_bloc.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthService>(
          create: (context) => AuthService(),
        ),
        
        RepositoryProvider<ProfileService>(
          create: (context) => ProfileService(),
        ),
        
        RepositoryProvider<ProductRepository6>(
          create: (context) => ProductRepository6(
            localDataSource: LocalDataSource(),
            remoteDataSource: RemoteDataSource(),
          ),
        ),

        RepositoryProvider<CustomerRepository>(
          create: (context) => CustomerRepository(
           remoteDataSource: CustomerRemoteDataSource(),
           localDataSource: CustomerLocalDataSource(),
          ),
        ),

        RepositoryProvider<CartRepository>(
          create: (context) => CartRepository(
            remoteDataSource: CartRemoteDataSource(), 
            localDataSource: CartLocalDataSource(),   
          ),
        ),

       RepositoryProvider<SupportRepository>(
          create: (context) => SupportRepository(
            remoteDataSource: SupportRemoteDataSource(),
          ),
        ),
      ],
      
      
    
      child: MultiBlocProvider(
        providers: [
          
          // bloc đăng nhập/đăng ký 
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              context.read<AuthService>(),
              
            ),
          ),

          // bloc hồ sơ cá nhân 
          BlocProvider<ProfileBloc>(
            create: (context) => ProfileBloc(
              context.read<AuthService>(),
               context.read<ProfileService>(),
            ),
          ),

          // bloc Sản phẩm
          BlocProvider<ProductBloc6>(
            create: (context) => ProductBloc6(
              context.read<ProductRepository6>(), 
            ),
          ),

          BlocProvider<CustomerBloc>(
            create: (context) => CustomerBloc(
               context.read<CustomerRepository>(),
           )
          ),

          BlocProvider<ThemeBloc>(
            create: (context) => ThemeBloc(),
          ),

           BlocProvider<SupportBloc>(
            create: (context) => SupportBloc(
              context.read<SupportRepository>(), 
            ),
          ),

          BlocProvider<ActiveCartBloc>(
            create: (context) => ActiveCartBloc(
              context.read<CartRepository>(),
            ),
          ),
        ],
        
      
        
        child: BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, themeState) {
            return MaterialApp.router(
              title: 'IT App',
              debugShowCheckedModeBanner: false,
              showSemanticsDebugger: false,
              
              // cấu hình theme sáng , tối
              theme: ThemeData.light(),
              darkTheme: ThemeData.dark(),
              
              // đọc state từ bloc để quyết định màu
              themeMode: themeState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
              
              routerConfig: AppRouter.router, 
            );
          },
        ),
      ),
    );
  }
}