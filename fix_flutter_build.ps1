Write-Host "==== Fix Flutter Build Script Started ===="

Write-Host "Stopping Gradle daemons..."
.\gradlew --stop

Write-Host "Clearing Flutter cache..."
flutter clean

Write-Host "Deleting build and cache..."
Remove-Item -Recurse -Force .\build, .\.dart_tool, .\pubspec.lock, .\android\.gradle

Write-Host "Running flutter pub get..."
flutter pub get

Write-Host "Running flutter build apk..."
flutter build apk

Write-Host "==== Fix Flutter Build Script Finished ===="

