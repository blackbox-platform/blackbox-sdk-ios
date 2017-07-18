set -eo pipefail

check_master() {
  branch=$(git rev-parse --abbrev-ref HEAD)

  if [[ "$branch" != "master" ]]; then
    echo 'fatal: build.sh must be run from master'
    exit 1
  fi
}

check_clean() {
  clean=$(git status --porcelain)

  if [[ -n "$clean" ]]; then
    echo 'fatal: build.sh must be run with clean working directory'
    exit 1;
  fi
}

run_tests() {
  xcodebuild -scheme Production test
}

build_release() {
  ## Build release versions
  rm -rf build

  xcodebuild -target BlackboxSDK -configuration Release -arch arm64 -arch armv7 -arch armv7s only_active_arch=no defines_module=yes -sdk "iphoneos"
  CONFIGURATION_BUILD_DIR=build
  xcodebuild -target BlackboxSDK -configuration Release -arch x86_64 -arch i386 only_active_arch=no defines_module=yes -sdk "iphonesimulator" CONFIGURATION_BUILD_DIR=build

  # Merge device/simulatior binaries and create package
  mkdir -p build/BlackboxSDK
  cp -r build/BlackboxSDK.framework build/BlackboxSDK
  cp LICENSE README.md build/BlackboxSDK

  lipo -create \
    -output build/BlackboxSDK/BlackboxSDK.framework/BlackboxSDK \
    build/Release-iphoneos/BlackboxSDK.framework/BlackboxSDK \
    build/BlackboxSDK.framework/BlackboxSDK
}

publish_github_release() {
  ## Zip up the package and tag a new version
  cd build

  zip -r \
    BlackboxSDK.zip \
    BlackboxSDK

  cd -

  hub release create \
    -a build/BlackboxSDK.zip \
    $(cat version)
}

publish_cocoapods_release() {
  pod trunk push BlackboxSDK.podspec
}

## Prepare
check_clean
check_master
run_tests
git push origin master

# Deploy
build_release
publish_github_release
publish_cocoapods_release
