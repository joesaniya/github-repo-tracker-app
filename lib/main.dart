import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:repo_tracker_app/data/Business%20Logic/provider-common.dart';
import 'package:repo_tracker_app/data/Presentation/ui/search-screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: ProviderHelperClass.instance.providerLists,
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.teal,
        ),
        home: const SearchScreen(),
      ),
    );
  }
}
