set -eo pipefail

## Build release version and zip up binaries
rm -rf build

xcodebuild \
  -scheme Production \
  CONFIGURATION_BUILD_DIR=build

zip -r \
  build/BlackboxSDK.zip \
  build/BlackboxSDK.framework

## Tag a github release and upload the built binaries
hub release create \
  -a build/BlackboxSDK.zip \
  $(cat version)

# Deploy to CocoaPods
pod trunk push BlackboxSDK.podspec
