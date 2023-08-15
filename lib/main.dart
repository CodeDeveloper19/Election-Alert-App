import 'package:election_alert_app/Pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:election_alert_app/Pages/onboarding.dart';
import 'package:election_alert_app/Pages/login.dart';
import 'package:election_alert_app/Pages/signup.dart';
import 'package:election_alert_app/Pages/forgotpassword.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:election_alert_app/Pages/auth_page.dart';
import 'package:go_router/go_router.dart';
import 'package:election_alert_app/Pages/profile.dart';
import 'package:election_alert_app/Pages/Notifications/notifications_onboarding.dart';
import 'package:election_alert_app/Pages/Notifications/settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GoRouter _router = GoRouter(
    initialLocation: '/auth',
    routes: <RouteBase>[
      GoRoute(
        path: '/auth',
        builder: (BuildContext context, GoRouterState state) {
          return const AuthPage();
        },
        routes: <RouteBase>[
          GoRoute(
            path: 'onboarding',
            builder: (BuildContext context, GoRouterState state) {
              return const OnBoarding();
            },
          ),
          GoRoute(
            path: 'login',
            builder: (BuildContext context, GoRouterState state) {
              return const Login();
            },
            routes: <RouteBase>[
              GoRoute(
                path: 'forgot',
                builder: (BuildContext context, GoRouterState state) {
                  return const Forgot();
                },
              ),
            ],
          ),
          GoRoute(
            path: 'signup',
            builder: (BuildContext context, GoRouterState state) {
              return const SignUp();
            },
          ),
          GoRoute(
              path: 'homepage',
              builder: (BuildContext context, GoRouterState state) {
                return const Homepage();
              },
              routes: <RouteBase>[
                GoRoute(
                  path: 'profile',
                  builder: (BuildContext context, GoRouterState state) {
                    return const ProfileSettings();
                  },
                ),
                GoRoute(
                    path: 'notifications_onboarding',
                    builder: (BuildContext context, GoRouterState state) {
                      return const NotificationsOnboarding();
                    },
                    routes: <RouteBase>[
                      GoRoute(
                        path: 'settings',
                        builder: (BuildContext context, GoRouterState state) {
                          return const NotificationSettings();
                        },
                      ),
                    ]
                ),
              ]
          ),
        ],
      ),
      // GoRoute(
      //   path: '/homepage',
      //   builder: (BuildContext context, GoRouterState state) {
      //     return const Homepage();
      //   },
      //   routes: <RouteBase>[
      //     GoRoute(
      //      path: 'profile',
      //      builder: (BuildContext context, GoRouterState state) {
      //        return const ProfileSettings();
      //      },
      //    ),
      //     GoRoute(
      //       path: 'notifications_onboarding',
      //       builder: (BuildContext context, GoRouterState state) {
      //         return const NotificationsOnboarding();
      //       },
      //        routes: <RouteBase>[
      //          GoRoute(
      //            path: 'settings',
      //            builder: (BuildContext context, GoRouterState state) {
      //              return const NotificationSettings();
      //            },
      //          ),
      //        ]
      //     ),
      //   ]
      // ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    // whenever your initialization is completed, remove the splash screen:
    return MaterialApp.router(
      // initialRoute: '/',
      debugShowCheckedModeBanner: false,
      // routes: {
      //   '/homepage': (context) => const Homepage(),
      //   '/onboarding': (context) => const OnBoarding(),
      //   '/onboarding/login': (context) => const Login(),
      //   '/signup': (context) => const SignUp(),
      //   '/forgot': (context) => const Forgot(),
      // },
      routerConfig: _router,
      // body: StreamBuilder<User?>(
      //   stream: FirebaseAuth.instance.authStateChanges(),
      //   builder: (context, snapshot) {
      //     print('working');
      //     if (snapshot.hasData){
      //       print("A");
      //       return Homepage();
      //     } else {
      //       print("B");
      //       return OnBoarding();
      //     }
      //   },
      // ),
    );
    //   MaterialApp(
    //   // initialRoute: '/auth',
    //   debugShowCheckedModeBanner: false,
    //   // routes: {
    //   //   '/': (context) => const OnBoarding(),
    //   //   '/homepage': (context) => const Homepage(),
    //   //   '/login': (context) => const Login(),
    //   //   '/signup': (context) => const SignUp(),
    //   //   '/forgot': (context) => const Forgot(),
    //   //   '/auth': (context) => const AuthPage()
    //   // },
    // );
  }
}
