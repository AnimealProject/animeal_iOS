##!/bin/sh

# Decrypt the files
# --batch to prevent interactive command --yes to assume "yes" for questions
gpg --quiet --batch --yes --decrypt --passphrase="$CERTIFICATE_PASSWORD" --output provisioning/AnimealDistributionCertificate.p12 provisioning/AnimealDistributionCertificate.p12.gpg
gpg --quiet --batch --yes --decrypt --passphrase="$PROVISIONING_PASSWORD" --output provisioning/AnimealDistributionProvisioning.mobileprovision provisioning/AnimealDistributionProvisioning.mobileprovision.gpg



mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles

echo "List profiles"
ls ~/Library/MobileDevice/Provisioning\ Profiles/
echo "Move profiles"
cp provisioning/*.mobileprovision ~/Library/MobileDevice/Provisioning\ Profiles/
echo "List profiles"
ls ~/Library/MobileDevice/Provisioning\ Profiles/

security create-keychain -p "" build.keychain
security import provisioning/AnimealDistributionCertificate.p12 -t agg -k ~/Library/Keychains/build.keychain -P "$UNLOCK_CERTIFICATE" -A

security list-keychains -s ~/Library/Keychains/build.keychain
security default-keychain -s ~/Library/Keychains/build.keychain
security unlock-keychain -p "" ~/Library/Keychains/build.keychain
security set-key-partition-list -S apple-tool:,apple: -s -k "" ~/Library/Keychains/build.keychain
security find-certificate ~/Library/Keychains/build.keychain
ls
