import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'src/core/abstracts/format_service_interface.dart';
import 'src/core/abstracts/log_service_interface.dart';
import 'src/core/abstracts/mock_database_interface.dart';
import 'src/core/abstracts/storage_service_interface.dart';
import 'src/core/features/auth/abstracts/auth_controller_interface.dart';
import 'src/core/features/auth/abstracts/auth_repository_interface.dart';
import 'src/core/features/auth/controller/auth_controller.dart';
import 'src/core/features/auth/repository/auth_repository.dart';
import 'src/core/services/format_service.dart';
import 'src/core/services/log_service.dart';
import 'src/core/services/mock_database.dart';
import 'src/core/services/storage_service.dart';
import 'src/core/theme/app_theme.dart';
import 'src/enum/pages_routes.dart';
import 'src/routes/app_pages.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR');

  // Persistencia local.
  await Hive.initFlutter();
  final Box<dynamic> box = await Hive.openBox<dynamic>(StorageService.boxName);

  // Servicos transversais — unicos registros eager do app.
  Get.put<LogServiceInterface>(LogService(), permanent: true);
  Get.put<StorageServiceInterface>(StorageService(box), permanent: true);
  Get.put<FormatServiceInterface>(FormatService(), permanent: true);
  Get.put<MockDatabaseInterface>(MockDatabase(), permanent: true);

  // Autenticacao e permanente (specs/06 — tabela de controllers).
  Get.put<AuthRepositoryInterface>(AuthRepository(), permanent: true);
  Get.put<AuthControllerInterface>(AuthController(), permanent: true);

  runApp(const DsFitnessApp());
}

class DsFitnessApp extends StatelessWidget {
  const DsFitnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'DS Fitness',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      initialRoute: PagesRoutes.splash.path,
      getPages: AppPages.pages,
      defaultTransition: Transition.cupertino,
      builder: (BuildContext context, Widget? child) {
        // Limita o fator de escala de texto para preservar o layout.
        final MediaQueryData media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            textScaler: TextScaler.linear(
              media.textScaler.scale(1).clamp(0.85, 1.15),
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
