# FI-YOU Android Release Signing

FI-YOU Android package id is `com.fiyou.app`.

Release builds must not use the debug signing key. The Flutter app expects a local
`mobile/fi_you/android/key.properties` file or equivalent CI-injected values.

## Local File

Create `mobile/fi_you/android/key.properties` from:

```text
mobile/fi_you/android/key.properties.example
```

Required keys:

```properties
storeFile=/absolute/path/to/release-keystore.jks
storePassword=...
keyAlias=...
keyPassword=...
```

Do not commit `key.properties`, keystore files, or passwords.

## Expected Failure Without Secrets

When the signing file is absent, this command should fail with a clear Gradle
message instead of falling back to debug signing:

```powershell
C:\Users\frog8\development\flutter\bin\flutter.bat build appbundle --release
```

Expected message:

```text
FI-YOU release signing is not configured. Create android/key.properties from android/key.properties.example or inject the same values in CI. Do not commit keystore files or passwords.
```

## Release Check

Before Play Console upload:

1. Confirm `applicationId` is `com.fiyou.app`.
2. Create or inject release signing values outside git.
3. Run `flutter build appbundle --release`.
4. Archive the generated `.aab` and signing provenance in the release checklist.
