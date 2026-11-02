/// Ngày dạng dd/MM/yyyy.
String formatDate(DateTime date) {
  String twoDigits(int value) => value.toString().padLeft(2, '0');
  return '${twoDigits(date.day)}/${twoDigits(date.month)}/${date.year}';
}

/// Khoảng cách gọn: "8 m", "350 m", "1,2 km".
String formatDistance(double meters) {
  if (meters < 1000) return '${meters.round()} m';
  final km = (meters / 1000).toStringAsFixed(1).replaceAll('.', ',');
  return '$km km';
}

/// Cân nặng kiểu Việt Nam, dấu phẩy thập phân: "4,5 kg", "5 kg".
String formatWeight(double kg) {
  final text = kg == kg.truncateToDouble()
      ? kg.toStringAsFixed(0)
      : kg.toStringAsFixed(1);
  return '${text.replaceAll('.', ',')} kg';
}

/// Tuổi tính đến [now], vd "2 tuổi 3 tháng" hoặc "5 tháng".
String formatAge(DateTime birthDate, DateTime now) {
  var months = (now.year - birthDate.year) * 12 + now.month - birthDate.month;
  if (now.day < birthDate.day) months--;
  if (months < 1) return 'Dưới 1 tháng';

  final years = months ~/ 12;
  final rest = months % 12;
  if (years == 0) return '$rest tháng';
  if (rest == 0) return '$years tuổi';
  return '$years tuổi $rest tháng';
}
