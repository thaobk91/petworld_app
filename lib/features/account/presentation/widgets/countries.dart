import 'package:petworld_app/core/utils/text_search.dart';
import 'package:petworld_app/features/account/presentation/widgets/country_names_vi.dart';
import 'package:phone_numbers_parser/metadata.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';

/// Một quốc gia trong danh sách chọn mã vùng điện thoại.
class Country {
  Country(this.isoCode)
    : name = countryNamesVi[isoCode.name] ?? isoCode.name,
      dialCode = '+${metadataByIsoCode[isoCode]!.countryCode}';

  final IsoCode isoCode;

  /// Tên tiếng Việt, vd "Nhật Bản".
  final String name;

  /// Mã vùng có dấu cộng, vd "+81".
  final String dialCode;

  /// Cờ dạng emoji, ghép từ 2 ký tự "chỉ báo vùng" ứng với mã ISO.
  String get flag => String.fromCharCodes(
    isoCode.name.codeUnits.map((c) => 0x1F1E6 + c - 0x41),
  );

  /// Số di động mẫu của nước này, vd "912 345 678" với Việt Nam.
  String get exampleMobile {
    final example = metadataExamplesByIsoCode[isoCode]?.mobile ?? '';
    if (example.isEmpty) return '';
    return PhoneNumber(isoCode: isoCode, nsn: example).formatNsn();
  }

  /// Khớp khi [query] nằm trong tên (không phân biệt dấu), trùng mã ISO, hoặc
  /// là phần đầu của mã vùng.
  bool matches(String query) {
    final folded = foldForSearch(query.trim());
    if (folded.isEmpty) return true;
    if (RegExp(r'^\+?\d+$').hasMatch(folded)) {
      return dialCode.startsWith(folded.startsWith('+') ? folded : '+$folded');
    }
    return foldForSearch(name).contains(folded) ||
        isoCode.name.toLowerCase() == folded;
  }
}

/// Mọi quốc gia, xếp theo tên tiếng Việt.
final List<Country> allCountries = IsoCode.values.map(Country.new).toList()
  ..sort((a, b) => foldForSearch(a.name).compareTo(foldForSearch(b.name)));
