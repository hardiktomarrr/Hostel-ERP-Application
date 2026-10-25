# Lakshya's Hostel ERP — Agent Customization Guide

> **Last Updated**: 2026-08-14  
> **Project Type**: Flutter Multi-Platform ERP (Mobile + Web)  
> **Quick Start**: `flutter run` | **Test**: `flutter test` | **Build Web**: `flutter build web`

---

## 1. Project Overview

**Lakshya's Hostel ERP** is a dual-role Flutter application for managing hostel/flat operations:

- **Resident Role**: Dashboard with meal schedules, payment dues, support tickets, shuttle info, announcements
- **Admin/Manager Role**: Full administrative control with real-time Firestore listeners for resident management, payments, and support tickets

**Tech Stack**:
- **Framework**: Flutter 3.0+, Dart 3.0+
- **Backend**: Firebase (Auth, Firestore real-time database)
- **State Management**: ChangeNotifier pattern (custom reactive state)
- **UI**: Material Design 3, Google Fonts (Inter)
- **Platforms**: Android, iOS, Web

---

## 2. Essential Commands & Workflows

### Development
```bash
flutter run                          # Run on default device/emulator
flutter run --release               # Optimized release build
flutter pub get                      # Install dependencies
flutter clean                        # Clean build artifacts
```

### Testing & Analysis
```bash
flutter test                         # Run all unit and widget tests
flutter test --coverage             # Generate coverage report
flutter analyze                      # Static analysis (linting)
flutter doctor                       # Check dev environment setup
```

### Building
```bash
flutter build apk                   # Android APK
flutter build appbundle             # Android App Bundle (Play Store)
flutter build ios                   # iOS build (requires macOS)
flutter build web                   # Web build (outputs to build/web/)
```

### Code Generation (if needed)
```bash
flutter pub run build_runner build  # Run code generation
flutter pub run build_runner watch  # Watch for changes
```

---

## 3. Architecture & Key Patterns

### High-Level Structure
```
Entry Point (main.dart)
    ↓
Firebase Initialization + Theme Setup
    ↓
Login Screen (Role Selector)
    ↓
┌─────────────────┬──────────────────────┐
↓                 ↓
Resident          Admin Dashboard
Dashboard         (with Firestore Listeners)
    ↓                 ↓
Controllers (ChangeNotifier) ← Handle state & business logic
    ↓
Models (Domain objects)
    ↓
Widgets (Reusable components)
    ↓
Theme (Design tokens: colors, typography)
```

### State Management Pattern
The app uses **ChangeNotifier with manual listener subscription**:

```dart
// Controllers extend ChangeNotifier
class LoginController extends ChangeNotifier {
  String _password = '';
  LoginStatus _status = LoginStatus.initial;
  
  void setPassword(String value) {
    _password = value;
    notifyListeners();  // Triggers setState() in listeners
  }
  
  Future<void> login() async {
    _status = LoginStatus.loading;
    notifyListeners();
    // Async work...
    _status = LoginStatus.success;
    notifyListeners();
  }
}

// Usage in Screens
class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late LoginController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = LoginController();
    _controller.addListener(_onStateChange);
  }
  
  void _onStateChange() => setState(() {});
  
  @override
  void dispose() {
    _controller.removeListener(_onStateChange);
    super.dispose();
  }
}
```

### Firestore Real-Time Sync
Admin Dashboard uses StreamSubscription for live updates:

```dart
StreamSubscription? _ticketsSubscription;

@override
void initState() {
  super.initState();
  _ticketsSubscription = FirebaseFirestore.instance
    .collection('tickets')
    .snapshots()
    .listen((snapshot) {
      setState(() {
        _tickets = snapshot.docs
          .map((doc) => Ticket.fromFirestore(doc))
          .toList();
      });
    });
}

@override
void dispose() {
  _ticketsSubscription?.cancel();
  super.dispose();
}
```

---

## 4. Codebase Organization & Conventions

