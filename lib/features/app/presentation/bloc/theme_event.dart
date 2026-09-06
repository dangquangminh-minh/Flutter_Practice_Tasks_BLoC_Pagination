abstract class ThemeEvent {}

class ThemeChanged extends ThemeEvent {
  final bool isDarkMode;
  
  ThemeChanged(this.isDarkMode);
}