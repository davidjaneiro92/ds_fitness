import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'src/core/abstracts/error_reporter_interface.dart';
import 'src/core/abstracts/format_service_interface.dart';
import 'src/core/abstracts/http_manager_interface.dart';
import 'src/core/abstracts/log_service_interface.dart';
import 'src/core/abstracts/storage_service_interface.dart';
import 'src/core/features/auth/abstracts/auth_controller_interface.dart';
import 'src/core/features/auth/abstracts/auth_repository_interface.dart';
import 'src/core/features/auth/controller/auth_controller.dart';
import 'src/core/features/auth/repository/auth_repository.dart';
import 'src/core/services/error_reporter.dart';
import 'src/core/services/format_service.dart';
import 'src/core/services/http_manager.dart';
import 'src/core/services/log_service.dart';
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
  Get.put<StorageServiceInterface>(StorageService(box), permanent: true);
  final ErrorReporterInterface reporter = ErrorReporter(storage: Get.find());
  Get.put<ErrorReporterInterface>(reporter, permanent: true);
  Get.put<LogServiceInterface>(
    LogService(reporter: reporter),
    permanent: true,
  );
  _capturarErrosGlobais(Get.find<LogServiceInterface>());
  unawaited(reporter.reenviarPendentes());
  Get.put<FormatServiceInterface>(FormatService(), permanent: true);
  Get.put<HttpManagerInterface>(
    HttpManager(storage: Get.find(), log: Get.find()),
    permanent: true,
  );

  // Autenticacao e permanente (specs/06 — tabela de controllers).
  Get.put<AuthRepositoryInterface>(AuthRepository(), permanent: true);
  Get.put<AuthControllerInterface>(AuthController(), permanent: true);

  runApp(const DsFitnessApp());
}

/// Manda para o log os erros que nenhum `catch` pegou: os do framework
/// (build, layout, gestos) e os de codigo assincrono sem tratamento.
void _capturarErrosGlobais(LogServiceInterface log) {
  final FlutterExceptionHandler? anterior = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails detalhes) {
    anterior?.call(detalhes);
    log.error(
      'Erro do Flutter: ${detalhes.exceptionAsString()}',
      error: detalhes.exception,
      stackTrace: detalhes.stack,
    );
  };
  PlatformDispatcher.instance.onError = (Object erro, StackTrace pilha) {
    log.error('Erro nao tratado', error: erro, stackTrace: pilha);
    return true;
  };
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
