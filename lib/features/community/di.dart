import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petworld_app/core/storage/shared_preferences_provider.dart';
import 'package:petworld_app/features/community/data/datasources/community_local_datasource.dart';
import 'package:petworld_app/features/community/data/repositories/community_repository_impl.dart';
import 'package:petworld_app/features/community/domain/repositories/community_repository.dart';
import 'package:petworld_app/features/community/domain/usecases/add_group_post.dart';
import 'package:petworld_app/features/community/domain/usecases/create_group.dart';
import 'package:petworld_app/features/community/domain/usecases/delete_group_post.dart';

// Chỗ duy nhất nối interface của domain với implementation của data.
// Presentation chỉ dùng các provider ở đây, không import thẳng lớp data.

final communityLocalDataSourceProvider = Provider<CommunityLocalDataSource>(
  (ref) => CommunityLocalDataSource(ref.watch(sharedPreferencesProvider)),
);

final communityRepositoryProvider = Provider<CommunityRepository>(
  (ref) => CommunityRepositoryImpl(ref.watch(communityLocalDataSourceProvider)),
);

final createGroupProvider = Provider<CreateGroup>(
  (ref) => CreateGroup(ref.watch(communityRepositoryProvider)),
);

final addGroupPostProvider = Provider<AddGroupPost>(
  (ref) => AddGroupPost(ref.watch(communityRepositoryProvider)),
);

final deleteGroupPostProvider = Provider<DeleteGroupPost>(
  (ref) => DeleteGroupPost(ref.watch(communityRepositoryProvider)),
);
