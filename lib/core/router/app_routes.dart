abstract final class AppRoutes {
  static const home = '/';
  static const addPet = '/pets/add';
  static const petDetailPattern = '/pets/:id';
  static const createGroup = '/community/groups/new';
  static const groupDetailPattern = '/community/groups/:id';

  static String petDetail(String id) => '/pets/$id';

  static String groupDetail(String id) => '/community/groups/$id';
}
