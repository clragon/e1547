if [ $(basename $PWD) = "ios" ]; then 
    cd ..; 
fi 
ROOT=$PWD
echo "Building with flutter"
flutter build ios
cd build/ios/iphoneos
# Remove this next segment if we ever upload to the App Store
echo "Fixing IPA Size"
xcrun bitcode_strip -r Runner.app/Frameworks/Flutter.framework/Flutter -o Runner.app/Frameworks/Flutter.framework/FlutterStrip && mv Runner.app/Frameworks/Flutter.framework/FlutterStrip Runner.app/Frameworks/Flutter.framework/Flutter
echo "Removed bitcode from Flutter.framework"
echo "Signing..."
codesign -s "Apple Distribution: Kritanta Development LLC (5K985WUQXA)" Runner.app -f
echo "Fixing executable bit"
chmod +x Runner.app/Runner
echo "Creating archive..."
rm -rf Payload/*
mkdir Payload
mv Runner.app Payload/Runner.app
zip -9 -r e1547.zip Payload
mv e1547.zip e1547.ipa
echo "Done!"
open $PWD

cd $ROOT/ios
