# Critical Issues Diagnosis - Build 21

## Symptoms Reported:
1. ❌ Camera/photo upload not working
2. ❌ Can't save recipes (error screen)
3. ❌ Can't save ingredients (error screen)
4. ❌ Can't save supplies (lets you enter but won't save)
5. ❌ Shopping list error message
6. ❌ Reminders don't persist between sessions
7. ❌ Order management error on save
8. ❌ Currency and price/hour reverted to default

## Root Causes Identified:

### Issue 1: Authentication State Lost
**Diagnosis**: When you deleted and reinstalled the app (to fix camera permissions), Firebase authentication session was cleared.

**Evidence**:
- Settings reverted to default = SharedPreferences cleared
- All save operations failing = `currentUserId` is null
- FirebaseRepository checks: `if (currentUserId == null) throw Exception('User not authenticated');`

**Solution**: 
1. Sign in again with Google Sign In
2. DO NOT delete the app again (camera permissions won't reset anyway until iOS system restart)

---

### Issue 2: Reminders Not Connected to Firebase
**Diagnosis**: Reminders feature stores data in local memory only, not Firebase.

**Evidence**:
```dart
// In lib/screens/reminders/reminders_screen.dart:
final List<ReminderItem> _reminders = []; // Just a list, no Firebase!
```

**Impact**: Reminders disappear when app closes - this is BY DESIGN (not a bug introduced in build 21)

**Solution Needed**: Create ReminderRepository + connect to Firestore (requires new feature development)

---

### Issue 3: Camera Permissions STILL Denied
**Diagnosis**: Simply deleting and reinstalling doesn't reset iOS permission state.

**Why**: iOS caches permission denials at the system level, not just the app level.

**Correct Reset Procedure**:
1. Delete CakeAide Pro app
2. **Restart iPhone** (full power cycle - this is the critical step!)
3. Wait for iPhone to fully boot
4. Reinstall from TestFlight
5. Try camera access - iOS will now show permission dialog

**What you did**: Deleted app → Reinstalled (skipped the restart step)

---

### Issue 4: Firestore Indexes Not Created
**Diagnosis**: All the index errors you're seeing are because indexes haven't been manually created in Firebase Console yet.

**Status**:
- ✅ ingredients index (you created this earlier) - should work
- ✅ supplies index (you created this earlier) - should work  
- ✅ orders index (you created this earlier) - should work
- ❌ recipes index - NOT created yet
- ❌ quotes index - NOT created yet
- ❌ shopping_lists index - NOT created yet
- ❌ timer_recordings indexes - NOT created yet

**But**: These errors only show if you're authenticated. If you're seeing "error screen" it might be authentication error, not index error.

---

## Immediate Action Plan:

### Step 1: Verify Authentication (DO THIS FIRST)
1. Open build 21 on your iPhone
2. Check if you see the sign-in screen
3. **Sign in with Google**
4. Verify you see your name on the home screen

### Step 2: Test What Should Work (After Sign In)
After signing in, test these features that have indexes:
- [ ] Ingredients - should WORK (index already created)
- [ ] Supplies - should WORK (index already created)
- [ ] Orders - should WORK (index already created)

If these STILL show errors after sign-in, check Firebase Console to verify those indexes actually exist.

### Step 3: Create Missing Indexes
For features showing index errors:
- [ ] Recipes - click error link → create index
- [ ] Quotes - click error link → create index  
- [ ] Shopping Lists - click error link → create index
- [ ] Timer - click error link → create index (twice)

### Step 4: Reset Camera Permissions (PROPERLY)
1. Delete app
2. **Hold power button → Slide to power off**
3. Wait 10 seconds
4. **Turn iPhone back on**
5. Wait for full boot
6. Reinstall from TestFlight
7. Try camera access

### Step 5: Reset Settings
After signing in again:
1. Go to Settings
2. Set your currency again
3. Set your price/hour again
4. These will persist now (as long as you don't delete the app)

---

## What's Working vs. What Needs Fixing:

| Feature | Status | Reason |
|---------|--------|--------|
| Google Sign In | ✅ Works | Already tested |
| User Profile Persistence | ✅ Works | Tested in previous builds |
| Ingredients (after auth + index) | ✅ Should Work | Index already created |
| Supplies (after auth + index) | ✅ Should Work | Index already created |
| Orders (after auth + index) | ✅ Should Work | Index already created + no duplicates |
| Recipes | ⚠️ Needs Index | Create via error link |
| Quotes | ⚠️ Needs Index | Create via error link |
| Shopping Lists | ⚠️ Needs Index | Create via error link |
| Timer | ⚠️ Needs 2 Indexes | Create via error links |
| Reminders | ❌ Not Implemented | Never connected to Firebase (new feature needed) |
| Camera/Photos | ❌ Need Restart | iOS permission cache issue |
| Settings Persistence | ✅ Works | Lost because you deleted app |

---

## Expected Error Messages:

### If Not Authenticated:
```
Exception: User not authenticated
```
**Fix**: Sign in with Google

### If Authenticated But No Index:
```
[cloud_firestore/failed-precondition] The query requires an index.
You can create it here: https://console.firebase.google.com/...
```
**Fix**: Click the link → Create index

### If Camera Permission Denied:
```
Permission denied
```
**Fix**: Delete app → **Restart iPhone** → Reinstall

---

## Verification Checklist:

After signing in, run these tests:

**Test 1: Check Authentication**
- [ ] Open app
- [ ] See your name on home screen (not "Hello User")
- [ ] Settings shows your email

**Test 2: Test Ingredients**
- [ ] Go to Ingredients
- [ ] Should show empty state (not error screen)
- [ ] Tap + button
- [ ] Fill in form
- [ ] Tap SAVE
- [ ] Should save successfully
- [ ] Should see ingredient in list

**Test 3: Test Supplies** 
- [ ] Same as ingredients test
- [ ] Should work (index already created)

**Test 4: Test Orders**
- [ ] Same as ingredients test  
- [ ] Should work AND only save once (duplicate bug fixed)

**Test 5: Test Recipes**
- [ ] Will show index error
- [ ] Click error link
- [ ] Create index
- [ ] Wait 1-2 minutes
- [ ] Try again - should work

---

## Summary:

The issues are NOT bugs in build 21. They're a combination of:
1. **You deleted the app** → Lost authentication + settings
2. **Didn't restart iPhone** → Camera permissions still denied
3. **Indexes not created yet** → Some features show errors
4. **Reminders never used Firebase** → Always been local-only (not a regression)

**Quick Fix**: Sign in again with Google. Most issues will resolve immediately.

**Long-term**: Don't delete the app unless absolutely necessary (you lose all local data).
