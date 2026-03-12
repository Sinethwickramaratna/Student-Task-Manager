import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/loading_page.dart';
import 'services/network_service.dart';
import 'core/app_theme.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  bool isFirstTime = prefs.getBool('isFirstTime')?? true;

  runApp(MyApp(isFirstTime: isFirstTime));
}

class MyApp extends StatefulWidget{
  final bool isFirstTime;
  const MyApp({super.key, required this.isFirstTime});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final NetworkService _networkService;

  @override
  void initState() {
    super.initState();
    _networkService = NetworkService();
    _networkService.addListener(_onNetworkChange);
  }

  @override
  void dispose() {
    _networkService.removeListener(_onNetworkChange);
    super.dispose();
  }

  void _onNetworkChange() {
    if (!_networkService.isConnected) {
      _showNetworkError();
    } else {
      _hideNetworkError();
    }
  }

  void _showNetworkError() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.wifi_off, color: Colors.white),
              SizedBox(width: 10),
              Text('No network connection'),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(days: 365), // Keep showing until network is back
        ),
      );
    }
  }

  void _hideNetworkError() {
    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    }
  }

  @override
  Widget build(BuildContext){
    return MaterialApp(
      title: 'Student Task Manager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: LoadingPage(isFirstTime: widget.isFirstTime),
    );
  }
}