### Directory Structure
```
lib/
├── main.dart                    # Entry point, Firebase init, theme setup
├── firebase_options.dart        # Multi-platform Firebase config (auto-generated)
├── screens/                     # UI screens (one per file)
│   ├── login_screen.dart
│   ├── resident_dashboard_screen.dart
│   ├── admin_dashboard_screen.dart
│   ├── payments_screen.dart
│   └── ...
├── controllers/                 # ChangeNotifier state + business logic
│   ├── login_controller.dart
│   ├── resident_dashboard_controller.dart
│   ├── payments_controller.dart
│   └── ...
├── models/                      # Domain models & data classes
│   ├── user_role.dart          # enum UserRole { resident, owner }
│   ├── resident_data.dart      # Nested classes: Profile, DueInfo, MealItem, etc.
│   ├── payment_data.dart
│   ├── mess_menu_model.dart
│   └── ...
├── widgets/                     # Reusable UI components
│   ├── app_button.dart         # Styled button
│   ├── app_text_field.dart     # Styled input
│   ├── app_checkbox.dart
│   ├── bottom_nav_bar.dart     # Resident navigation
│   ├── brand_header.dart
│   ├── dues_summary_card.dart
│   ├── today_meals_card.dart
│   ├── payment_history_tile.dart
│   ├── announcements_card.dart
│   └── ...
└── theme/                       # Design system
    ├── app_colors.dart         # Color constants from DESIGN.md
    ├── app_theme.dart          # Material 3 ThemeData configuration
    └── app_typography.dart     # Text style helpers
```

### Naming Conventions
- **Controllers**: `{feature}_controller.dart` (e.g., `login_controller.dart`)
- **Screens**: `{feature}_screen.dart` (e.g., `resident_dashboard_screen.dart`)
- **Models**: `{entity}_model.dart` or domain class files (e.g., `resident_data.dart`)
- **Widgets**: `{purpose}_widget.dart` or `{component}_card.dart` (lowercase, descriptive)
- **Classes**: PascalCase (`LoginController`, `ResidentProfile`)
- **Constants**: `UPPER_SNAKE_CASE` or `static const` in theme classes
- **Private members**: Prefix with `_` (e.g., `_password`, `_status`)

### Code Organization Best Practices
1. **No barrel exports** — Use explicit imports: `import 'package:lakshya_hostel_erp/screens/login_screen.dart';`
2. **Feature-based grouping** — Related screens, controllers, and models organized by feature
3. **Shared components** — Common widgets and theme tokens centralized in `theme/` and `widgets/`
4. **Status enums** — Use enums for distinct states (e.g., `LoginStatus { initial, loading, success, error }`)
5. **Error handling** — Errors stored in controller state, not thrown directly

---

## 5. Design System & Styling

### Color Usage
All colors from [DESIGN.md](DESIGN.md) are defined in [lib/theme/app_colors.dart](lib/theme/app_colors.dart).

**Primary Colors**:
- `AppColors.primary` — #003d9b (deep blue)
- `AppColors.secondary` — #00687b (teal)
- `AppColors.tertiary` — #7b2600 (burnt orange)

**Semantic Colors**:
- `AppColors.successEmerald` — #36B37E (success/positive)
- `AppColors.warningAmber` — #FFAB00 (warning)
- `AppColors.errorRuby` — #FF5630 (error/negative)

**Surface Colors**:
- `AppColors.surfaceWhite` — #FFFFFF (cards, containers)
- `AppColors.slateGray` — #42526E (text secondary)
- `AppColors.deepNavy` — #091E42 (dark text/backgrounds)

### Typography
Font: **Inter** (from Google Fonts)

**Text Styles** (via [lib/theme/app_typography.dart](lib/theme/app_typography.dart)):
- `headline-lg`: 32px (large headlines)
- Standard Material 3 scale for body, labels, titles

### Spacing & Layout
Based on 8px base unit (from [DESIGN.md](DESIGN.md)):
- **Gutter**: 12px (space between elements)
- **Padding**: 16px (inner spacing)
- **Gap**: 24px (section spacing)
- **Border Radius**: 12px (cards, buttons)
- **Border Width**: 1px (subtle borders)

### Responsive Design
- **Mobile-first**: 4-column grid, 16px margins
- **Tablet/Web**: 2-column card layouts, expanded spacing
- Use `MediaQuery.of(context).size.width` for breakpoints if needed

---

## 6. Firebase Integration & Data Model

### Configuration
- **Project ID**: `lakshya-s-erp`
- **Platform Keys**:
  - Android: `1:935763498289:android:d99c821bd25d929ccbcc10`
  - iOS: `1:935763498289:ios:479dd53015afd2a8cbcc10`
  - Web: `1:935763498289:web:1c4f3f761f8a921fcbcc10`

### Initialization
```dart
// In main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const LakshyaHostelErpApp());
}
```

### Collections & Data Structure
- **`tickets`** — Support tickets with `status` field (lowercase: 'open', 'in progress', 'resolved')
- **`payments`** — Payment records with due dates, amounts, UTR confirmations
- **`residents`** — Resident profiles with contact info, dues summary
- **`menus`** — Meal schedules by day/category

### Key Pattern: Firestore Listeners
Admin Dashboard actively listens to Firestore changes:
- Uses `StreamSubscription` for real-time updates
- Unsubscribe in `dispose()` to prevent memory leaks
- Status field stored lowercase in Firestore

