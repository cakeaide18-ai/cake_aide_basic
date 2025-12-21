# Profile Picture Upload - Camera Permissions Fix

## Issue Summary
User reports: "It's still not letting me add a profile picture."

## Root Cause
iOS has cached a "denied" permission state for Camera and Photo Library access. The permissions ARE correctly configured in `Info.plist`, but iOS won't show the permission dialog again because it remembers the previous denial.

## How Profile Picture Upload Works
1. Go to Settings screen
2. Tap anywhere on the profile card (the whole colored box with your name/email/business)
3. This opens the Profile Editor screen
4. Tap the camera icon on the profile picture
5. Choose "Camera" or "Photo Library"
6. iOS should show permission dialog (if permissions not granted yet)
7. Allow permission
8. Take photo or select from library
9. Save profile

## Why It's Not Working
iOS permission state is stuck on "denied" from a previous attempt. The app DOES have the correct permissions in Info.plist:

```xml
<key>NSCameraUsageDescription</key>
<string>CakeAide needs camera access to take photos of your cakes, ingredients, and profile picture.</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>CakeAide needs photo library access to select images for your cakes, ingredients, and profile picture.</string>
```

But iOS won't ask again unless you reset the permission state.

## Solution: Reset iOS Permission State

### Step 1: Delete the App
1. On your iPhone, find the CakeAide Pro app icon
2. Long-press the app icon
3. Tap "Remove App"
4. Tap "Delete App" (not "Remove from Home Screen")
5. Confirm deletion

###Step 2: Restart iPhone
1. Press and hold the Side button and Volume Down button
2. Slide to power off
3. Wait 10 seconds
4. Press and hold the Side button to turn iPhone back on
5. Wait for iPhone to fully boot up

### Step 3: Reinstall from TestFlight
1. Open the TestFlight app
2. Find CakeAide Pro
3. Tap "Install"
4. Wait for installation to complete
5. Open CakeAide Pro

### Step 4: Test Profile Picture Upload
1. Sign in with Google (or Apple)
2. Go to Settings tab
3. Tap on the profile card (the colored box)
4. Tap the camera icon on profile picture
5. Select "Photo Library"
6. **iOS SHOULD NOW SHOW**: "CakeAide would like to access your photos"
7. Tap "Allow Access to All Photos" or "Select Photos"
8. Select an image
9. Save profile
10. Go back to Settings - profile picture should now show

### Alternative: Test with Camera
1. After reinstall, go to Settings → Profile Editor
2. Tap camera icon
3. Select "Camera"
4. **iOS SHOULD NOW SHOW**: "CakeAide would like to access your camera"
5. Tap "OK"
6. Take a photo
7. Save profile

## Why This Works
- Deleting the app clears iOS's cached permission states
- Restarting ensures all caches are cleared
- Fresh install = fresh permission request
- iOS will show the permission dialog as if it's the first time

## Verification in iOS Settings
After granting permissions, you can verify in iOS Settings:
1. Open iPhone Settings app
2. Scroll down to "CakeAide Pro"
3. Check "Photos" permission - should show "All Photos" or "Selected Photos"
4. Check "Camera" permission - should show toggle ON

## Important Notes
- This is NOT a bug in the app code
- The app correctly requests permissions
- This is an iOS behavior - permissions are "sticky" once denied
- This is a one-time fix - once permissions are granted, they persist
- You won't need to do this again unless you explicitly deny permissions in iOS Settings

## If It Still Doesn't Work After Reinstall
1. Check iOS Settings → CakeAide Pro → Photos → should allow access
2. Check iOS Settings → CakeAide Pro → Camera → should be toggled ON
3. If permissions are ON but still not working:
   - Take a screenshot of the error message
   - Check Xcode console for permission-related errors
   - Verify Info.plist entries are correct (they are)

## Technical Background
The profile picture feature uses:
- `image_picker` Flutter package
- `permission_handler` Flutter package  
- Native iOS ImagePicker API
- Stores images locally in SharedPreferences + app documents directory
- Future: Will upload to Firebase Storage (not yet implemented)
