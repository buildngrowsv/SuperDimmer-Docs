# Next Action

**Priority:** HIGH
**Status:** READY (requires Apple credentials)
**Action:** Re-run `packaging/release.sh 1.0.8` with Apple notarization credentials set:

```bash
export APPLE_ID="your@appleid.com"
export APPLE_APP_PASSWORD="app-specific-password"
export APPLE_TEAM_ID="HHHHZ6UV26"
cd Github/SuperDimmer/SuperDimmer-Website/packaging
./release.sh 1.0.8   # (no --skip-sign this time)
```

This will produce a signed + notarized + stapled DMG, overwriting the current unsigned artifact at `SuperDimmer-Website/releases/SuperDimmer-v1.0.8.dmg`.

**Then:** regenerate the Sparkle EdDSA signature and replace the `REPLACE_WITH_ACTUAL_SIGNATURE_FROM_SIGN_UPDATE_TOOL==` placeholder in `SuperDimmer-Website/sparkle/appcast.xml` for the v1.0.8 item:

```bash
cd Github/SuperDimmer/SuperDimmer-Website
./path-to-sparkle/sign_update releases/SuperDimmer-v1.0.8.dmg
# copy the output sparkle:edSignature="..." into appcast.xml
```

**Finally:** `git add . && git commit && git push` on the Website repo — Cloudflare Pages auto-deploys and Sparkle will see the update within minutes of users' next check.

**Blocker:** None (all three repos are already synced and pushed with the v1.0.8 code + artifacts; only the signing step requires your local Apple credentials).
**Agent-Executable:** PARTIALLY — signing must be done on your machine with your certificate + credentials; everything else (code, artifacts, website, Sparkle appcast, release notes) is already committed.
