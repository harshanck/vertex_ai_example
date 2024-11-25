# Flutter Vertex AI Example

This is a simple example code that demonstrate how use Vertex AI with function calls in Flutter.

**Useful Links:**
- [Vertex AI - Flutter Plugin](https://pub.dev/packages/firebase_vertexai)
- [Firebase Documentation](https://firebase.google.com/docs/vertex-ai/get-started?platform=flutter)

### Running the example

1. Clone the repository
```
git clone <repo_url>
```
2. Make sure required APIs are enabled in [Google Cloud](https://cloud.google.com/vertex-ai?hl=en) and Add Firebase to project
```
flutterfire configure
```
3. Obtain [OpenWeather](https://home.openweathermap.org/api_keys) api key. Then create new dart class called "api_keys.dart" under lib and add below line
```
const String openWeatherApiKey = 'YOUR API KEY';
```
4. Run
```
flutter run
```
