import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../shared/models/enums.dart';
import 'package:go_router/go_router.dart';
import '../features/splash/splash_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/auth/forgot_password_screen.dart';
import '../features/tenant/tenant_dashboard.dart';
import '../features/tenant/property_details.dart';
import '../features/tenant/rental_application.dart';
import '../features/tenant/rental_agreement_screen.dart';
import '../features/tenant/payments_screen.dart';
import '../features/tenant/rnlp_screen.dart';
import '../features/tenant/maintenance_screen.dart';
import '../features/tenant/property_search.dart';
import '../features/tenant/category_properties_screen.dart';
import '../features/tenant/monetization/tenant_monetization_screen.dart';
import '../features/tenant/monetization/tenant_gigs_screen.dart';
import '../features/tenant/messages_screen.dart';
import '../features/landlord/landlord_dashboard.dart';
import '../features/landlord/add_property.dart';
import '../features/landlord/kyc_screen.dart';
import '../features/landlord/kyc_pending_screen.dart';
import '../features/landlord/monetization/landlord_monetization_screen.dart';
import '../features/landlord/monetization/post_gig_form.dart';
import '../features/landlord/agent_marketplace_screen.dart';
import '../features/admin/admin_dashboard.dart';
import '../features/admin/admin_landlords_screen.dart';
import '../features/admin/admin_tenants_screen.dart';
import '../features/admin/users_screen.dart';
import '../features/admin/kyc_management_screen.dart';
import '../features/admin/admin_agents_screen.dart';
import '../features/notifications/notifications_screen.dart';
import '../features/agent/agent_onboarding_screen.dart';
import '../features/agent/agent_dashboard.dart';
import '../features/agent/agent_kyc_screen.dart';
import '../features/agent/agent_kyc_pending_screen.dart';
import '../features/chatbot/chatbot_screen.dart';
import '../features/properties/domain/property.dart';

// ── Reusable transition builders ──────────────────────────────────────────────

/// Slide up from bottom — used for full-screen detail pages & modals
CustomTransitionPage<void> _slideUp(BuildContext context, GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 380),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
        child: FadeTransition(opacity: animation, child: child),
      );
    },
  );
}

/// Slide in from right — standard horizontal navigation push
CustomTransitionPage<void> _slideRight(BuildContext context, GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 320),
    reverseTransitionDuration: const Duration(milliseconds: 260),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.12, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
        child: FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: const Interval(0.0, 0.7, curve: Curves.easeOut)),
          ),
          child: child,
        ),
      );
    },
  );
}

/// Fade transition — used for dashboard swaps (login → home)
CustomTransitionPage<void> _fade(BuildContext context, GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 420),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
        child: child,
      );
    },
  );
}

// ── Router ────────────────────────────────────────────────────────────────────

class AppRouter {
  // Empty class for namespace
}

final goRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      
      if (authState.isLoading) return null; // wait

      final hasAccess = authState.hasAccess;   // true for guests AND signed-in users
      final isGuest = authState.isGuest;

      final isGoingToSplash = state.matchedLocation == '/splash';
      final isGoingToLogin = state.matchedLocation == '/login';
      final isGoingToRegister = state.matchedLocation == '/register';
      final isGoingToForgot = state.matchedLocation == '/forgot-password';

      final isAuthRoute = isGoingToLogin || isGoingToRegister || isGoingToForgot;

      // Not signed in and not a guest → force to login
      if (!hasAccess) {
        if (!isAuthRoute && !isGoingToSplash) return '/login';
        return null;
      }

      // Guest: allow splash/auth routes to pass through to /tenant
      if (isGuest) {
        if (isAuthRoute || isGoingToSplash) return '/tenant';
        // Guests can browse /tenant, /chatbot, and /agent/onboarding
        final loc = state.matchedLocation;
        if (loc.startsWith('/tenant')) return null;
        if (loc == '/chatbot') return null;
        if (loc == '/agent/onboarding') return null;
        if (loc == '/notifications') return null;
        return '/tenant';
      }

      // Signed-in user: redirect away from auth/splash screens to their dashboard
      final session = authState.session!;
      if (isAuthRoute || isGoingToSplash) {
        switch (session.role) {
          case Role.tenant: return '/tenant';
          case Role.landlord: return '/landlord';
          case Role.admin: return '/admin';
          case Role.agent:
            // Route agents based on their KYC status
            if (session.isKycVerified) return '/agent/dashboard';
            return '/agent/pending'; // they've applied and are waiting
        }
      }

      // Agent routing: pending agents can browse /tenant, /chatbot while waiting
      if (session.role == Role.agent && !session.isKycVerified) {
        final loc = state.matchedLocation;
        if (loc.startsWith('/agent/pending')) return null;
        if (loc.startsWith('/agent/kyc')) return null;
        if (loc.startsWith('/tenant')) return null;
        if (loc == '/chatbot') return null;
        if (loc == '/notifications') return null;
        return '/agent/pending'; // block everything else
      }

      // Role enforcement: prevent cross-role navigation
      final loc = state.matchedLocation;
      if (loc.startsWith('/tenant') && session.role != Role.tenant) {
        if (session.role == Role.landlord) return '/landlord';
        if (session.role == Role.admin) return '/admin';
        if (session.role == Role.agent && session.isKycVerified) return '/agent/dashboard';
      }
      if (loc.startsWith('/landlord') && session.role != Role.landlord) {
        if (session.role == Role.tenant) return '/tenant';
        if (session.role == Role.admin) return '/admin';
      }
      if (loc.startsWith('/admin') && session.role != Role.admin) {
        if (session.role == Role.tenant) return '/tenant';
        if (session.role == Role.landlord) return '/landlord';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) => _fade(context, state, const SplashScreen()),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => _fade(context, state, const LoginScreen()),
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (context, state) => _slideRight(context, state, const RegisterScreen()),
      ),
      GoRoute(
        path: '/forgot-password',
        pageBuilder: (context, state) => _slideRight(context, state, const ForgotPasswordScreen()),
      ),

      // ── Tenant ──────────────────────────────────────────────────────────────
      GoRoute(
        path: '/tenant',
        pageBuilder: (context, state) => _fade(context, state, const TenantDashboard()),
        routes: [
          GoRoute(
            path: 'property/:id',
            pageBuilder: (context, state) {
              final property = state.extra as PropertyWithListing?;
              if (property == null) return _fade(context, state, const TenantDashboard());
              return _slideUp(context, state, PropertyDetails(property: property));
            },
          ),
          GoRoute(
            path: 'apply',
            pageBuilder: (context, state) {
              final property = state.extra as PropertyWithListing?;
              if (property == null) return _fade(context, state, const TenantDashboard());
              return _slideUp(context, state, RentalApplication(property: property));
            },
          ),
          GoRoute(
            path: 'agreement',
            pageBuilder: (context, state) {
              final tenantId = state.extra as String? ?? 'guest';
              return _slideRight(context, state, RentalAgreementScreen(tenantId: tenantId));
            },
          ),
          GoRoute(
            path: 'payments',
            pageBuilder: (context, state) {
              final tenantId = state.extra as String? ?? 'guest';
              return _slideRight(context, state, PaymentsScreen(tenantId: tenantId));
            },
          ),
          GoRoute(
            path: 'rnlp',
            pageBuilder: (context, state) {
              final tenantId = state.extra as String? ?? 'guest';
              return _slideRight(context, state, RnlpScreen(tenantId: tenantId));
            },
          ),
          GoRoute(
            path: 'maintenance',
            pageBuilder: (context, state) {
              final tenantId = state.extra as String? ?? 'guest';
              return _slideRight(context, state, MaintenanceScreen(tenantId: tenantId));
            },
          ),
          GoRoute(
            path: 'monetization',
            pageBuilder: (context, state) => _slideRight(context, state, const TenantMonetizationScreen()),
          ),
          GoRoute(
            path: 'gigs',
            pageBuilder: (context, state) => _slideRight(context, state, const TenantGigsScreen()),
          ),
          GoRoute(
            path: 'chat/:id',
            pageBuilder: (context, state) {
              final chatData = state.extra as Map<String, dynamic>? ??
                  {'id': state.pathParameters['id'], 'name': 'Chat', 'property': '', 'unread': 0};
              return _slideRight(context, state, ChatDetailScreen(chatData: chatData));
            },
          ),
          GoRoute(
            path: 'search',
            pageBuilder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              final showMap = extra?['showMap'] as bool? ?? false;
              return _slideRight(context, state, PropertySearch(showMap: showMap));
            },
          ),
          GoRoute(
            path: 'category/:name',
            pageBuilder: (context, state) {
              final categoryName = state.pathParameters['name'] ?? 'Category';
              final extra = state.extra as List<String>?;
              return _slideRight(context, state, CategoryPropertiesScreen(categoryName: categoryName, propertyIds: extra));
            },
          ),
        ],
      ),

      // ── Landlord ─────────────────────────────────────────────────────────────
      GoRoute(
        path: '/landlord/kyc',
        pageBuilder: (context, state) => _fade(context, state, const LandlordKYCScreen()),
      ),
      GoRoute(
        path: '/landlord/pending',
        pageBuilder: (context, state) => _fade(context, state, const LandlordPendingScreen()),
      ),
      GoRoute(
        path: '/landlord',
        pageBuilder: (context, state) => _fade(context, state, const LandlordDashboard()),
        routes: [
          GoRoute(
            path: 'add-property',
            pageBuilder: (context, state) => _slideUp(context, state, const AddProperty()),
          ),
          GoRoute(
            path: 'monetization',
            pageBuilder: (context, state) => _slideRight(context, state, const LandlordMonetizationScreen()),
          ),
          GoRoute(
            path: 'post-gig',
            pageBuilder: (context, state) => _slideUp(context, state, const PostPropertyGigForm()),
          ),
          GoRoute(
            path: 'agents/marketplace',
            pageBuilder: (context, state) => _slideRight(context, state, const AgentMarketplaceScreen()),
          ),
        ],
      ),

      // ── Admin ────────────────────────────────────────────────────────────────
      GoRoute(
        path: '/admin',
        pageBuilder: (context, state) => _fade(context, state, const AdminDashboard()),
        routes: [
          GoRoute(
            path: 'landlords',
            pageBuilder: (context, state) => _slideRight(context, state, const AdminLandlordsScreen()),
          ),
          GoRoute(
            path: 'tenants',
            pageBuilder: (context, state) => _slideRight(context, state, const AdminTenantsScreen()),
          ),
          GoRoute(
            path: 'agents',
            pageBuilder: (context, state) => _slideRight(context, state, const AdminAgentsScreen()),
          ),
          GoRoute(
            path: 'users',
            pageBuilder: (context, state) => _slideRight(context, state, const UsersScreen()),
          ),
          GoRoute(
            path: 'kyc',
            pageBuilder: (context, state) => _slideRight(context, state, const AdminKYCManagementScreen()),
          ),
        ],
      ),

      // ── Agent ────────────────────────────────────────────────────────────────
      GoRoute(
        path: '/agent/onboarding',
        pageBuilder: (context, state) => _slideUp(context, state, const AgentOnboardingScreen()),
      ),
      GoRoute(
        path: '/agent/kyc',
        pageBuilder: (context, state) => _fade(context, state, const AgentKYCScreen()),
      ),
      GoRoute(
        path: '/agent/pending',
        pageBuilder: (context, state) => _fade(context, state, const AgentKycPendingScreen()),
      ),
      GoRoute(
        path: '/agent/dashboard',
        pageBuilder: (context, state) => _fade(context, state, const AgentDashboard()),
      ),

      // ── Shared ───────────────────────────────────────────────────────────────
      GoRoute(
        path: '/notifications',
        pageBuilder: (context, state) => _slideRight(context, state, const NotificationsScreen()),
      ),
      GoRoute(
        path: '/chatbot',
        pageBuilder: (context, state) => _slideUp(context, state, const ChatbotScreen()),
      ),
    ],
  );

  ref.listen(authProvider, (previous, next) {
    router.refresh();
  });

  return router;
});
