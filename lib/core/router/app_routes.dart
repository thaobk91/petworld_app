abstract final class AppRoutes {
  static const home = '/';
  static const addPet = '/pets/add';
  static const petDetailPattern = '/pets/:id';

  static String petDetail(String id) => '/pets/$id';
}
