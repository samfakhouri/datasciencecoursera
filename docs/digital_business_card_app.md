# Digital Business Card App Design & Implementation Plan

## 1. High-level architecture overview
- **Pattern:** Layered clean-ish architecture with presentation (UI/widgets), application/state (Riverpod providers/controllers), domain (models, use cases), data (repositories + local storage), and services (QR, share, permissions).
- **State management:** **Riverpod** for testable, lightweight providers, easily scoped listening, and no global mutable state; great for async interactions (storage, camera permissions) and Compose-like patterns.
- **Storage:** **Hive** (NoSQL, type adapters) for fast local persistence, simple schema evolution, offline-first; fits card documents without heavy relational needs.
- **QR format:** Compact JSON encoded as string: `{ "type": "bizcard", "version": 1, "payload": { ...BusinessCard... } }` enabling backward compatibility and validation.
- **Navigation:** GoRouter (or Navigator 2.0) with bottom navigation shell for Home (My Cards), Scan, Search, Settings; onboarding shown once via stored flag in Hive box.
- **Theming:** Light & dark gradients, glassmorphism cards, hero/implicit animations; custom `AppTheme` with seeded color support per-card accent.

## 2. Data models
```dart
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
part 'business_card.g.dart';

@HiveType(typeId: 0)
class BusinessCard extends HiveObject {
  @HiveField(0)
  final String id; // uuid
  @HiveField(1)
  final String fullName;
  @HiveField(2)
  final String jobTitle;
  @HiveField(3)
  final String companyName;
  @HiveField(4)
  final String category; // e.g., IT, Marketing
  @HiveField(5)
  final String businessType; // e.g., Freelancer, Agency
  @HiveField(6)
  final String mobileNumber;
  @HiveField(7)
  final String? email;
  @HiveField(8)
  final String? websiteUrl;
  @HiveField(9)
  final String? address;
  @HiveField(10)
  final String? notes;
  @HiveField(11)
  final List<String> tags;
  @HiveField(12)
  final String? profileImagePath; // local file path
  @HiveField(13)
  final Color accentColor;
  @HiveField(14)
  final DateTime createdAt;
  @HiveField(15)
  final DateTime updatedAt;
  @HiveField(16)
  final bool favorite;
  @HiveField(17)
  final List<InteractionLog> logs;
}

@HiveType(typeId: 1)
class InteractionLog {
  @HiveField(0)
  final DateTime occurredAt;
  @HiveField(1)
  final String note;
}
```

## 3. `pubspec.yaml` dependencies (key)
- `flutter` SDK `>=3.19.0`
- State: `flutter_riverpod`
- Routing: `go_router`
- Storage: `hive`, `hive_flutter`, `path_provider`
- QR generate: `qr_flutter`
- QR scan: `mobile_scanner` (camera + QR detection)
- Forms/validation: `form_validator` or `intl_phone_field`
- Sharing: `share_plus`
- Images/pickers: `image_picker`
- Permissions: `permission_handler`
- JSON: `json_annotation`, `build_runner`, `json_serializable`
- UI polish: `smooth_page_indicator`, `animations`, `google_fonts`

## 4. Project structure
```
lib/
  main.dart
  app_router.dart
  theme/app_theme.dart
  models/
    business_card.dart
    interaction_log.dart
  data/
    business_card_repository.dart
    hive_adapters.dart
  services/
    qr_service.dart
    share_service.dart
    permission_service.dart
  providers/
    cards_provider.dart
    search_provider.dart
    scan_provider.dart
  ui/
    onboarding/
      onboarding_screen.dart
    home/
      home_shell.dart
      card_list_screen.dart
      card_detail_screen.dart
    edit/
      edit_card_screen.dart
    scan/
      scan_screen.dart
      scan_preview_screen.dart
    settings/
      settings_screen.dart
    widgets/
      card_tile.dart
      glass_container.dart
```

