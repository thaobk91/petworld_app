import 'package:flutter/material.dart';
import 'package:petworld_app/features/pets/domain/entities/pet.dart';

extension PetSpeciesLabel on PetSpecies {
  String get label => switch (this) {
    PetSpecies.dog => 'Chó',
    PetSpecies.cat => 'Mèo',
    PetSpecies.bird => 'Chim',
    PetSpecies.rabbit => 'Thỏ',
    PetSpecies.hamster => 'Hamster',
    PetSpecies.fish => 'Cá',
    PetSpecies.other => 'Khác',
  };

  String get emoji => switch (this) {
    PetSpecies.dog => '🐶',
    PetSpecies.cat => '🐱',
    PetSpecies.bird => '🐦',
    PetSpecies.rabbit => '🐰',
    PetSpecies.hamster => '🐹',
    PetSpecies.fish => '🐟',
    PetSpecies.other => '🐾',
  };

  /// Màu pastel làm nền khi thú cưng chưa có ảnh.
  Color get color => switch (this) {
    PetSpecies.dog => const Color(0xFFFFE2C6),
    PetSpecies.cat => const Color(0xFFE7DEFF),
    PetSpecies.bird => const Color(0xFFD3F1FF),
    PetSpecies.rabbit => const Color(0xFFFFDDEA),
    PetSpecies.hamster => const Color(0xFFFFF0BF),
    PetSpecies.fish => const Color(0xFFCBEFE6),
    PetSpecies.other => const Color(0xFFEAE3D9),
  };
}

extension PetGenderLabel on PetGender {
  String get label => switch (this) {
    PetGender.male => 'Đực',
    PetGender.female => 'Cái',
    PetGender.unknown => 'Chưa rõ',
  };

  IconData get icon => switch (this) {
    PetGender.male => Icons.male,
    PetGender.female => Icons.female,
    PetGender.unknown => Icons.question_mark,
  };

  Color get color => switch (this) {
    PetGender.male => const Color(0xFF3D8BE0),
    PetGender.female => const Color(0xFFE0569A),
    PetGender.unknown => const Color(0xFF8A8580),
  };
}

extension PetSubtitle on Pet {
  /// "Mèo" hoặc "Mèo · Mèo mướp".
  String get speciesAndBreed => [species.label, ?breed].join(' · ');
}
