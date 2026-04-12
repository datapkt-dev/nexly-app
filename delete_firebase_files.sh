#!/bin/bash
# Run this script to delete all Firebase configuration files
rm -f lib/firebase_options.dart
rm -f firebase.json
rm -f firebase.json.bak
rm -f ios/Runner/GoogleService-Info.plist
rm -f android/app/google-services.json
echo "All Firebase configuration files have been removed."
echo "You can now delete this script: rm delete_firebase_files.sh"
