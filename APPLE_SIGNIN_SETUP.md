# Apple Sign In Configuration Checklist for CakeAide Pro

This document provides step-by-step instructions to fix the `[firebase_auth/invalid-credential]` error for Apple Sign In.

## Project Information
- **App Name**: CakeAide Pro
- **Bundle ID**: `com.cakeaide.cakeaideapp2`
- **Firebase Project ID**: `dlgrijpah7jlvfjuexnmcmv4p0rmbc`
- **Firebase Auth Domain**: `dlgrijpah7jlvfjuexnmcmv4p0rmbc.firebaseapp.com`

---

## ✅ Step 1: Verify Apple Developer Console Setup

### 1.1 App ID Configuration
**URL**: https://developer.apple.com/account/resources/identifiers/list

- [ ] Find your App ID: `com.cakeaide.cakeaideapp2`
- [ ] Verify "Sign In with Apple" capability is **ENABLED**
- [ ] Click **Edit** on the App ID
- [ ] Ensure "Sign In with Apple" is checked
- [ ] Click **Save** if you made any changes

### 1.2 Services ID Configuration (CRITICAL)
**URL**: https://developer.apple.com/account/resources/identifiers/list/serviceId

**Option A: If Services ID exists**
- [ ] Find your Services ID (usually something like `com.cakeaide.cakeaideapp2.signin`)
- [ ] Click on it to edit

**Option B: If Services ID doesn't exist**
- [ ] Click the **+** button to create a new identifier
- [ ] Select **Services IDs** and click **Continue**
- [ ] Fill in:
  - **Description**: CakeAide Pro Sign In (or any name you want)
  - **Identifier**: `com.cakeaide.cakeaideapp2.signin`
- [ ] Click **Continue** then **Register**

**For both options, configure the Services ID:**
- [ ] Check the box for **Sign In with Apple**
- [ ] Click **Configure** next to "Sign In with Apple"
- [ ] In the configuration dialog:
  - **Primary App ID**: Select `com.cakeaide.cakeaideapp2`
  - **Domains and Subdomains**: Add these (click + to add each):
    - `dlgrijpah7jlvfjuexnmcmv4p0rmbc.firebaseapp.com`
    - (Add any other domains you use for web/preview)
  - **Return URLs**: Add this exact URL (click + to add):
    - `https://dlgrijpah7jlvfjuexnmcmv4p0rmbc.firebaseapp.com/__/auth/handler`
- [ ] Click **Done**
- [ ] Click **Save** (top right)

**IMPORTANT**: Write down your Services ID here: `_______________________________`

---

## ✅ Step 2: Configure Firebase Console

### 2.1 Enable Apple Sign In Provider
**URL**: https://console.firebase.google.com/project/dlgrijpah7jlvfjuexnmcmv4p0rmbc/authentication/providers

- [ ] Click on **Apple** in the providers list
- [ ] Verify it shows as **Enabled**
- [ ] If not enabled:
  - [ ] Click **Enable** toggle at the top
  - [ ] Click **Save**

### 2.2 (Optional) Configure OAuth Code Flow
**Still on the Apple provider page:**

If you want to use the Services ID for additional functionality:
- [ ] Expand **OAuth code flow configuration (optional)**
- [ ] Add your Services ID from Step 1.2: `com.cakeaide.cakeaideapp2.signin`
- [ ] Click **Save**

**Note**: For native iOS apps, this section is optional. The main requirement is that Apple provider is enabled.

### 2.3 Verify Authorized Domains
**URL**: https://console.firebase.google.com/project/dlgrijpah7jlvfjuexnmcmv4p0rmbc/authentication/settings

- [ ] Scroll to **Authorized domains** section
- [ ] Verify these domains are listed:
  - [ ] `localhost` (for local development)
  - [ ] `dlgrijpah7jlvfjuexnmcmv4p0rmbc.firebaseapp.com`
  - [ ] `dlgrijpah7jlvfjuexnmcmv4p0rmbc.web.app` (if it exists)
- [ ] If testing with DreamFlow or preview domains, add:
  - [ ] Your preview domain: `_______________________________`
  - [ ] Click **Add domain** to add each one

---

## ✅ Step 3: Verify Xcode Project Settings

### 3.1 Check Signing & Capabilities
- [ ] Open `ios/Runner.xcworkspace` in Xcode
- [ ] Select the **Runner** target
- [ ] Go to **Signing & Capabilities** tab
- [ ] Verify **Sign in with Apple** capability is present
- [ ] Verify your **Team** is selected
- [ ] Verify **Bundle Identifier** is `com.cakeaide.cakeaideapp2`

