import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum DateFormatOption {
  dmy, // DD/MM/YYYY
  mdy, // MM/DD/YYYY
  ymd, // YYYY/MM/DD
}

class DateTimeFormatter {
  DateTimeFormatter._();

  static const String _dateFormatKey = 'selected_date_format';
  static const String _hour24Key = 'is_24_hour_format';

  static DateFormatOption _currentDateFormat = DateFormatOption.dmy;
  static bool _is24Hour = true;

  static DateFormatOption get currentDateFormat => _currentDateFormat;
  static bool get is24Hour => _is24Hour;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final df = prefs.getString(_dateFormatKey);
    if (df != null) {
      _currentDateFormat = DateFormatOption.values.firstWhere(
        (e) => e.name == df,
        orElse: () => DateFormatOption.dmy,
      );
    }
    _is24Hour = prefs.getBool(_hour24Key) ?? true;
  }

  static Future<void> setDateFormat(DateFormatOption option) async {
    _currentDateFormat = option;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dateFormatKey, option.name);
  }

  static Future<void> set24Hour(bool is24) async {
    _is24Hour = is24;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hour24Key, is24);
  }

  static String formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    switch (_currentDateFormat) {
      case DateFormatOption.dmy:
        return '$day/$month/$year';
      case DateFormatOption.mdy:
        return '$month/$day/$year';
      case DateFormatOption.ymd:
        return '$year/$month/$day';
    }
  }

  static String formatTime(int hour, int minute) {
    if (_is24Hour) {
      final h = hour.toString().padLeft(2, '0');
      final m = minute.toString().padLeft(2, '0');
      return '$h:$m';
    } else {
      final period = hour >= 12 ? 'PM' : 'AM';
      final h = hour % 12 == 0 ? 12 : hour % 12;
      final m = minute.toString().padLeft(2, '0');
      return '$h:$m $period';
    }
  }

  static String formatDateWithDay(DateTime date, String locale) {
    final dayName = DateFormat('EEEE', locale).format(date);
    return '$dayName, ${formatDate(date)}';
  }
}
