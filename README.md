# Grahasthi (गृहस्थी)

**Your Home Manager** — a cross-platform household expense tracker built with **Dart** and **Flutter**, designed for Indian families.

Grahasthi brings milk bills, maid wages, kirana runs, LPG refills, and everything else under one roof. All data stays on your device. No account required.

---

## Features

### Dashboard
- Monthly expense overview across all trackers
- Budget tracking — set a monthly limit and see what's left
- Quick access to every tracker from one screen
- Time-based greetings in English or Hindi

### 11 Household Trackers

| Tracker | What it does |
|---------|--------------|
| 🥛 **Milk** | Daily litre logging per milk type, monthly calendar, bill sharing |
| 🧹 **House Help** | Attendance (present / absent / half-day / holiday), wages, advances |
| 🛒 **Groceries** | Category-wise kirana expenses with monthly calendar |
| 🏪 **Shop Credit** | Udhar ledger per shop — purchases and repayments |
| 🔥 **LPG Cylinder** | Refill history and spend tracking |
| ⚡ **Electricity** | Bill logging with unit and amount tracking |
| 💧 **Water** | Tanker and supply expense logging |
| 💂 **Security / Watchman** | Attendance and monthly payment tracking |
| 🚗 **Vehicle** | Fuel and maintenance logs |
| 📅 **EMI & Bills** | Recurring payments with due-date reminders |
| 🎉 **Festival Budget** | Festival-wise expense planning and tracking |

### Milk Tracker highlights
- **Set Default for Month** — fill the entire month with your default daily quantity (e.g. 1L/day) in one tap
- **No Milk Taken** — mark individual days when no milk was delivered; shown on the calendar and excluded from totals
- Multiple milk types with separate price-per-litre and default quantities
- Shareable monthly milk bill via WhatsApp or any app

### Reports
- Category-wise pie chart for the current month
- Biggest expense highlight
- Year-to-date summary

### Settings
- **English / Hindi** — full bilingual UI
- Monthly budget configuration
- Daily reminder time
- Dark theme with saffron accent

---

## Screenshots

<!-- Add screenshots here -->
<!-- ![Home](docs/screenshots/home.png) -->
<!-- ![Milk Tracker](docs/screenshots/milk.png) -->
<!-- ![Reports](docs/screenshots/reports.png) -->

---

## Tech Stack

| Layer | Technology |
|-------|------------|
| Language | [Dart](https://dart.dev) 3.2+ |
| UI framework | [Flutter](https://flutter.dev) 3.x |
| State management | [Provider](https://pub.dev/packages/provider) |
| Local storage | [Hive](https://pub.dev/packages/hive) + SharedPreferences |
| Charts | [fl_chart](https://pub.dev/packages/fl_chart) |
| Sharing | [share_plus](https://pub.dev/packages/share_plus) |
| Notifications | [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications) |

All data is stored locally on the device. No backend, no cloud sync (backup/restore planned for a future release).

---

## Getting Started

### Prerequisites

- [Dart SDK](https://dart.dev/get-dart) and [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart 3.2+ / Flutter 3.x)
- Android SDK (for Android builds)
- A device or emulator

Verify your setup:

```bash
flutter doctor
```

### Clone and run

```bash
git clone https://github.com/<your-username>/grahasthi.git
cd grahasthi
flutter pub get
flutter run
```

### Build for Android

**Debug APK** (for testing):

```bash
flutter build apk --debug
```

**Release APK** (for installing on your phone):

```bash
flutter build apk --release
```

The APK will be at:

```
build/app/outputs/flutter-apk/app-release.apk
```

Transfer it to your Android phone and install. If prompted, allow **Install from unknown sources** for the app you use to open the file (Files, Chrome, etc.).

**Install directly via USB** (with USB debugging enabled):

```bash
flutter run --release
```

### Build for Web

```bash
flutter run -d chrome
# or
flutter build web
```

---

## Project Structure

```
lib/
├── main.dart              # App entry point, provider setup
├── app.dart               # MaterialApp and routing
├── config/                # Theme, constants
├── l10n/                  # English & Hindi strings
├── providers/             # State management (one per tracker)
├── screens/               # UI screens
│   ├── home/
│   ├── milk/
│   ├── maid/
│   ├── grocery/
│   ├── credit/
│   ├── lpg/
│   ├── electricity/
│   ├── water/
│   ├── watchman/
│   ├── vehicle/
│   ├── emi/
│   ├── festival/
│   ├── reports/
│   └── settings/
├── services/              # Hive storage service
└── widgets/               # Reusable UI (calendar, cards, etc.)
```

---

## Localization

Grahasthi supports **English** and **Hindi (हिंदी)**. Switch languages anytime from Settings. Month names, currency formatting (₹), and all tracker labels are localized.

---

## Roadmap

- [ ] Google Drive backup & restore
- [ ] iOS build
- [ ] PDF export for monthly reports
- [ ] Widget for quick expense entry

---

## Contributing

Contributions are welcome. Feel free to open an issue or submit a pull request.

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/my-feature`)
3. Commit your changes
4. Push and open a PR

---

## License

This project is open source. Add your preferred license here (e.g. MIT).

---

<p align="center">❤️ Made in India</p>
