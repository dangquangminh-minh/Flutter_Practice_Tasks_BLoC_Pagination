import 'package:flutter_bloc/flutter_bloc.dart';

import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  // mặc định là chế độ sáng
  ThemeBloc() : super(ThemeState(isDarkMode: false)) {
    
    // nhận s.kiện đổi màu nền thì cập nhật lại 
    on<ThemeChanged>((event, emit) {
      emit(ThemeState(isDarkMode: event.isDarkMode));
    });
    
  }
}