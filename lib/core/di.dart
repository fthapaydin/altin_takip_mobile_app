import 'package:get_it/get_it.dart';
import 'package:altin_takip/core/network/dio_client.dart';
import 'package:altin_takip/core/network/public_dio_client.dart';
import 'package:altin_takip/core/storage/storage_service.dart';
import 'package:altin_takip/features/auth/domain/auth_repository.dart';
import 'package:altin_takip/features/auth/data/auth_repository_impl.dart';
import 'package:altin_takip/features/assets/domain/asset_repository.dart';
import 'package:altin_takip/features/assets/data/asset_repository_impl.dart';
import 'package:altin_takip/features/currencies/domain/currency_repository.dart';
import 'package:altin_takip/features/currencies/data/currency_repository_impl.dart';
import 'package:altin_takip/features/dashboard/domain/dashboard_repository.dart';
import 'package:altin_takip/features/dashboard/data/dashboard_repository_impl.dart';
import 'package:altin_takip/features/chat/domain/chat_repository.dart';
import 'package:altin_takip/features/chat/data/chat_repository_impl.dart';
import 'package:altin_takip/features/notifications/domain/notifications_repository.dart';
import 'package:altin_takip/features/notifications/data/notifications_repository_impl.dart';
import 'package:altin_takip/features/public_prices/domain/public_prices_repository.dart';
import 'package:altin_takip/features/public_prices/data/public_prices_repository_impl.dart';
import 'package:altin_takip/features/auth/data/google_sign_in_service.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // Services
  sl.registerLazySingleton<StorageService>(() => StorageService());
  sl.registerLazySingleton<GoogleSignInService>(() => GoogleSignInService());

  // Network
  sl.registerLazySingleton<DioClient>(() => DioClient(sl()));
  sl.registerLazySingleton<PublicDioClient>(() => PublicDioClient());

  // Repositories
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  sl.registerLazySingleton<AssetRepository>(() => AssetRepositoryImpl(sl()));
  sl.registerLazySingleton<CurrencyRepository>(
    () => CurrencyRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<ChatRepository>(() => ChatRepositoryImpl(sl()));
  sl.registerLazySingleton<NotificationsRepository>(
    () => NotificationsRepositoryImpl(sl<DioClient>().dio),
  );
  sl.registerLazySingleton<PublicPricesRepository>(
    () => PublicPricesRepositoryImpl(sl()),
  );
}
