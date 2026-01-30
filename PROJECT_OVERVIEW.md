# Penance - Project Overview

## App Structure

```
Penance/
├── README.md                           # Setup instructions
├── PROJECT_OVERVIEW.md                 # This file
├── Penance/                           # Main app target
│   ├── App/
│   │   ├── PenanceApp.swift          # App entry point
│   │   └── Info.plist                # App configuration & permissions
│   ├── Models/
│   │   ├── CounterManager.swift      # Core business logic (balance, pushups, screen time)
│   │   └── ScreenTimeMonitor.swift   # Screen Time API integration
│   ├── Services/
│   │   ├── PersistenceService.swift  # UserDefaults + App Groups
│   │   └── NotificationService.swift # Push notifications
│   └── Views/
│       ├── ContentView.swift         # Swipeable tab container
│       ├── IncrementView.swift       # Tap-to-add pushups screen
│       └── HistoryView.swift         # Stats and history screen
└── PenanceWidget/                     # Widget extension target
    ├── PenanceWidget.swift           # Lock screen widget implementation
    └── PersistenceService.swift      # Shared data access
```

## Core Features

### 1. Increment Screen (Page 1)
**File:** `IncrementView.swift:1`

- **Tap anywhere** to add 5 pushups (= 1 minute)
- **Visual feedback:**
  - Green background when balance is positive
  - Red background when balance is negative
  - Smooth color transition animation
  - Pulse animation on tap
  - Haptic feedback
- **Balance display:**
  - Large centered number showing current minutes
  - "+" prefix for positive, "-" for negative
  - Updates in real-time

### 2. History Screen (Page 2)
**File:** `HistoryView.swift:1`

- **Current Balance Card** - Shows minutes remaining (green/red)
- **Total Pushups Card** - Lifetime pushup count (blue)
- **Screen Time Used Card** - Total minutes spent (orange)
- **Days Tracked Card** - Since start date (purple)
- **Start Date Card** - When tracking began (gray)

### 3. Lock Screen Widget
**File:** `PenanceWidget.swift:1`

- **Accessory Circular style** (like weather widget)
- Shows current balance with +/- prefix
- Green text for positive, red for negative
- Tap to open app
- Updates every 5 minutes

### 4. Balance System
**File:** `CounterManager.swift:52`

**Earning Minutes:**
- Tap screen → +5 pushups → +1 minute
- Formula: 5 pushups = 60 seconds = 1 minute

**Spending Minutes:**
- 1 minute of Instagram/X usage = -1 minute from balance
- Balance can go negative (debt system)

**Notification Trigger:**
- When balance crosses from positive to negative: **"Time's up loser!"**
- Only sent once per session in negative territory

## Technical Implementation

### Data Storage
**File:** `PersistenceService.swift:1`

All data stored locally in UserDefaults with App Groups:
- `balanceMinutes` - Current balance
- `totalPushups` - Lifetime pushup count
- `totalScreenTimeMinutes` - Lifetime screen time used
- `startDate` - First launch date (auto-set)
- `lastUpdated` - Last modification timestamp

**App Group:** `group.com.penance.app`
- Enables data sharing between main app and widget
- Widget reads balance to display on lock screen
- Main app writes updates, triggers widget refresh

### Screen Time Integration
**File:** `ScreenTimeMonitor.swift:1`

Uses Apple's Screen Time API:
- **FamilyControls** - Authorization framework
- **DeviceActivity** - Usage monitoring
- **ManagedSettings** - App-specific settings

**Monitoring Strategy:**
1. Request authorization on first launch
2. Timer checks every 60 seconds
3. Query Instagram and X usage
4. Deduct minutes from balance
5. Trigger notification if going negative

**Requirements:**
- Physical iPhone (not Simulator)
- User authorization (system prompt)
- Family Controls capability in Xcode

### Notifications
**File:** `NotificationService.swift:8`

**Permission:** Requested on app launch
**Trigger:** Balance crosses from ≥0 to <0
**Message:** "Time's up loser!"
**Timing:** Immediate (1 second delay)
**Frequency:** Once per negative session (won't spam)

## UI/UX Details

### Color Scheme
- **Positive Balance:** Green background (#00C851-ish)
- **Negative Balance:** Red background (#FF4444-ish)
- **Transition:** Smooth 0.5s ease animation

### Typography
- **System Rounded Design** throughout
- **Balance:** 80pt bold
- **Labels:** 24pt medium
- **Instructions:** 18pt regular

### Gestures
- **Tap anywhere** on increment screen (full screen gesture)
- **Swipe left/right** between pages (TabView)

### Animations
- **Pulse effect** on tap (1.1x scale, 0.2s)
- **Color transition** when crossing zero (0.5s)
- **Haptic feedback** on every tap (medium impact)

## Setup Checklist

- [ ] Create Xcode project in Penance folder
- [ ] Add all Swift files to main target
- [ ] Add Widget Extension target
- [ ] Add widget files to widget target
- [ ] Configure App Groups (both targets)
- [ ] Add Family Controls capability (main target)
- [ ] Update bundle identifiers
- [ ] Build on physical device
- [ ] Grant Screen Time permission
- [ ] Grant Notification permission
- [ ] Add widget to lock screen

## Testing Strategy

### Without Physical Device
- UI testing in Simulator
- Counter increment logic
- Color transitions
- Page swiping
- Data persistence (UserDefaults)
- Widget preview in Xcode

### With Physical Device (Required)
- Screen Time authorization flow
- Actual Instagram/X usage tracking
- Push notifications
- Lock screen widget
- Background monitoring

### Manual Testing
```swift
// Simulate screen time usage
ScreenTimeMonitor.shared.simulateScreenTime(minutes: 5)

// Reset all data
PersistenceService.shared.reset()
```

## Known Limitations

1. **Screen Time API restrictions:**
   - Requires iOS 15+
   - Physical device only
   - User must grant permission
   - May have delays in reporting usage

2. **Background limitations:**
   - iOS restricts background execution
   - Timer-based checks may not be perfectly real-time
   - Widget updates limited by system

3. **App-specific tracking:**
   - Only tracks Instagram and X
   - Cannot track Safari-based usage of these sites
   - Requires apps to be installed

## Future Enhancements

- [ ] More granular pushup increments (1, 5, 10, 20)
- [ ] Edit balance manually (for corrections)
- [ ] Daily/weekly reports with charts
- [ ] Export history as CSV
- [ ] Achievements and streaks
- [ ] Custom notification messages
- [ ] Support more social media apps
- [ ] Apple Watch companion app
- [ ] Home screen widgets (small/medium/large)
- [ ] Siri shortcuts integration
