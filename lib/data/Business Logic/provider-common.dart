import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:repo_tracker_app/data/Business%20Logic/issue-provider.dart';
import 'package:repo_tracker_app/data/Business%20Logic/search-provider.dart';

class ProviderHelperClass {
  static ProviderHelperClass? _instance;

  static ProviderHelperClass get instance {
    _instance ??= ProviderHelperClass();
    return _instance!;
  }

  List<SingleChildWidget> providerLists = [
   ChangeNotifierProvider(create: (context) => SearchProvider()),
    ChangeNotifierProvider(create: (context) => IssueProvider()),
  ];
}
