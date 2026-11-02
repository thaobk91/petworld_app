import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petworld_app/app/app_gate.dart';
import 'package:petworld_app/core/router/app_routes.dart';
import 'package:petworld_app/features/pets/presentation/screens/add_pet_screen.dart';
import 'package:petworld_app/features/pets/presentation/screens/pet_detail_screen.dart';

final appRouterProvider = Provider<GoRouter>(
  (ref) => GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const AppGate(),
      ),
      // Phải đứng trước '/pets/:id', nếu không 'add' sẽ bị hiểu là một id.
      GoRoute(
        path: AppRoutes.addPet,
        builder: (context, state) => const AddPetScreen(),
      ),
      GoRoute(
        path: AppRoutes.petDetailPattern,
        builder: (context, state) =>
            PetDetailScreen(petId: state.pathParameters['id']!),
      ),
    ],
  ),
);
