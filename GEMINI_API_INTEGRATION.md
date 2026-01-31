# FilaManager AI - Integration Guide

## 🔌 Gemini Vision API Integration

The app currently uses **simulated AI detection** for demonstration purposes. To integrate real Gemini Vision API:

### Step 1: Add Gemini API Dependency

Add to `pubspec.yaml`:
```yaml
dependencies:
  google_generative_ai: ^0.2.0  # Latest Gemini SDK
```

### Step 2: Get API Key

1. Go to [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Create a new API key
3. Store securely (use environment variables or secure storage)

### Step 3: Update `ai_service.dart`

Replace the simulated `processFilamentImage` function:

```dart
import 'package:google_generative_ai/google_generative_ai.dart';

class AIService {
  static const String _apiKey = 'YOUR_GEMINI_API_KEY'; // Use secure storage!
  
  static Future<List<Map<String, dynamic>>> processFilamentImage(
      Uint8List imageBytes) async {
    
    final model = GenerativeModel(
      model: 'gemini-1.5-pro-latest',
      apiKey: _apiKey,
    );

    final prompt = '''
    Analyze this image of 3D printer filament spool(s).
    For EACH spool visible, extract:
    1. Brand/Manufacturer name
    2. Material type (PLA, PETG, ABS, ASA, TPU, PA-CF)
    3. Sub-type (Standard, Silk, Matte, Gradient, Carbon Fiber, High Speed)
    4. Weight in grams (usually 250g, 500g, or 1000g)
    5. Color name (descriptive)
    6. Color hex code (estimate from visual)
    7. If label shows price, extract it
    8. Is it AMS compatible? (Bambu Lab spools usually are)
    
    Return JSON array format:
    [
      {
        "brand": "eSun",
        "material": "PLA",
        "subType": "Silk",
        "weight": 1000,
        "colorName": "Navy Blue",
        "colorHex": "#003366",
        "cost": 25.0,
        "amsCompatible": true
      }
    ]
    
    If multiple spools detected, return multiple objects.
    ''';

    final content = [
      Content.multi([
        TextPart(prompt),
        DataPart('image/jpeg', imageBytes),
      ])
    ];

    final response = await model.generateContent(content);
    final text = response.text ?? '[]';
    
    // Parse JSON response
    final List<dynamic> decoded = jsonDecode(text);
    
    return decoded.map((item) {
      return {
        'brand': item['brand'] ?? 'Unknown',
        'material': item['material'] ?? 'PLA',
        'subType': item['subType'] ?? 'Standard',
        'weight': item['weight'] ?? 1000,
        'colorName': item['colorName'] ?? 'Unknown',
        'colorHex': item['colorHex'] ?? '#808080',
        'quantity': 1,
        'cost': (item['cost'] ?? 25.0).toDouble(),
        'amsCompatible': item['amsCompatible'] ?? false,
        'currency': 'USD',
      };
    }).toList();
  }
}
```

### Step 4: Test with Real Images

Upload real filament spool images and verify:
- Brand recognition accuracy
- Color detection quality
- Label OCR performance
- Multi-spool separation

### Step 5: Error Handling

Add proper error handling:
```dart
try {
  final response = await model.generateContent(content);
  // ... parse response
} catch (e) {
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('AI detection failed: $e')),
    );
  }
  return []; // Return empty list on error
}
```

## 💡 Tips for Best Results

1. **Good lighting**: Take photos in well-lit conditions
2. **Clear labels**: Ensure spool labels are visible and in focus
3. **Single angle**: Photograph spools from the front/side for best label reading
4. **Multiple spools**: Separate spools slightly for better detection
5. **Clean background**: Plain background improves detection accuracy

## 🔐 Security Notes

- **Never commit API keys** to version control
- Use **environment variables** or **secure storage** packages
- Consider using **Firebase Functions** for server-side API calls
- Implement **rate limiting** to prevent API abuse
- Monitor **API usage costs** in Google Cloud Console

## 📊 Current Demo Behavior

The simulation returns varied results based on:
- Image byte length (creates hash)
- Current timestamp
- Predefined sample pool (10 different filaments)

This ensures each uploaded image shows different detection results for demo purposes.
