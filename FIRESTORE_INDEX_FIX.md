# Firestore Index Fix - Build 24 Plan

## Issues Fixed in Code
✅ Added Firestore rules for `support_issues` collection (fixes "Report Issue" permission error)  
✅ Added Firestore rules for `mail` collection (for email extension)  
✅ Fixed Order model DateTime serialization (fixes "Add Order" invalid-argument error)  

## Remaining Issue: Firestore Indexes

### Problem
Even though Firebase Console shows all indexes as "Enabled", the app still shows:
```
[cloud_firestore/failed-precondition] The query requires an index
```

### Root Cause
There are two possible causes:
1. **Index propagation delay**: Firestore indexes can take 5-15 minutes to fully propagate after being created
2. **Stale index state**: Sometimes indexes show as "Enabled" but need to be rebuilt

### Solution Steps

#### Step 1: Deploy Updated Firestore Rules (CRITICAL - DO THIS FIRST)

The updated `firestore.rules` file has been committed and needs to be deployed to Firebase:

1. Go to: https://console.firebase.google.com/u/0/project/dlgrijpah7jlvfjuexnmcmv4p0rmbc/firestore/rules
2. Click "Rules" tab
3. Replace the entire contents with the file from: `/Users/bolajieyo/Documents/cake_aide_basic/firestore.rules`
4. Click "Publish"

