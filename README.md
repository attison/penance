# Penance

Atone for your social media sins. Track workouts to earn screen time minutes.

## Overview

Penance helps you build healthy habits by requiring physical activity to "pay" for social media usage. For every minute you spend on tracked apps, you owe a set of exercises (pushups, squats, etc.). Keep your balance positive, build up a bank of minutes for later, or work your way out of a deficit.

## Features

- **Customizable Workouts**: Set your workout type (pushups, squats, etc.) and how many equal 1 minute of screen time
- **Tap to Add**: Tap anywhere on the main screen to log workouts
- **Balance Tracking**: Visual feedback with green (positive), gray (equilibrium), or red (negative) backgrounds
- **Automatic Screen Time Monitoring**: Uses iOS DeviceActivity API to track selected apps in real-time
- **Lock Screen Widget**: Shows your current balance at a glance
- **History & Stats**: Weekly charts, YTD totals, and all-time statistics
- **Dark Mode Support**: Adaptive UI for light and dark modes
- **Notifications**: Get pinged when your balance hits zero

## How It Works

1. **Configure**: Choose your workout type and set the ratio (e.g., 5 pushups = 1 minute)
2. **Select Apps**: Pick which apps require penance (social media, games, etc.)
3. **Log Workouts**: Tap the screen to add workouts and build up minutes
4. **Auto-Track**: The app monitors your screen time automatically
5. **Stay Balanced**: Keep your balance at zero or positive

If you're going to waste your minutes, at least earn them.

## Technical Details

- Built with SwiftUI and iOS DeviceActivity framework
- Requires iOS 16+ and a physical device (Screen Time API unavailable in Simulator)
- Uses App Groups (`group.com.attison.penance`) for data sharing between app and extensions
- All data stored locally with UserDefaults - no cloud sync
- Three extensions: Main app, Widget, and DeviceActivityMonitor
