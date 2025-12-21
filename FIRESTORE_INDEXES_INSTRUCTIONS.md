# Firestore Index Deployment Instructions

## Issue Summary
After testing build 20, the following features are showing Firestore index errors:
- ✅ Ingredients (index defined, needs manual creation)
- ✅ Supplies (index defined, needs manual creation)
- ✅ Recipes (index defined, needs manual creation)
- ✅ Orders (index defined, needs manual creation)
- ✅ Quotes (index defined, needs manual creation)
- ✅ Shopping Lists (index defined, needs manual creation)
- ❌ **Timer Recordings** (index defined, needs manual creation)

## Root Cause
The indexes are all defined correctly in `firestore.indexes.json`, but they haven't been manually created in Firebase Console yet. Firestore requires you to explicitly create composite indexes before queries using multiple fields can work.

## Solution Applied
Updated `firestore.indexes.json` with all necessary composite indexes:
- ingredients: `owner_id` + `created_at`
- supplies: `owner_id` + `created_at`
- recipes: `owner_id` + `created_at`
- orders: `owner_id` + `created_at`
- quotes: `owner_id` + `created_at`
- shopping_lists: `owner_id` + `created_at` (NEWLY ADDED)
- timer_recordings: `owner_id` + `startTime` (FIXED)
- timer_recordings: `owner_id` + `created_at` (NEWLY ADDED)

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
   - ✅ quotes (owner_id + created_at)
   - ⏳ shopping_lists (owner_id + created_at) - **NEW**
   - ⏳ timer_recordings (owner_id + startTime) - **FIXED**
   - ⏳ timer_recordings (owner_id + created_at) - **NEW**

You said earlier that you manually created ingredients, supplies, orders indexes. Those should already be "Enabled". You still need to create:
- quotes (owner_id + created_at)
- shopping_lists (owner_id + created_at) 
- timer_recordings (owner_id + startTime)
- timer_recordings (owner_id + created_at)

## Expected Result
After indexes are created and enabled:
- **Ingredients** will load and save successfully
- **Supplies** will load and save successfully
- **Recipes** will load and save successfully
- **Orders** will load and save successfully
- **Quotes** will load and save successfully
- **Shopping Lists** will load and save successfully
- **Timer recordings** will load and save successfully
- No more "[cloud_firestore/failed-precondition] The query requires an index" errors

## Files Changed
- ✅ `firestore.indexes.json` - Added shopping_lists index, fixed timer_recordings indexes
- ✅ `lib/screens/reminders/reminders_screen.dart` - Added empty state
- ✅ `lib/screens/orders/add_order_screen.dart` - Fixed duplicate save bug (added save guard)

## Next Build
After manually creating the indexes, they will persist. No need to recreate them for future builds.
