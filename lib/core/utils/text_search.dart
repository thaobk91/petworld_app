const _accents = {
  'a': 'àáạảãâầấậẩẫăằắặẳẵäåā',
  'e': 'èéẹẻẽêềếệểễëē',
  'i': 'ìíịỉĩîïī',
  'o': 'òóọỏõôồốộổỗơờớợởỡöøō',
  'u': 'ùúụủũưừứựửữûüū',
  'y': 'ỳýỵỷỹÿ',
  'd': 'đ',
  'c': 'ç',
  'n': 'ñ',
};

final _plainOf = {
  for (final MapEntry(key: plain, value: accented) in _accents.entries)
    for (final char in accented.split('')) char: plain,
};

/// Chữ thường, bỏ dấu, để tìm kiếm không phân biệt dấu: "Việt Nam" và
/// "viet nam" đều thành "viet nam".
String foldForSearch(String text) =>
    text.toLowerCase().split('').map((char) => _plainOf[char] ?? char).join();