## 5. Key implementation code (representative excerpts)
### `main.dart`
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(BusinessCardAdapter());
  Hive.registerAdapter(InteractionLogAdapter());
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'Fancy Cards',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: router,
    );
  }
}
```

### Routing
```dart
final appRouterProvider = Provider((ref) => GoRouter(
  initialLocation: '/onboarding',
  routes: [
    GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
    ShellRoute(
      builder: (_, __, child) => HomeShell(child: child),
      routes: [
        GoRoute(path: '/cards', builder: (_, __) => const CardListScreen()),
        GoRoute(path: '/scan', builder: (_, __) => const ScanScreen()),
        GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
      ],
    ),
    GoRoute(path: '/cards/:id', builder: (_, state) => CardDetailScreen(id: state.pathParameters['id']!)),
    GoRoute(path: '/edit', builder: (_, state) => EditCardScreen(card: state.extra as BusinessCard?)),
    GoRoute(path: '/scan/preview', builder: (_, state) => ScanPreviewScreen(card: state.extra as BusinessCard)),
  ],
));
```

### Card list with search chips
```dart
class CardListScreen extends ConsumerWidget {
  const CardListScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cardsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('My Cards'), actions: [
        IconButton(icon: const Icon(Icons.search), onPressed: () => showSearch(context: context, delegate: CardSearchDelegate(ref.read)))
      ]),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text('New Card'), icon: const Icon(Icons.add),
        onPressed: () => context.push('/edit'),
      ),
      body: state.when(
        data: (cards) => cards.isEmpty ? _EmptyState() : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: cards.length,
          itemBuilder: (_, i) => CardTile(card: cards[i]),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
```

### Edit form with validation (excerpt)
```dart
class EditCardScreen extends ConsumerStatefulWidget {
  final BusinessCard? card;
  const EditCardScreen({super.key, this.card});
  @override
  ConsumerState<EditCardScreen> createState() => _EditCardScreenState();
}

class _EditCardScreenState extends ConsumerState<EditCardScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameCtrl;
  // ... other controllers

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.card?.fullName ?? '');
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    final card = widget.card?.copyWith(
      fullName: nameCtrl.text,
      updatedAt: DateTime.now(),
    ) ?? BusinessCard(
      id: const Uuid().v4(),
      fullName: nameCtrl.text,
      // ... map other fields
      accentColor: Colors.teal,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      tags: [], favorite: false, logs: [],
    );
    await ref.read(cardsProvider.notifier).upsert(card);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.card == null ? 'Create Card' : 'Edit Card')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Full name'),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            // ... phone, email with validators
            ElevatedButton(onPressed: _save, child: const Text('Save')),
          ],
        ),
      ),
    );
  }
}
```

### Repository (Hive)
```dart
class BusinessCardRepository {
  static const boxName = 'cards';
  Future<Box<BusinessCard>> _box() => Hive.openBox<BusinessCard>(boxName);

  Future<List<BusinessCard>> getAll() async => (await _box()).values.toList();

  Future<void> upsert(BusinessCard card) async {
    final box = await _box();
    await box.put(card.id, card.copyWith(updatedAt: DateTime.now()));
  }

  Future<void> delete(String id) async => (await _box()).delete(id);

  Future<List<BusinessCard>> search(String query, {String? category, String? businessType, bool? favorite}) async {
    final q = query.toLowerCase();
    return (await _box()).values.where((c) {
      final matchesText = [c.fullName, c.category, c.businessType, c.mobileNumber, c.companyName ?? '', ...c.tags]
        .any((f) => f.toLowerCase().contains(q));
      final matchesCat = category == null || c.category == category;
      final matchesType = businessType == null || c.businessType == businessType;
      final matchesFav = favorite == null || c.favorite == favorite;
      return matchesText && matchesCat && matchesType && matchesFav;
    }).toList();
  }
}
```

### Providers
```dart
final repositoryProvider = Provider((_) => BusinessCardRepository());
final cardsProvider = StateNotifierProvider<CardsNotifier, AsyncValue<List<BusinessCard>>>((ref) {
  final repo = ref.watch(repositoryProvider);
  return CardsNotifier(repo)..load();
});

