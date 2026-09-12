import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:planedriver_flame/l10n/app_localizations.dart';
import 'package:planedriver_flame/screens/menu_screen.dart';
import 'package:planedriver_flame/utils/theme.dart';

class PlaneDriverApp extends StatelessWidget {
  const PlaneDriverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plane Driver',
      debugShowCheckedModeBanner: false,
      theme: PlaneDriverTheme.data(),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('tr'),
        Locale('de'),
        Locale('fr'),
        Locale('es'),
        Locale('pt'),
        Locale('ru'),
        Locale('ja'),
        Locale('ko'),
        Locale('zh'),
      ],
      home: const MenuScreen(),
    );
  }
}
