import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens.dart';
import 'droniva_store.dart';
import '../app/brand.dart';

class ProductApp extends StatelessWidget {
  const ProductApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DronivaStore()..init(),
      child: MaterialApp(
        title: 'Droniva',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: cBg,
          appBarTheme: const AppBarTheme(backgroundColor: cSurface),
        ),
        home: const DronivaMainScreen(),
      ),
    );
  }
}
