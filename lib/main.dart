import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:pocketnotes/Services/auth/bloc/auth_bloc.dart';
import 'package:pocketnotes/Services/auth/firebase_provider.dart';
import 'package:pocketnotes/views/Constants/app_theme.dart';
import 'package:pocketnotes/views/Constants/routes.dart';
import 'package:pocketnotes/views/Notes/create_update_note_view.dart';
import 'package:pocketnotes/views/Settings/date_format_page.dart';
import 'package:pocketnotes/views/Settings/filter_page.dart';
import 'package:pocketnotes/views/controller_view.dart';
import 'package:pocketnotes/views/forgot_password.dart';
import 'package:pocketnotes/views/Settings/settings.dart';
import 'package:provider/provider.dart';

void main() async {
  await Settings.init(cacheProvider: SharePreferenceCache());
  WidgetsFlutterBinding.ensureInitialized;
  await AppTheme.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(create: (context) {
      return AppTheme();
    }, builder: (context, _) {
      ThemeData theme = Provider.of<AppTheme>(context).getDarkTheme();
      return MaterialApp(
        title: 'Pocket Notes',
        debugShowCheckedModeBanner: false,
        theme: theme,
        home: BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(FireBaseProvider()),
          child: const ControllerView(),
        ),
        routes: {
          createOrUpdateNoteRoute: (context) => const CreateUpdateView(),
          forgotPasswordRoute: (context) => const ForgotPasswordView(),
          settingsRoute: (context) => const SettingsView(),
          filterSettingsRoute: (context) => const FilterPageView(),
          dateFormatSettingsRoute: (context) => const DateFormatView(),
        },
      );
    });
  }
}
