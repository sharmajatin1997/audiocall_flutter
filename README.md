# 🎧 Audio Call — Flutter App

A **Flutter-based real-time audio calling application** template. This repository demonstrates how to structure and build an **in-app voice calling feature** similar to WhatsApp or Signal using Flutter. It is designed to be simple, clean, and easy to extend with real-time audio SDKs like **Agora** or **WebRTC**.

---

## 🚀 What This Repository Does

This project provides:

* 🎙️ Real-time audio call architecture
* 📞 Basic audio call UI structure
* 🔐 Microphone permission handling
* 🧩 Clean and extendable project structure
* 🛠️ Ready to integrate any RTC audio SDK

This repository can be used as a **starter template** or **reference project** for adding audio calling features to Flutter apps.

---

## 🛠️ Tech Stack

* **Flutter** (UI & application logic)
* **Agora RTC Engine / WebRTC** (for real-time audio calls – can be integrated)
* **permission_handler** (Microphone permissions)

---

## 📂 Project Structure

```
lib/
 ├── main.dart              # App entry point
 ├── audio_call_screen.dart # Audio call UI & logic
 ├── services/              # Audio call & RTC logic
 ├── utils/                 # Helpers & constants

pubspec.yaml
```

---

## ✨ Features Breakdown

### 1️⃣ Audio Calling

* One-to-one voice calling architecture
* RTC-ready structure

### 2️⃣ Permissions Handling

* Runtime microphone permission request
* Graceful permission handling

### 3️⃣ Clean UI Structure

* Easy-to-customize call UI
* Extendable for ringing, mute, speaker, etc.

---

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  permission_handler: ^11.3.1
  agora_rtc_engine: ^6.3.2   # Optional (recommended for audio calls)
```

---

## 🔐 Permissions Setup

### Android

`android/app/src/main/AndroidManifest.xml`

```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
```

---

### iOS

`ios/Runner/Info.plist`

```xml
<key>NSMicrophoneUsageDescription</key>
<string>Microphone access is required for audio calls</string>
```

---

## ▶️ How to Run

```bash
flutter pub get
flutter run
```

Run the app on a **real device** to test microphone functionality.

---

## 🧪 Use Cases

* Voice calls in chat applications
* Customer support audio calls
* Consultation & service-based apps
* Telephony-style communication apps

---

## 🧑‍💻 Author

**Jatin Sharma**
Flutter Developer

GitHub: [https://github.com/sharmajatin1997](https://github.com/sharmajatin1997)

---

## ⭐ Support

If this repository helps you:

* ⭐ Star the repo
* 🍴 Fork it
* 🧑‍💻 Use it in your projects

---

## 📄 License

This project is open-source and available under the **MIT License**.

---

> ⚠️ Note: This repository is a **starter template**. For production apps, integrate a secure backend and generate RTC tokens dynamically.
