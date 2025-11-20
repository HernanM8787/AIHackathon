# Firebase Setup Guide for Calendar Events

## Step-by-Step Instructions

### 1. Enable Firestore Database

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project: **ai-hackathon-edcd2**
3. Click **Firestore Database** in the left sidebar
4. If you see "Create database" button:
   - Click **Create database**
   - Choose **Production mode** (we'll add security rules)
   - Select a location (e.g., **us-central1** or closest to you)
   - Click **Enable**
5. Wait for the database to be created (takes ~1 minute)

### 2. Set Security Rules

1. In Firestore Database, click the **Rules** tab
2. Copy the rules from `firestore.rules` file in this project
3. Paste them into the Firebase Console Rules editor
4. Click **Publish**

**Important:** These rules ensure:
- Users can only read/write their own events
- Only authenticated users can access data
- Users can manage their own RSVP status

### 3. Create Required Indexes

Firestore needs indexes for queries that filter by `userId` and sort by `startDate`.

**Option A: Automatic (Recommended)**
- When you first run the app and create/fetch events, Firebase will show an error with a link
- Click the link to automatically create the index
- Wait ~1-2 minutes for index to build

**Option B: Manual**
1. In Firestore Database, click the **Indexes** tab
2. Click **Create Index**
3. Collection ID: `events`
4. Add fields:
   - `userId` (Ascending)
   - `startDate` (Ascending)
5. Click **Create**
6. Wait for index to build (status will show "Enabled")

### 4. Verify Authentication is Enabled

1. Click **Authentication** in the left sidebar
2. Click **Get started** if needed
3. Go to **Sign-in method** tab
4. Enable **Email/Password** provider:
   - Click on **Email/Password**
   - Toggle **Enable**
   - Click **Save**

### 5. Test the Setup

1. Run your app
2. Create an account or sign in
3. Create a new event from the calendar view
4. Check Firestore Database → **Data** tab
5. You should see:
   - A `users` collection with your user document
   - An `events` collection with your event document

## Data Structure

Your Firestore will have:

```
firestore/
├── users/
│   └── {userId}/
│       ├── displayName: string
│       ├── email: string
│       ├── usernameLowercase: string
│       └── updatedAt: timestamp
│
└── events/
    └── {eventId}/
        ├── userId: string
        ├── title: string
        ├── location: string
        ├── startDate: timestamp
        ├── endDate: timestamp
        ├── description: string
        ├── rsvp: string ("going" | "notGoing" | "undecided")
        ├── createdAt: timestamp
        ├── updatedAt: timestamp
        └── rsvps/ (subcollection)
            └── {userId}/
                ├── status: string
                └── updatedAt: timestamp
```

## Troubleshooting

**Error: "Missing or insufficient permissions"**
- Check that security rules are published
- Verify user is authenticated
- Check that `userId` in event matches authenticated user ID

**Error: "The query requires an index"**
- Click the error link in Xcode console to create index automatically
- Or manually create index in Firebase Console → Indexes tab

**Events not showing up**
- Check Firestore → Data tab to see if events are being created
- Verify `refreshCalendarEvents()` is being called after sign-in
- Check Xcode console for error messages

## Quick Checklist

- [ ] Firestore Database created
- [ ] Security rules published
- [ ] Indexes created (or will be auto-created on first use)
- [ ] Email/Password authentication enabled
- [ ] Test: Create account → Create event → Verify in Firestore


