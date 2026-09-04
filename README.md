# Animeal iOS
### A project to help volunteers feed stray animals


## About the application
The app helps you search and locate animals that need feed feeding. A user can sign in with a mobile number / Facebook / Apple account.

## Usage
Xcode: 14+
SDK: iOS 15+
SPM: Yes
Architecture: MVVM + Flow Coordinator


## Tech Stack
1. UIKit / SwiftUI / Combine
2. Swift Package Manager
3. XCTest

## List of 3rd party SDK's
1. MapBOX
2. AWS Amplify
3. Sorcery
4. Quick and Nimble
5. CocoaLumberjackSwift
6. Firebase
7. Kingfisher


## Style guide
Raywenderlich Swift Style Guide https://github.com/raywenderlich/swift-style-guide

## Color Naming
https://colors.artyclick.com/color-name-finder/

## Steps for onboarding
1. This app uses Mabbox SDK. Please follow the steps from here. https://docs.mapbox.com/ios/maps/guides/install/
2. Configure the backend. The app talks to one of two Amplify environments: `dev` (day-to-day development and QA) and `test` (used by real beta testers — never create test data there). Per-environment configs live in `amplify_configs/<env>/amplifyconfiguration.json`; the folder is gitignored because the repository is public.
   - With AWS access (ask a maintainer for IAM credentials — never paste them into docs or chats):
     ```bash
     ./update_amplify.sh -a <AWS_ACCESS_KEY_ID> -s <AWS_SECRET_ACCESS_KEY> -i <AMPLIFY_APP_ID> -t <FACEBOOK_APP_ID> -r <FACEBOOK_APP_SECRET> -e dev
     ./update_amplify.sh -a <AWS_ACCESS_KEY_ID> -s <AWS_SECRET_ACCESS_KEY> -i <AMPLIFY_APP_ID> -t <FACEBOOK_APP_ID> -r <FACEBOOK_APP_SECRET> -e test
     ```
     Each run pulls the config for that environment into `amplify_configs/<env>/` and selects it. If the script fails on first onboarding, run `./recover_from_error.sh` and retry.
   - Without AWS access: get `amplifyconfiguration.json` for `dev` and `test` from a teammate and put them into `amplify_configs/dev/` and `amplify_configs/test/`.
3. Pick the environment for Debug/QA builds (Release always uses `test`):
   ```bash
   ./Tools/select_env.sh dev     # or test
   ```
   The QA build can also switch between them at runtime (More → QA Menu → Environment).

## Generate the string file

We needed to convert the certificate and provisioning profile to base 64 string format so that it can be used in the github actions secrets. Hence we used the following commands to convert the files to base 64 format.

openssl base64 -in dev-certificates.p12 -A | tr -d '\n' > dev-certificates_base64.txt
openssl base64 -in Animeal_Development_latest.mobileprovision -A | tr -d '\n' > Animeal_Development_latest_base64.txt
