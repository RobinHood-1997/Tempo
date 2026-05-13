# Context-Aware Focus Timer

A Flutter app that learns when you focus best — by task type and time of day.

## The Problem
Generic Pomodoro timers treat all focus sessions the same. 
But you don't code with the same energy at 9am as you do at 3pm. 
This app tracks that difference and tells you when your best 
focus windows are — per task type.

## What It Does
- 25-minute focus sessions with 5-minute breaks
- Three task types: Work, Study, Creative
- Logs every session locally (task type, time of day, duration)
- Surfaces insights like "You focus best on Work at 10:00 AM"
- Shows completion rates per task type
- Tracks daily streaks
- Sends break and focus reminders via local notifications

## Tech Stack
- **Flutter** + **Dart**
- **Riverpod** — state management
- **Hive** — local persistence
- **flutter_local_notifications** — break reminders
- **CustomPainter** — hand-drawn timer ring

## Architecture
lib/
models/          → Session data model
providers/       → Riverpod state (timer, insights)
repositories/    → Hive data access layer
screens/         → Home + Stats UI
services/        → Insight engine + Notifications
widgets/         → Reusable UI components

## What I Learned
This was my first Flutter app. Key concepts I worked through:
- StatefulWidget vs StatelessWidget and when to use each
- Riverpod StateNotifier for timer state management
- Hive for structured local persistence
- CustomPainter for the countdown ring arc
- Pure Dart algorithms for the insight engine

## Demo
[Will add screen recording link here]
