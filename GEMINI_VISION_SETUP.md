# 🤖 Gemini Vision AI Integration - Complete Guide

**FilaManager AI v2.0.0** now supports **real AI-powered filament detection** using Google's Gemini Vision API!

---

## ✨ What's New in v2.0.0

### **Real AI Detection Features:**
- 🎯 **Automatic brand recognition** from packaging
- 🎨 **Color detection** with hex code generation
- 📝 **OCR label reading** for material type
- ⚖️ **Weight detection** from visible text
- 🏷️ **Sub-type identification** (Silk, Matte, etc.)
- 🔍 **Multi-spool detection** in single image
- ✅ **AMS compatibility** detection

---

## 🚀 Quick Setup (5 Minutes)

### **Step 1: Get FREE Gemini API Key**

1. Visit: **https://makersuite.google.com/app/apikey**
2. Sign in with your Google account
3. Click **"Get API Key"** or **"Create API Key"**
4. Copy the generated key (starts with `AIzaSy...`)

**💡 Free Tier Limits:**
- ✅ 60 requests per minute
- ✅ 1,500 requests per day
- ✅ **Perfect for personal use!**

---

### **Step 2: Add API Key to App**

**Option A: Edit in IDE/Editor**
```dart
// File: lib/config/gemini_config.dart
// Line 17:

class GeminiConfig {
  // Replace YOUR_API_KEY_HERE with your actual key:
  static const String apiKey = 'AIzaSyAbc123...your-key-here...';
  
  // ... rest of file
}
```

**Option B: In-App Setup Guide**
1. Open FilaManager AI
2. Tap **Profile icon** (top right)
3. Select **"AI Setup"**
4. Follow the instructions
5. Edit the file as shown

---

### **Step 3: Rebuild the App**

**For Development (Web Preview):**
```bash
cd /home/user/flutter_app
flutter clean
flutter pub get
flutter build web --release
```

**For Android (APK):**
```bash
cd /home/user/flutter_app
flutter clean
flutter pub get
flutter build apk --release
```

---

## 📱 How to Use AI Detection

### **Method 1: Take Photo**
1. Open FilaManager AI
2. Tap the **orange camera FAB** (center bottom)
3. Tap **"Take Photo"**
4. Point camera at filament spool(s)
5. Take picture
6. **AI will analyze automatically!**
7. Review detected information
8. Edit if needed
9. Tap **"Save All"**

### **Method 2: Choose from Gallery**
1. Tap the orange camera FAB
2. Tap **"Choose from Gallery"**
3. Select image with filament spool(s)
4. AI analyzes the image
5. Review and save

---

## 🎯 What AI Detects

### **Automatic Detection:**
```
✅ Brand Name        → eSun, Bambu Lab, Polymaker, etc.
✅ Material Type     → PLA, PETG, ABS, ASA, TPU, PA-CF
✅ Sub-Type          → Silk, Matte, Standard, Gradient
✅ Color Name        → "Navy Blue", "Matte Black"
✅ Color Hex         → #003366, #000000
✅ Weight            → 1000g, 750g, 500g, 250g
✅ AMS Compatible    → true/false
```

### **Example Detection Output:**
```json
{
  "brand": "eSun",
  "material": "PLA",
  "subType": "Silk",
  "weight": 1000,
  "colorName": "Navy Blue",
  "colorHex": "#003366",
  "amsCompatible": true
}
```

---

## 🔄 Demo Mode vs AI Mode

### **Demo Mode (No API Key):**
- ⚠️ Uses sample data variations
- ⚠️ Orange indicator in camera screen
- ⚠️ Menu shows "Demo Mode"
- ✅ All features work
- ✅ Edit everything manually
- ✅ Good for testing

### **AI Mode (With API Key):**
- ✅ Real image analysis
- ✅ Green indicator in camera screen
- ✅ Menu shows "Active"
- ✅ Automatic detection
- ✅ More accurate results
- ✅ OCR label reading

---

## 🎨 AI Status Indicators

