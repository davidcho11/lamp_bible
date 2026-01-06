class DateHelper {
  static bool isLeapYear(int year) {
    if (year % 400 == 0) return true;
    if (year % 100 == 0) return false;
    if (year % 4 == 0) return true;
    return false;
  }

  static int getTotalDaysInYear(int year) {
    return isLeapYear(year) ? 366 : 365;
  }

  static bool shouldShow229(int year) {
    return isLeapYear(year);
  }

  static int getDaysInMonth(int year, int month) {
    switch (month) {
      case 1:
      case 3:
      case 5:
      case 7:
      case 8:
      case 10:
      case 12:
        return 31;
      case 4:
      case 6:
      case 9:
      case 11:
        return 30;
      case 2:
        return isLeapYear(year) ? 29 : 28;
      default:
        return 30;
    }
  }

  static bool isValidDate(int year, int month, int day) {
    if (month < 1 || month > 12) return false;
    if (day < 1) return false;
    return day <= getDaysInMonth(year, month);
  }

  static DateTime getToday() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static bool isBeforeToday(int year, int month, int day) {
    final target = DateTime(year, month, day);
    final today = getToday();
    return target.isBefore(today);
  }

  static bool isToday(int year, int month, int day) {
    final today = DateTime.now();
    return year == today.year && month == today.month && day == today.day;
  }
}