---

## 7. Common Workflows & Code Examples

### Adding a New Screen
1. Create `lib/screens/{feature}_screen.dart` with `StatefulWidget`
2. Create `lib/controllers/{feature}_controller.dart` extending `ChangeNotifier`
3. Define any new models in `lib/models/` if needed
4. Wire controller to screen via `initState()` listener
5. Import and navigate using `Navigator.push()`

### Adding a Reusable Widget
1. Create `lib/widgets/{component}.dart`
2. Extract common UI patterns (buttons, cards, text fields)
3. Accept parameters for customization
4. Use theme colors from `AppColors`
5. Test with multiple use cases in different screens

### Adding Firestore Integration
```dart
// Read once
final doc = await FirebaseFirestore.instance
  .collection('residents')
  .doc(userId)
  .get();

// Real-time listener
FirebaseFirestore.instance
  .collection('tickets')
  .snapshots()
  .listen((snapshot) {
    // Handle updates
  });

// Write/Update
await FirebaseFirestore.instance
  .collection('payments')
  .add({'amount': 5000, 'status': 'pending'});
```

### State Management with ChangeNotifier
- Always call `notifyListeners()` after state changes
- Use enums for status states (avoid string magic values)
- Handle errors by storing in state, not throwing
- Cancel listeners in `dispose()` to prevent memory leaks

---

## 8. Testing & Quality

### Test Structure
- Unit tests in `test/` folder
- Widget tests for UI components
- Integration tests for multi-screen flows

### Running Tests
```bash
flutter test                      # Run all
flutter test test/widget_test.dart  # Specific file
flutter test --coverage          # With coverage report
```

### Key Areas for Testing
- Controller logic (ChangeNotifier state changes)
- Widget rendering with different states
- Firebase interactions (mock FirebaseFirestore)
- Form validation in controllers

---

## 9. MCP Server Integration & AI Agent Context

### Why MCP Matters for This Project
This Flutter project benefits from **Model Context Protocol (MCP) servers** to provide AI agents with:
1. **Real-time project state** — Build status, test results, active errors
2. **Firestore schema inspection** — Current collections, document structure, indexes
3. **Code navigation** — Quick lookup of symbols, imports, dependencies
4. **Build & deployment tools** — Trigger builds, generate reports, manage releases

### Recommended MCP Server Setup

#### 1. **Flutter/Dart Development Server** (For Code Context)
Expose via MCP:
- Pubspec dependencies and version constraints
- Analyzer errors and warnings (via `flutter analyze`)
- Build output and Gradle build information
- Test discovery and coverage reports
- Hot reload status during development

**Key Endpoints**:
```
/dependencies      → List all pubspec.yaml dependencies
/lint              → Run flutter analyze, return issues
/build-info        → Get current build status
/tests             → List available tests, run them
/coverage          → Generate and return coverage report
```

#### 2. **Firestore Schema Inspector** (For Data Model Context)
Expose via MCP:
- Active collections in Firestore
- Document structure/schema inference
- Sample documents for reference
- Indexes and query constraints
- Real-time listener status from admin screens

**Key Endpoints**:
```
/collections       → List all collections in database
/schema/{collection} → Infer schema from sample docs
/sample-docs/{collection} → Get representative docs
/indexes           → List Firestore indexes
```

#### 3. **Theme & Design System Server** (For UI Consistency)
Expose via MCP:
- Design tokens from DESIGN.md and app_colors.dart
- Material 3 theme configuration
- Typography scale and font mappings
- Responsive breakpoints

**Key Endpoints**:
```
/colors            → Return all color constants
/typography        → Return text styles
/spacing           → Return spacing values (8px base)
/theme-data        → Return full ThemeData JSON
```

#### 4. **Navigation & Screen Registry** (For Feature Context)
Expose via MCP:
- Screens and their entry points
- Navigation flows (resident vs admin)
- Route parameters and guards
- Screen-to-controller mappings

**Key Endpoints**:
```
/screens           → List all screens with descriptions
/navigation-graph  → Show navigation flow diagram
/routes/{screen}   → Get route info for screen
```

### Setting Up an MCP Server for This Project

**Option 1: Node.js/TypeScript MCP Server**
```typescript
// example-mcp-server.ts
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio";
import { Server } from "@modelcontextprotocol/sdk/server/server";
import { CallToolRequestSchema } from "@modelcontextprotocol/sdk/types";

const server = new Server({
  name: "lakshya-erp-context",
  version: "1.0.0",
});

// Register tools for Flutter commands
server.setRequestHandler(CallToolRequestSchema, async (request) => {
  if (request.params.name === "flutter-analyze") {
    // Run: flutter analyze
    // Parse output, return structured errors
  }
  if (request.params.name === "get-firestore-schema") {
    // Connect to Firebase, inspect collections
    // Return schema JSON
  }
  // ... more tools
});

const transport = new StdioServerTransport();
await server.connect(transport);
```

