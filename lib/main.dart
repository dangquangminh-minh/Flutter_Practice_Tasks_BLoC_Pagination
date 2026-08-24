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
import 'features/profile/presentation/bloc/profile_event.dart';

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
        
        RepositoryProvider<ProductRepository6>(
          create: (context) => ProductRepository6(
            localDataSource: LocalDataSource(),
            remoteDataSource: RemoteDataSource(),
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
            )..add(ProfileFetchStarted()), 
          ),

          // bloc Sản phẩm
          BlocProvider<ProductBloc6>(
            create: (context) => ProductBloc6(
              context.read<ProductRepository6>(), 
            ),
          ),
        ],
        
        //giao diện
        child: MaterialApp.router(
          title: 'IT App',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          routerConfig: AppRouter.router, 
        ),
      ),
    );
  }
}