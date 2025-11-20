# How Firebase Stores Calendar Data - Complete Guide

## Overview

Your app uses **Firebase Firestore** (a NoSQL database) to store calendar events. Here's exactly how it works:

---

## 📊 Data Flow: From UI to Firebase

### Step 1: User Creates Event
```
CreateEventView (UI)
    ↓
User fills in: title, location, dates, description
    ↓
User taps "Save" button
    ↓
save() function creates Event object
    ↓
FirebaseService.save(event, userId) is called
    ↓
Data is converted to Firestore format
    ↓
Saved to Firebase Firestore database
```

### Step 2: Data Retrieval
```
AppState.refreshCalendarEvents()
    ↓
FirebaseService.fetchEvents(userId) is called
    ↓
Firestore query: "Get all events where userId = current user"
    ↓
Data is converted back to Event objects
    ↓
Displayed in EventCalendarView
```

---

## 🗄️ Firestore Database Structure

Your calendar events are stored in Firestore like this:

```
firestore/
└── events/                    ← Collection (like a table)
    ├── abc123xyz/             ← Document (like a row)
    │   ├── userId: "user123"
    │   ├── title: "Study Session"
    │   ├── location: "Library"
    │   ├── startDate: Timestamp(2025-01-15 14:00:00)
    │   ├── endDate: Timestamp(2025-01-15 16:00:00)
    │   ├── description: "CS101 group study"
    │   ├── rsvp: "going"
    │   ├── createdAt: Timestamp(...)
    │   ├── updatedAt: Timestamp(...)
    │   └── rsvps/             ← Subcollection (for multi-user RSVPs)
    │       └── user456/
    │           ├── status: "going"
    │           └── updatedAt: Timestamp(...)
    │
    ├── def456uvw/             ← Another event document
    │   ├── userId: "user123"
    │   ├── title: "Gym Workout"
    │   └── ...
    │
    └── ghi789rst/             ← Another event document
        └── ...
```

---

## 💾 How Data is Stored (Code Breakdown)

### 1. Creating/Saving an Event

**Location:** `CreateEventView.swift` → `save()` function

```swift
// User creates event in UI
let newEvent = Event(
    id: "",  // Empty - Firebase will generate ID
    title: "Study Session",
    location: "Library",
    startDate: Date(),
    endDate: Date().addingTimeInterval(3600),
    description: "CS101 group study",
    rsvp: .going
)

// Save to Firebase
let firebaseService = FirebaseService()
try await firebaseService.save(
    event: newEvent, 
    userId: appState.userProfile.id  // Links event to user
)
```

**What happens in `FirebaseService.save()`:**

```swift
// 1. Convert Event to Firestore format
let firestoreEvent = FirestoreEvent(from: event, userId: userId)

// 2. Convert to dictionary
let data = try firestoreEvent.toDictionary()
// Result: [
//     "userId": "user123",
//     "title": "Study Session",
//     "startDate": Timestamp(...),
//     ...
// ]

// 3. Save to Firestore
let docRef = db.collection("events").document()  // Generate new document ID
try await docRef.setData(data)  // Save to Firebase
```

**Result in Firebase Console:**
- New document created in `events` collection
- Document ID: Auto-generated (e.g., "abc123xyz")
- All fields stored as shown above

---

### 2. Fetching Events

**Location:** `AppState.swift` → `refreshCalendarEvents()`

```swift
// Fetch user's events from Firebase
let firebaseEvents = try await firebaseService.fetchEvents(for: userProfile.id)
```

**What happens in `FirebaseService.fetchEvents()`:**

```swift
// 1. Query Firestore
let snapshot = try await db.collection("events")
    .whereField("userId", isEqualTo: userId)  // Filter by user
    .order(by: "startDate", descending: false)  // Sort by date
    .getDocuments()

// 2. Convert Firestore documents to Event objects
let events = snapshot.documents.map { doc in
    let firestoreEvent = try doc.data(as: FirestoreEvent.self)
    return firestoreEvent.toEvent(id: doc.documentID)
}

// 3. Return array of Event objects
return events
```

**Result:**
- Array of `Event` objects
- Only events belonging to the current user
- Sorted by start date (earliest first)

---

## 🔍 Querying Examples

### Get All User's Events
```swift
let events = try await firebaseService.fetchEvents(for: "user123")
// Returns: All events where userId = "user123"
```

### Get Events in Date Range
```swift
let startDate = Date()
let endDate = Calendar.current.date(byAdding: .day, value: 7, to: startDate)!

let events = try await firebaseService.fetchEvents(
    for: "user123",
    from: startDate,
    to: endDate
)
// Returns: Events between startDate and endDate
```

### Real-Time Updates (Live Sync)
```swift
// Set up listener - automatically updates when data changes
let listener = firebaseService.observeEvents(for: "user123") { events in
    // This closure is called whenever events change in Firebase
    print("Events updated: \(events.count)")
    // Update your UI here
}

// Later, remove listener when done:
listener.remove()
```

