#!/bin/bash
# Flutter Split-ABI build command for Memory/Storage Optimization
# 
# CRITICAL: By splitting ABIs (Application Binary Interfaces), the Google Play Store
# serves a targeted APK that only contains the native C++ code for the specific device 
# (e.g., arm64-v8a). This keeps the download size under 15MB, heavily reducing storage
# and memory overhead on 4GB RAM phones.

cd Wallet-Flutter
flutter build apk --split-per-abi --obfuscate --split-debug-info=./debug-info
