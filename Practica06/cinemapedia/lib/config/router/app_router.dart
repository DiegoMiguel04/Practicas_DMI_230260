import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:cinemapedia/presentation/screens/screens.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [

    GoRoute(
      path: '/splash',
      name: SplashScreen.name,
      builder: (context, state) => const SplashScreen(),
    ),
    
    GoRoute(
      path: '/home/:page',
      name: HomeScreen.name,
      // Transición con fade para que la salida de la pantalla de carga sea suave
      pageBuilder: (context, state) {
        final pageIndex = int.parse( state.pathParameters['page'] ?? '0' );

        return CustomTransitionPage(
          key: state.pageKey,
          child: HomeScreen( pageIndex: pageIndex ),
          transitionDuration: const Duration(milliseconds: 400),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
        );
      },
      routes: [
         GoRoute(
          path: 'movie/:id',
          name: MovieScreen.name,
          pageBuilder: (context, state) {
            final movieId = state.pathParameters['id'] ?? 'no-id';
            return CustomTransitionPage(
              key: state.pageKey,
              child: MovieScreen(movieId: movieId),
              transitionDuration: const Duration(milliseconds: 420),
              reverseTransitionDuration: const Duration(milliseconds: 320),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
                return FadeTransition(
                  opacity: curved,
                  child: SlideTransition(
                    position: Tween<Offset>(begin: const Offset(0, .035), end: Offset.zero).animate(curved),
                    child: child,
                  ),
                );
              },
            );
          },
        ),
      ]
    ),



    GoRoute(
      path: '/',
      redirect: (context, _) => '/home/0',
    ),

  ]
);
