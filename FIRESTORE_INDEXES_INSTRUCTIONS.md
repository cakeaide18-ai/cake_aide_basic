# Firestore Index Deployment Instructions

## Issue Summary
After testing build 20, the following features are showing Firestore index errors:
- ✅ Ingredients (already fixed)
- ✅ Supplies (already fixed)  
- ✅ Recipes (already fixed)
- ✅ Orders (already fixed)
- ❌ **Timer Recordings** (needs fix)

## Root Cause
The `firestore.indexes.json` had incorrect field name for timer_recordings. It referenced `date` but the actual query uses `startTime`.

## Solution Applied
Updated `firestore.indexes.json` to add the correct composite indexes for timer_recordings:

1. **Index 1**: `owner_id` (ASC) + `startTime` (DESC) - for getting recent recordings
2. **Index 2**: `owner_id` (ASC) + `created_at` (DESC) - for base queries

## Manual Steps Required

You need to manually create these indexes in Firebase Console:

### Option 1: Use Error Link (Easiest)
1. Open the app and go to Timer feature
2. Try to save a timer recording
3. Click the error message - it will show a clickable link
4. Click the link to open Firebase Console with pre-filled index form
5. Click "Create Index"
6. Wait 1-2 minutes for the index to build
7. Try saving the timer again

### Option 2: Manual Creation in Firebase Console
1. Go to https://console.firebase.google.com
2. Select your project: `dlgrijpah7jlvfjuexnmcmv4p0rmbc`
3. Click "Firestore Database" in left sidebar
4. Click "Indexes" tab
5. Click "Create Index" button
6. Fill in the form:
   - **Collection ID**: `timer_recordings`
   - **Fields to index**:
     - Field: `owner_id`, Order: `Ascending`
     - Field: `startTime`, Order: `Descending`
7. Click "Create"
8. Wait for status to change from "Building" to "Enabled" (1-2 minutes)
9. Repeat for second index with `created_at` instead of `startTime`

### Option 3: Deploy via Firebase CLI
```bash
cd /Users/bolajieyo/Documents/cake_aide_basic
firebase deploy --only firestore:indexes
```

## Verification
After creating the indexes:
1. Go to Firebase Console → Firestore Database → Indexes tab
2. Verify all these indexes show status "Enabled":
   - ✅ ingredients (owner_id + created_at)
   - ✅ supplies (owner_id + created_at)
   - ✅ recipes (owner_id + created_at)
   - ✅ orders (owner_id + created_at)
   - ⏳ timer_recordings (owner_id + startTime) - **NEW**
   - ⏳ timer_recordings (owner_id + created_at) - **NEW**

## Expected Result
After indexes are created and enabled:
- Timer recordings will save successfully
- All data features (ingredients, supplies, recipes, orders, timer) will work without errors
- No more "[cloud_firestore/failed-precondition] The query requires an index" errors

## Files Changed
- ✅ `firestore.indexes.json` - Updated with correct timer_recordings indexes
- ✅ `lib/screens/reminders/reminders_screen.dart` - Added empty state

## Next Build
After manually creating the indexes, they will persist. No need to recreate them for future builds.
