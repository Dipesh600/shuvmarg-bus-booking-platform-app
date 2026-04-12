import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sumarg/controllers/auth_controller/login_provider.dart';
import 'package:sumarg/controllers/seatas_controller/seats_provider.dart';
import 'package:sumarg/providers/profile_provider.dart';
import 'package:sumarg/providers/notification_provider.dart';
import 'package:sumarg/providers/app_state_provider.dart';
import 'package:sumarg/providers/ticket_provider.dart';
import 'package:sumarg/providers/coupon_provider.dart';
import 'package:sumarg/providers/feedback_provider.dart';
import 'package:sumarg/utils/color_constants.dart';
import 'package:sumarg/utils/push_notifiction.dart';
import 'package:sumarg/utils/global_context.dart';
import 'package:sumarg/views/home/splash_screen.dart';

Future<void> backgroundPushNotification(RemoteMessage message) async {
  try {} catch (e) {}
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(backgroundPushNotification);
    await FirebasePushnotificationService().setUpFirebaseNotification();
  } catch (e) {
    print("Firebase initialization skipped (missing config file for this platform). App will proceed without push notifications locally.");
  }

  final loginProvider = LoginProvider();
  await loginProvider.loadLoginStatus();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AppStateProvider>(
          create: (_) => AppStateProvider(),
        ),
        ChangeNotifierProvider<LoginProvider>.value(
          value: loginProvider,
        ),
        ChangeNotifierProvider<ProfileProvider>(
          create: (_) => ProfileProvider(),
        ),
        ChangeNotifierProvider<NotificationProvider>(
          create: (_) => NotificationProvider(),
        ),
        ChangeNotifierProvider<SeatSelectionProvider>(
          create: (_) => SeatSelectionProvider(pricePerSeat: 0),
        ),
        ChangeNotifierProvider<TicketProvider>(
          create: (_) => TicketProvider(),
        ),
        ChangeNotifierProvider<CouponProvider>(
          create: (_) => CouponProvider(),
        ),
        ChangeNotifierProvider<FeedbackProvider>(
          create: (_) => FeedbackProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sumarg',
      navigatorKey: GlobalContext.navigatorKey,
      theme: ThemeData(
        primarySwatch: customWhite,
        fontFamily: 'Geometria',
      ),
      home: const AppInitializer(),
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  @override
  void initState() {
    super.initState();
    // Defer initialization to after first frame to avoid notifyListeners during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    // Initialize app state provider
    final appStateProvider =
        Provider.of<AppStateProvider>(context, listen: false);
    await appStateProvider.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        if (appState.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return const SplashScreen();
      },
    );
  }
}