### 3.2 Verify Entitlements File
File: `ios/Runner/Runner.entitlements`

Should contain:
```xml
<key>com.apple.developer.applesignin</key>
<array>
    <string>Default</string>
</array>
```

- [ ] Confirmed ✓

---

## ✅ Step 4: Test the Configuration

### 4.1 Clean Build
```bash
cd /Users/bolajieyo/Documents/cake_aide_basic
flutter clean
flutter pub get
cd ios
pod install
cd ..
```

### 4.2 Build and Run on Physical Device
```bash
flutter run -d 00008120-001A282E3EE0A01E
```

### 4.3 Test Apple Sign In
- [ ] Open the app on your physical device
- [ ] Tap "Sign in with Apple"
- [ ] Complete Apple authentication
- [ ] Verify you're signed in successfully

---

## 🔍 Troubleshooting

### If you still get `[firebase_auth/invalid-credential]`:

1. **Double-check Return URL** (Most common issue)
   - In Apple Developer Console, Services ID configuration
   - Return URL MUST be exactly: `https://dlgrijpah7jlvfjuexnmcmv4p0rmbc.firebaseapp.com/__/auth/handler`
   - No trailing slash
   - Must use HTTPS (not HTTP)

2. **Verify Services ID matches**
   - If you configured OAuth code flow in Firebase, the Services ID must match exactly

3. **Check Apple Developer Account Status**
   - Ensure your Apple Developer account is active
   - Ensure your app's provisioning profile is valid

4. **Wait for propagation**
   - Changes in Apple Developer Console can take 5-15 minutes to propagate
   - Try waiting a bit after making changes

5. **Check Firebase project**
   - Ensure you're editing the correct Firebase project
   - Project ID should be: `dlgrijpah7jlvfjuexnmcmv4p0rmbc`

6. **Verify iOS app is registered in Firebase**
   - Go to: https://console.firebase.google.com/project/dlgrijpah7jlvfjuexnmcmv4p0rmbc/settings/general
   - Verify iOS app with Bundle ID `com.cakeaide.cakeaideapp2` exists
   - Verify `GoogleService-Info.plist` is downloaded and in your project

---

## 📝 Common Mistakes to Avoid

❌ **Don't** use the App ID as the Services ID - they must be different  
❌ **Don't** forget the `/__/auth/handler` path in the Return URL  
❌ **Don't** use HTTP instead of HTTPS in Return URL  
❌ **Don't** add a trailing slash to the Return URL  
❌ **Don't** forget to click "Save" after making changes in Apple Developer Console  
❌ **Don't** test on simulator - Apple Sign In requires a physical device  

✅ **Do** use a separate Services ID (e.g., `com.cakeaide.cakeaideapp2.signin`)  
✅ **Do** use the exact Firebase project domain in Return URL  
✅ **Do** test on a physical iOS device  
✅ **Do** wait a few minutes after making changes before testing  
✅ **Do** check that both Firebase and Apple Developer Console are updated  

---

## 🎯 Quick Reference URLs

| Service | Purpose | URL |
|---------|---------|-----|
| Firebase Console | Main dashboard | https://console.firebase.google.com/project/dlgrijpah7jlvfjuexnmcmv4p0rmbc |
| Firebase Auth Providers | Enable/configure Apple Sign In | https://console.firebase.google.com/project/dlgrijpah7jlvfjuexnmcmv4p0rmbc/authentication/providers |
| Firebase Authorized Domains | Add allowed domains | https://console.firebase.google.com/project/dlgrijpah7jlvfjuexnmcmv4p0rmbc/authentication/settings |
| Apple Developer Identifiers | Manage App IDs | https://developer.apple.com/account/resources/identifiers/list |
| Apple Developer Services IDs | Configure Sign in with Apple | https://developer.apple.com/account/resources/identifiers/list/serviceId |
| Apple Developer Certificates | Manage certificates | https://developer.apple.com/account/resources/certificates/list |

---

## 📱 After Successful Configuration

Once Apple Sign In is working:
- [ ] Test sign in on multiple devices
- [ ] Test sign out and sign back in
- [ ] Verify user data persists after sign in
- [ ] Test with different Apple IDs
- [ ] Build new TestFlight version (already prepared as build 18)

---

## 💡 Need Help?

If you're still having issues after following this checklist:

1. Check the Xcode console logs when attempting sign in
2. Look for any Firebase error messages
3. Verify your internet connection
4. Ensure you're using the latest version of the app
5. Try deleting and reinstalling the app

**Current Build**: Version 1.0.1 (Build 18)  
**Last Updated**: December 17, 2025