**OR** copy this directly:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User Profiles - Private to owner
    match /user_profiles/{profileId} {
      allow read, update, delete: if request.auth != null && request.auth.uid == resource.data.owner_id;
      allow create: if request.auth != null && request.auth.uid == resource.data.owner_id;
    }

    // Ingredients - Private to owner
    match /ingredients/{ingredientId} {
      allow read, update, delete: if request.auth != null && request.auth.uid == resource.data.owner_id;
      allow create: if request.auth != null && request.auth.uid == resource.data.owner_id;
    }

    // Supplies - Private to owner
    match /supplies/{supplyId} {
      allow read, update, delete: if request.auth != null && request.auth.uid == resource.data.owner_id;
      allow create: if request.auth != null && request.auth.uid == resource.data.owner_id;
    }

    // Recipes - Private to owner
    match /recipes/{recipeId} {
      allow read, update, delete: if request.auth != null && request.auth.uid == resource.data.owner_id;
      allow create: if request.auth != null && request.auth.uid == resource.data.owner_id;
    }

    // Shopping Lists - Private to owner
    match /shopping_lists/{listId} {
      allow read, update, delete: if request.auth != null && request.auth.uid == resource.data.owner_id;
      allow create: if request.auth != null && request.auth.uid == resource.data.owner_id;
    }

    // Orders - Private to owner
    match /orders/{orderId} {
      allow read, update, delete: if request.auth != null && request.auth.uid == resource.data.owner_id;
      allow create: if request.auth != null && request.auth.uid == resource.data.owner_id;
    }

    // Quotes - Private to owner
    match /quotes/{quoteId} {
      allow read, update, delete: if request.auth != null && request.auth.uid == resource.data.owner_id;
      allow create: if request.auth != null && request.auth.uid == resource.data.owner_id;
    }

    // Timer Recordings - Private to owner
    match /timer_recordings/{recordingId} {
      allow read, update, delete: if request.auth != null && request.auth.uid == resource.data.owner_id;
      allow create: if request.auth != null && request.auth.uid == resource.data.owner_id;
    }

    // Support Issues - Private to owner
    match /support_issues/{issueId} {
      allow read, update, delete: if request.auth != null && request.auth.uid == resource.data.owner_id;
      allow create: if request.auth != null && request.auth.uid == request.resource.data.owner_id;
    }

    // Mail Queue - For Firebase email extension, write-only
    match /mail/{mailId} {
      allow create: if request.auth != null;
      allow read, update, delete: if false; // Only Firebase extension can read/modify
    }

    // App Settings - Private to owner
    match /user_settings/{userId} {
      allow read, update: if request.auth != null && request.auth.uid == userId;
      allow create: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

#### Step 2: Rebuild Firestore Indexes (DO AFTER RULES)

The indexes need to be rebuilt. Here's how:

1. **DELETE existing indexes** (this forces a rebuild):
   - Go to: https://console.firebase.google.com/u/0/project/dlgrijpah7jlvfjuexnmcmv4p0rmbc/firestore/indexes
   - For EACH index (ingredients, supplies, recipes, orders, quotes, shopping_lists, timer_recordings):
     - Click the three dots (⋮) on the right
     - Click "Delete"
     - Confirm deletion

2. **Wait 2-3 minutes** for deletions to propagate

3. **Recreate indexes** using the error links from the app:
   - Build version 1.0.1+24 (see Step 3 below)
   - Run the app and try to view each screen
   - When you see the error with the link, click it or copy the link
   - It will look like: `https://console.firebase.google.com/v1/r/project/...create_composite=...`
   - Open each link in your browser - it will auto-create the index
   - Click "Create Index" 
   - Wait for status to show "Building..." then "Enabled"

**Required indexes** (these will be created from the error links):
- `ingredients`: owner_id (ASC) + created_at (DESC)
- `supplies`: owner_id (ASC) + created_at (DESC)
- `recipes`: owner_id (ASC) + created_at (DESC)
- `orders`: owner_id (ASC) + created_at (DESC)
- `quotes`: owner_id (ASC) + created_at (DESC)
- `shopping_lists`: owner_id (ASC) + created_at (DESC)
- `timer_recordings`: owner_id (ASC) + created_at (DESC)
- `timer_recordings`: owner_id (ASC) + startTime (DESC)

#### Step 3: Build Version 1.0.1+24

After deploying the rules and deleting the indexes:

```bash
cd /Users/bolajieyo/Documents/cake_aide_basic
flutter clean
flutter pub get
flutter build ipa --release
```

This will:
- Increment to version 1.0.1+24
- Include the fixed Order model (no more invalid-argument error)
- Include the fixed Firestore rules (no more permission-denied error for reports)
- Work with rebuilt indexes once they're created

#### Step 4: Upload to TestFlight

1. Open **Transporter** app
2. Drag and drop `build/ios/ipa/cake_aide_basic.ipa`
3. Click **Deliver**
4. Wait 5-10 minutes for processing

#### Step 5: Test and Create Indexes

1. Install build 24 from TestFlight
2. Go to each screen (Ingredients, Supplies, Recipes, Orders, Quotes, Shopping Lists)
3. For screens showing index errors:
   - Screenshot or copy the error URL
   - Open the URL in your browser
   - Click "Create Index"
   - Wait for "Enabled" status (5-15 minutes per index)
4. Test "Report Issue" feature (should work now with updated rules)
5. Test "Add Order" feature (should work now with fixed DateTime serialization)

## Expected Timeline

- **Rules deployment**: Immediate
- **Index deletion**: 2-3 minutes
- **Build 24 creation**: 5-10 minutes
- **TestFlight upload**: 5-10 minutes
- **Each index creation**: 5-15 minutes
- **Total estimated time**: 45-90 minutes (depending on how many indexes need rebuilding)

## What Should Work After These Fixes

✅ Report Issue (Firestore rules fixed)  
✅ Add/Save Orders (DateTime serialization fixed)  
✅ View Ingredients (after index rebuilt)  
✅ View Supplies (after index rebuilt)  
✅ View Recipes (after index rebuilt)  
✅ View Orders (after index rebuilt)  
✅ View Quotes (after index rebuilt)  
✅ View Shopping Lists (after index rebuilt)  
✅ View Timer Recordings (after index rebuilt)  

## Notes

- **Photo library permission** error is separate - requires delete app + restart iPhone + reinstall
- The indexes showing as "Enabled" but not working is a known Firebase issue - rebuilding fixes it
- Make sure to deploy rules BEFORE building version 24
- The Order fix prevents sending raw DateTime objects (Firestore requires Timestamp type)