**Option 2: Python MCP Server**
```python
# mcp_server.py
from mcp.server.models import Tool
import subprocess
import json

server = MCP()

@server.tool()
def flutter_test():
    """Run Flutter tests and return results"""
    result = subprocess.run(["flutter", "test", "--json"], capture_output=True)
    return json.loads(result.stdout)

@server.tool()
def get_firestore_collections():
    """Get active Firestore collections"""
    # Use Firebase Admin SDK to inspect database
    # Return collection list with sample schemas
    pass
```

### Expected Benefits for AI Agents
1. **Faster problem diagnosis** — See actual linting errors, build failures in real-time
2. **Smarter code generation** — Understand actual Firestore schema before suggesting queries
3. **Design consistency** — Never suggest wrong colors or spacing values
4. **Better navigation** — Understand screen dependencies and routing constraints
5. **Fewer hallucinations** — Ground all suggestions in actual project state

---

## 10. Common Pitfalls & Troubleshooting

### State Management Issues
- ❌ **Mistake**: Forgetting to call `notifyListeners()` after state change
- ✅ **Solution**: Always call `notifyListeners()` in controller methods after updating `_status` or data
- ✅ **Prevention**: Use extension methods to enforce this pattern

### Firebase Connection Problems
- ❌ **Mistake**: Firestore queries without proper error handling
- ✅ **Solution**: Always wrap queries in try-catch, store errors in controller state
- ✅ **Prevention**: Use consistent error enum in all controllers

### Memory Leaks
- ❌ **Mistake**: Not canceling Firestore listeners or removing controller listeners in `dispose()`
- ✅ **Solution**: Always `_subscription?.cancel()` and `_controller.removeListener()` in `dispose()`
- ✅ **Prevention**: Use consistent disposal pattern across all stateful screens

### Theme Not Applying
- ❌ **Mistake**: Using hardcoded colors instead of `AppColors` constants
- ✅ **Solution**: Import `app_colors.dart`, use `AppColors.primary` etc.
- ✅ **Prevention**: Enable linting rule to flag non-constant color usage

### Platform-Specific Issues
- ❌ **Mistake**: Assuming `DefaultFirebaseOptions.currentPlatform` works without proper initialization
- ✅ **Solution**: Always call `WidgetsFlutterBinding.ensureInitialized()` before Firebase init
- ✅ **Prevention**: Test on each platform (Android, iOS, Web) before merging

### Build Size & Performance
- ❌ **Mistake**: Importing entire packages for single utilities
- ✅ **Solution**: Use only needed imports, tree-shake unused code
- ✅ **Prevention**: Monitor build size with `flutter build apk --analyze-size`

---

## 11. Resources & Documentation

### Official Docs
- [Flutter Documentation](https://docs.flutter.dev/) — Official guide
- [Firebase for Flutter](https://firebase.google.com/docs/flutter/setup) — Setup and APIs
- [Material Design 3](https://m3.material.io/) — Design system spec
- [Dart Language Guide](https://dart.dev/guides) — Language features

### Project Docs
- [DESIGN.md](DESIGN.md) — Color palette and typography
- [firebase.json](firebase.json) — Multi-platform Firebase config
- [pubspec.yaml](pubspec.yaml) — Dependencies and version constraints

### Debugging Tools
```bash
flutter logs              # View device/emulator logs
flutter run --verbose    # Verbose output for troubleshooting
flutter pub outdated     # Check for dependency updates
flutter pub upgrade      # Upgrade dependencies safely
```

---

## 12. AI Agent Checklist

When working on this codebase, ensure:

- [ ] **State Updates**: All ChangeNotifier state changes followed by `notifyListeners()`
- [ ] **Cleanup**: All listeners and subscriptions canceled in `dispose()`
- [ ] **Colors**: All color values come from `AppColors` constants
- [ ] **Naming**: File and class names follow project conventions
- [ ] **Imports**: Use explicit imports, no barrel exports
- [ ] **Error Handling**: Errors stored in controller state, not thrown
- [ ] **Firebase**: All Firestore queries wrapped in try-catch
- [ ] **Testing**: New features include unit/widget tests
- [ ] **Responsive**: Designs tested on mobile, tablet, and web
- [ ] **Accessibility**: Text contrast meets WCAG standards (handled by Material 3)

---

**Questions?** Start by examining [lib/main.dart](lib/main.dart) for entry point, then follow the architecture to specific features.

