Flutter Offline-First Product Sync App

A production-ready Flutter application showcasing offline-first architecture, media optimization, and cloud synchronization using Hive and Firebase.

This project demonstrates how to build real-world mobile apps that perform reliably on low-end devices, slow internet connections, and unstable networks, while still delivering a smooth user experience.

🚀 Key Features

📦 Offline-first data storage using Hive

☁️ Cloud synchronization with Firebase (Storage + Firestore)

📸 Native camera integration for capturing product images in-app

🖼️ Automatic image compression & resizing before upload

🔄 Reliable local → cloud sync with conflict-safe logic

🎞️ Smooth UI animations with performance-aware toggle

⚙️ Option to disable animations for low-spec / low-performance devices

📄 Dynamic PDF generation for product reports and summaries

📤 Share PDFs via WhatsApp and Telegram

🌐 Optimized for slow and unstable internet connections

⚡ Fully asynchronous background operations

📱 Clean, responsive, and scalable UI design

🛠️ Tech Stack

Flutter (Dart)

Hive – Local NoSQL database

Firebase Firestore – Cloud database

Firebase Storage – Media storage

Image processing – Resize & JPEG compression

PDF generation & native sharing

🖼️ Image Optimization Pipeline

Camera images (≈2–3 MB) are optimized before upload:

Resize to 1200px max width

JPEG compression at ~75% quality

Final image size: ~300–600 KB

This dramatically reduces:

Upload time

Data usage

Sync failures on slow networks

🔄 Sync Workflow

Product data is saved locally using Hive

Images are captured via camera or selected from storage

Images are resized and compressed on-device

Optimized images are uploaded to Firebase Storage

Download URLs are generated

Product metadata is stored in Firestore

Local and cloud data remain synchronized

📄 PDF Generation & Sharing

Generate professional PDF reports from local data

Includes product details and images

Preview PDFs inside the app

Share directly via WhatsApp and Telegram using native intents

This feature is designed for real business workflows such as reporting, inventory sharing, and record keeping.

🎞️ Performance-Aware UI

Smooth animations enabled by default

Optional low-performance mode:

Disables or reduces animations

Improves responsiveness on low-end devices

Designed for accessibility and battery efficiency

🌐 Network-Aware Design

The app is built to handle:

Slow upload speeds (1 Mbps and below)

High network latency

Intermittent connectivity

Sync performance automatically improves on faster networks without code changes.

▶️ Getting Started
Prerequisites

Flutter SDK

Firebase project configuration

Android or iOS device/emulator

Run the app
flutter pub get
flutter run --release

🎯 Project Purpose

This project was built as a portfolio-grade application to demonstrate:

Offline-first mobile architecture

Media optimization and cloud sync

Performance-aware UI design

Real-world Flutter development practices

👤 Author

Alazar Abate
Flutter Developer
Focused on performance, scalability, and real-world mobile solutions.