### **In Camera Screen:**
```
🟢 Green Badge + ✓  → AI Active (Gemini configured)
🟠 Orange Badge + ⓘ → Demo Mode (tap to setup)
```

### **In Profile Menu:**
```
AI Setup
├─ 🟢 Active      → Using Gemini Vision API
└─ 🟠 Demo Mode   → Using sample data
```

---

## 💡 Tips for Best Results

### **Photography Tips:**
1. ✅ **Good lighting** - Natural or bright indoor
2. ✅ **Clear view** - Show the label clearly
3. ✅ **Close-up** - Fill frame with spool
4. ✅ **Steady shot** - Avoid blur
5. ✅ **Multiple angles** - Try different views if needed

### **What to Show:**
- 📦 **Main label** with brand/material
- 🎨 **Color** of the filament
- ⚖️ **Weight** marking (if visible)
- 🏷️ **Sub-type** info (Silk, Matte, etc.)

### **Multi-Spool Detection:**
- 📸 Can detect **multiple spools** in one image
- ✅ Each spool analyzed separately
- ✅ Review and edit each detection
- ✅ Save all at once

---

## 🔧 Troubleshooting

### **"API Key Not Working"**
**Solution:**
1. Check key is correct (starts with `AIzaSy`)
2. No extra spaces or quotes
3. Rebuild app after editing
4. Check API key is active in Google AI Studio

### **"Detection Not Accurate"**
**Solutions:**
1. ✅ Take clearer photo
2. ✅ Better lighting
3. ✅ Show label clearly
4. ✅ Edit results manually
5. ✅ Try different angle

### **"Still Shows Demo Mode"**
**Solutions:**
1. Confirm API key is saved in file
2. Rebuild the app completely:
   ```bash
   flutter clean
   flutter pub get
   flutter build apk --release
   ```
3. Reinstall the APK

---

## 📊 API Usage & Costs

### **Free Tier:**
```
✅ 60 requests/minute
✅ 1,500 requests/day
✅ No credit card required
✅ Perfect for personal use
```

### **Estimated Usage:**
```
📸 1 photo = 1 API call
🔢 10 scans/day = ~300/month
💰 Cost: FREE (within limits)
```

### **If You Exceed Free Tier:**
- Automatically falls back to Demo Mode
- Manual entry still works
- Consider Google Cloud paid plan
- Or wait for daily reset

---

## 🔐 Security Best Practices

### **For Personal Use:**
✅ API key in code is fine
✅ App is private (not published)
✅ Key only works from your project

### **For Production/Distribution:**
🔒 Use environment variables
🔒 Backend proxy for API calls
🔒 Flutter secure storage
🔒 Never commit keys to public repos

---

## 📱 In-App Setup Access

### **How to Access Setup Screen:**

**Method 1: Profile Menu**
1. Tap **Profile icon** (top right)
2. Select **"AI Setup"**

**Method 2: Camera Screen**
1. Tap **Camera FAB** (orange)
2. Tap **AI badge** (top right)

---

## ✅ Setup Verification

### **Check If Working:**
1. Open app
2. Profile menu shows **"Active"** (green)
3. Camera screen has **green badge**
4. Take a test photo
5. See real detection results!

### **Status Indicators:**
```
✅ Green badge     = AI Active
✅ "Active" text   = Gemini configured
✅ Real results    = Working perfectly
```

---

## 🎉 You're Ready!

**Your FilaManager AI now has:**
- ✅ Real AI-powered detection
- ✅ Automatic label reading
- ✅ Color and brand recognition
- ✅ Multi-spool detection
- ✅ Professional OCR
- ✅ Smart inventory management

**Start scanning your filaments with real AI!** 🚀

---

## 🆘 Need Help?

**Issues?**
1. Check this guide thoroughly
2. Verify API key is correct
3. Rebuild app after changes
4. Try demo mode first
5. Check Google AI Studio for API status

**Questions?**
- API Limits: https://ai.google.dev/pricing
- Gemini Docs: https://ai.google.dev/docs
- Get API Key: https://makersuite.google.com/app/apikey

---

**FilaManager AI v2.0.0 - Powered by Gemini Vision** 🤖✨
