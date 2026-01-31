class GeminiConfig {
  // Gemini API Key
  // Get your free API key from: https://makersuite.google.com/app/apikey
  // 
  // HOW TO ADD YOUR API KEY:
  // Replace 'YOUR_API_KEY_HERE' with your actual Gemini API key
  // 
  // Example:
  // static const String apiKey = 'AIzaSyAbc123...';
  // 
  // SECURITY NOTE:
  // For production apps, consider using:
  // - Environment variables
  // - Flutter secure storage
  // - Backend proxy for API calls
  static const String apiKey = 'YOUR_API_KEY_HERE';
  
  // Model configuration
  static const String modelName = 'gemini-1.5-flash';
  
  // Check if API key is configured
  static bool get isConfigured => apiKey != 'YOUR_API_KEY_HERE' && apiKey.isNotEmpty;
  
  // Generation config
  static const double temperature = 0.4;
  static const int maxOutputTokens = 2048;
}
