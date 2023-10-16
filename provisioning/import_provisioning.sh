##!/bin/sh

# Decrypt the files
# --batch to prevent interactive command --yes to assume "yes" for questions
gpg --quiet --batch --yes --decrypt --passphrase="$UNLOCK_CERTIFICATE" --output provisioning/AnimealDevelopmentCertificate.p12 provisioning/AnimealDevelopmentCertificate.p12.gpg
gpg --quiet --batch --yes --decrypt --passphrase="$UNLOCK_CERTIFICATE" --output provisioning/AnimealDevelopmentProvisioning.mobileprovision provisioning/AnimealDevelopmentProvisioning.mobileprovision.gpg



mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles

echo "List profiles"
ls ~/Library/MobileDevice/Provisioning\ Profiles/
echo "Move profiles"
cp provisioning/*.mobileprovision ~/Library/MobileDevice/Provisioning\ Profiles/
echo "List profiles"
ls ~/Library/MobileDevice/Provisioning\ Profiles/

security create-keychain -p "" build.keychain
security import provisioning/AnimealDevelopmentCertificate.p12 -t agg -k ~/Library/Keychains/build.keychain -P "$UNLOCK_CERTIFICATE" -A

security list-keychains -s ~/Library/Keychains/build.keychain
security default-keychain -s ~/Library/Keychains/build.keychain
security unlock-keychain -p "" ~/Library/Keychains/build.keychain
security set-key-partition-list -S apple-tool:,apple: -s -k "" ~/Library/Keychains/build.keychain
