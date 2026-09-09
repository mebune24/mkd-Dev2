import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/auth_provider.dart';
import '../../providers/di_providers.dart';
import '../../services/session_storage_service.dart';

const currentTermsVersion = '2026-09-09';
const _localTermsKey = 'spacerentals_terms_accepted_version';

class TermsScreen extends ConsumerStatefulWidget {
  const TermsScreen({super.key});
  @override
  ConsumerState<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends ConsumerState<TermsScreen> {
  bool _accepted = false;
  bool _saving = false;

  Future<void> _continue() async {
    if (!_accepted || _saving) return;
    setState(() => _saving = true);
    try {
      final session = ref.read(authProvider).session;
      if (session != null) {
        await ref.read(authRepositoryProvider).acceptTerms(currentTermsVersion);
        ref.read(authProvider.notifier).markTermsAccepted();
      } else {
        ref.read(authProvider.notifier).markTermsAcceptedLocally();
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localTermsKey, currentTermsVersion);
      await SessionStorageService.instance.saveTermsAcceptance(
        currentTermsVersion,
      );
      if (mounted) context.go(session == null ? '/login' : '/splash');
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Terms and Conditions')),
    body: SafeArea(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              children: const [
                Text(
                  'SpaceRentals Terms and Conditions',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Effective version: 2026-09-09',
                  style: TextStyle(color: Colors.grey),
                ),
                _Heading('1. Using SpaceRentals'),
                _Copy(
                  'SpaceRentals connects tenants, landlords, agents, and administrators for property discovery, applications, leases, payments, maintenance, verification, and related services. Provide accurate information, use the platform lawfully, and respect other users.',
                ),
                _Heading('2. Business and OHADA context'),
                _Copy(
                  'SpaceRentals is a digital property-services platform and does not replace a lawyer, notary, accountant, regulator, landlord, tenant, or payment provider. Services and records are handled with applicable Cameroonian law, OHADA commercial principles, consumer obligations, tax rules, and required property or lease formalities. Users remain responsible for documents and agreements they sign.',
                ),
                _Heading('3. Data we collect'),
                _Copy(
                  'We collect account details, contact information, role, authentication records, property and rental information, KYC documents, payment references, messages, support requests, device and security logs, and actions needed to operate and protect the service.',
                ),
                _Heading('4. How data is used'),
                _Copy(
                  'Data is used to create accounts, verify identities, match users with properties, process applications and payments, manage leases and maintenance, prevent fraud, provide support and notifications, maintain audit trails, improve reliability, and meet legal obligations.',
                ),
                _Heading('5. Sharing and distribution'),
                _Copy(
                  'Data is shared only when needed for the requested service: relevant details with transaction counterparties, verification data with authorized reviewers, payment details with payment providers, and records with service providers or authorities when legally required. We do not sell personal information.',
                ),
                _Heading('6. Security and passwords'),
                _Copy(
                  'Passwords are stored as secure cryptographic hashes and are not readable by SpaceRentals staff. SpaceRentals does not have access to your password. Sensitive documents are protected in storage and access is role-restricted. Protect your device and credentials and report suspected compromise.',
                ),
                _Heading('7. Privacy and history'),
                _Copy(
                  'Account activity and transaction history support service delivery, security, dispute handling, and required records. Authorized administrators may review operational records when necessary; access is controlled and logged. We respect privacy and retain data only for legitimate operational, legal, security, and accounting needs.',
                ),
                _Heading('8. Prohibited conduct'),
                _Copy(
                  'Do not submit false documents, impersonate another person, evade verification, misuse payments, harass users, scrape the service, or attempt unauthorized access. SpaceRentals may suspend access, preserve evidence, or report unlawful activity.',
                ),
                _Heading('9. Acceptance and changes'),
                _Copy(
                  'Acceptance is recorded with the current terms version and time. Material updates may require renewed acceptance before continued use.',
                ),
                _Heading('10. Contact and disputes'),
                _Copy(
                  'Use the support channels shown in the application for questions, privacy requests, or complaints. This does not remove rights that cannot legally be waived.',
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              children: [
                CheckboxListTile(
                  value: _accepted,
                  onChanged: (value) =>
                      setState(() => _accepted = value ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                  title: const Text(
                    'I have read and agree to the current Terms and Conditions and Privacy information.',
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _accepted && !_saving ? _continue : null,
                    child: _saving
                        ? const CircularProgressIndicator()
                        : const Text('Continue to sign in'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _Heading extends StatelessWidget {
  final String text;
  const _Heading(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 6),
    child: Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
  );
}

class _Copy extends StatelessWidget {
  final String text;
  const _Copy(this.text);
  @override
  Widget build(BuildContext context) =>
      Text(text, style: const TextStyle(height: 1.45));
}