class CardsNotifier extends StateNotifier<AsyncValue<List<BusinessCard>>> {
  CardsNotifier(this.repo) : super(const AsyncLoading());
  final BusinessCardRepository repo;

  Future<void> load() async => state = AsyncData(await repo.getAll());
  Future<void> upsert(BusinessCard card) async { await repo.upsert(card); await load(); }
  Future<void> remove(String id) async { await repo.delete(id); await load(); }
  Future<void> search(String query) async { state = AsyncData(await repo.search(query)); }
}

final scanProvider = StateNotifierProvider<ScanNotifier, AsyncValue<BusinessCard?>>((ref) => ScanNotifier());
```

### QR services
```dart
class QrService {
  String encode(BusinessCard card) => jsonEncode({
    'type': 'bizcard', 'version': 1,
    'payload': card.toJson(),
  });

  BusinessCard? decode(String raw) {
    try {
      final data = jsonDecode(raw);
      if (data['type'] != 'bizcard') return null;
      return BusinessCard.fromJson(Map<String, dynamic>.from(data['payload']));
    } catch (_) { return null; }
  }

  Widget render(String data) => QrImageView(data: data, backgroundColor: Colors.white);
}
```

### Scanner screen
```dart
class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});
  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  final _controller = MobileScannerController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR')),
      body: MobileScanner(
        controller: _controller,
        onDetect: (capture) {
          final raw = capture.barcodes.first.rawValue;
          if (raw == null) return;
          final card = ref.read(qrServiceProvider).decode(raw);
          _controller.stop();
          if (card == null) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid QR')));
            _controller.start();
          } else {
            context.push('/scan/preview', extra: card);
          }
        },
      ),
    );
  }
}
```

### Scan preview actions (save/update)
```dart
class ScanPreviewScreen extends ConsumerWidget {
  final BusinessCard card;
  const ScanPreviewScreen({super.key, required this.card});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Imported Card')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CardTile(card: card, compact: false),
            const Spacer(),
            Row(children: [
              Expanded(child: OutlinedButton(onPressed: () => context.pop(), child: const Text('Cancel'))),
              const SizedBox(width: 12),
              Expanded(child: ElevatedButton(onPressed: () async {
                await ref.read(cardsProvider.notifier).upsert(card);
                if (context.mounted) context.go('/cards');
              }, child: const Text('Save to my cards'))),
            ])
          ],
        ),
      ),
    );
  }
}
```

## 6. How to run
1. Install Flutter SDK (>=3.19) and set up Xcode/Android Studio toolchains.
2. Create project: `flutter create fancy_cards` then replace `lib/` with structure above and add `pubspec` dependencies.
3. Run code generation: `flutter pub get && flutter pub run build_runner build --delete-conflicting-outputs`.
4. Initialize Hive adapters in `main.dart` as shown.
5. Launch:
   - Android: `flutter run -d emulator-5554`
   - iOS: `flutter run -d ios` (after `pod install` in `ios/` if needed)
6. For QR scanning, grant camera permission when prompted.

## 7. Polish & future improvements
- Add cloud sync (Firebase/Supabase) with offline cache & merge strategy.
- Implement export/import (JSON, CSV, vCard) with duplicate resolution UI.
- Secure local data with encrypted Hive boxes + biometrics/PIN gate.
- Add localization files (ARB) for EN + ES; wrap strings with `AppLocalizations`.
- Accessibility: larger tap targets, semantic labels for QR images, high-contrast theme.
- Integrate saving to device contacts and importing from address book.
- Add card snapshot sharing (render card to image via `RepaintBoundary`).
- Activity timeline per card with filters by event/tag; calendar integration for follow-ups.
