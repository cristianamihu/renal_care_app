import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:renal_care_app/features/home/data/repositories/restricted_food_repository_impl.dart';
import 'package:renal_care_app/features/home/data/services/restricted_food_remote_service.dart';
import 'package:renal_care_app/features/home/domain/usecases/get_restricted_foods.dart';
import 'package:renal_care_app/features/home/presentation/viewmodels/restricted_food_state.dart';
import 'package:renal_care_app/features/home/presentation/viewmodels/restricted_food_viewmodel.dart';

//Remote Service
final restrictedFoodRemoteServiceProvider = Provider(
  (_) => RestrictedFoodRemoteService(firestore: FirebaseFirestore.instance),
);

//Repository
final restrictedFoodRepoProvider = Provider(
  (ref) => RestrictedFoodRepositoryImpl(
    ref.read(restrictedFoodRemoteServiceProvider),
  ),
);

//Use Cases
final getRestrictedFoodsUseCaseProvider = Provider(
  (ref) => GetRestrictedFoods(ref.read(restrictedFoodRepoProvider)),
);

// Provider
final restrictedFoodViewModelProvider =
    StateNotifierProvider<RestrictedFoodViewModel, RestrictedFoodState>(
      (ref) => RestrictedFoodViewModel(
        ref,
        ref.watch(getRestrictedFoodsUseCaseProvider),
      ),
    );