---

## 📝 Data Types in Firestore

| Swift Type | Firestore Type | Example |
|------------|----------------|---------|
| `String` | `string` | `"Study Session"` |
| `Date` | `timestamp` | `Timestamp(2025-01-15 14:00:00)` |
| `Int` | `number` | `42` |
| `Bool` | `boolean` | `true` |
| `[String]` | `array` | `["CS101", "Math 221"]` |

**Important:** Dates are converted to `Timestamp` objects in Firestore, then converted back to `Date` when reading.

---

## 🔐 Security Rules (Who Can Access What)

Your Firestore security rules ensure:

```javascript
// Users can only read/write their own events
match /events/{eventId} {
  allow read, write: if request.auth.uid == resource.data.userId;
  allow create: if request.auth.uid == request.resource.data.userId;
}
```

**What this means:**
- ✅ User can create events with their own `userId`
- ✅ User can read/update/delete only their own events
- ❌ User cannot access other users' events
- ❌ Unauthenticated users cannot access any events

---

## 🎯 Complete Example: Create → Read → Update → Delete

### 1. CREATE Event
```swift
let event = Event(
    id: "",
    title: "Team Meeting",
    location: "Room 101",
    startDate: Date(),
    endDate: Date().addingTimeInterval(3600),
    description: "Project discussion",
    rsvp: .going
)

let firebaseService = FirebaseService()
try await firebaseService.save(event: event, userId: "user123")
// ✅ Event saved to Firebase
```

### 2. READ Events
```swift
let firebaseService = FirebaseService()
let events = try await firebaseService.fetchEvents(for: "user123")
// ✅ Returns: [Event(title: "Team Meeting", ...), ...]
```

### 3. UPDATE Event
```swift
// Modify the event
var event = events.first!
event.title = "Team Meeting - Updated"

// Save again (with existing ID)
try await firebaseService.save(event: event, userId: "user123")
// ✅ Event updated in Firebase
```

### 4. DELETE Event
```swift
let firebaseService = FirebaseService()
try await firebaseService.delete(eventId: "firebase_abc123xyz")
// ✅ Event deleted from Firebase
```

---

## 🔄 How It Works in Your App

### When User Opens Calendar View:

1. **EventCalendarView** displays
2. Calls `appState.refreshCalendarEvents()`
3. Fetches from **Firebase** (user's saved events)
4. Fetches from **Local Calendar** (device calendar)
5. Merges both lists
6. Displays all events

### When User Creates New Event:

1. User fills form in **CreateEventView**
2. Taps "Save"
3. Event saved to **Firebase**
4. `refreshCalendarEvents()` called automatically
5. New event appears in calendar view

### Data Persistence:

- ✅ Events saved to Firebase persist across devices
- ✅ Events saved to Firebase persist after app restart
- ✅ Events saved to Firebase are backed up in cloud
- ✅ Multiple users can have separate event collections

---

## 📱 Viewing Data in Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project: **ai-hackathon-edcd2**
3. Click **Firestore Database**
4. Click **Data** tab
5. You'll see:
   ```
   events/
     └── [document-id]/
         ├── userId: "user123"
         ├── title: "Study Session"
         ├── startDate: January 15, 2025 at 2:00:00 PM
         └── ...
   ```

---

## 🚀 Advanced: Real-Time Sync

To get live updates when events change:

```swift
// In AppState or a ViewModel
private var eventListener: ListenerRegistration?

func setupEventListener() {
    let firebaseService = FirebaseService()
    eventListener = firebaseService.observeEvents(for: userProfile.id) { [weak self] events in
        Task { @MainActor in
            // Update UI with new events
            self?.events = events
        }
    }
}

func removeEventListener() {
    eventListener?.remove()
}
```

**Benefits:**
- Events update automatically when changed on another device
- No need to manually refresh
- Real-time collaboration possible

---

## 🎓 Key Concepts

1. **Collection** = Table (e.g., `events`)
2. **Document** = Row (e.g., one event)
3. **Field** = Column (e.g., `title`, `startDate`)
4. **Query** = Filter/search (e.g., "get events for user123")
5. **Listener** = Real-time updates

---

## ✅ Summary

**To Store Calendar Data:**
- Use `FirebaseService.save(event:userId:)` 
- Data automatically saved to Firestore `events` collection

**To Retrieve Calendar Data:**
- Use `FirebaseService.fetchEvents(for:userId:)`
- Returns array of `Event` objects

**Data Structure:**
- Each event is a document in `events` collection
- Linked to user via `userId` field
- Dates stored as Firestore Timestamps

**Security:**
- Users can only access their own events
- Enforced by Firestore security rules

That's it! Your calendar data is now stored in Firebase and synced across devices! 🎉


