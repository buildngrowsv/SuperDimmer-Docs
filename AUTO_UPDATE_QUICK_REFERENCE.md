# SuperDimmer Auto-Update: Quick Reference

## 🚦 CURRENT STATUS

```
┌─────────────────────────────────────────────────────────────┐
│                    WHAT'S READY                              │
├─────────────────────────────────────────────────────────────┤
│ ✅ Cloudflare Pages hosting (auto-deploys from GitHub)      │
│ ✅ version.json file exists                                  │
│ ✅ appcast.xml file exists (needs real signatures)           │
│ ✅ DMG files in releases/ folder                             │
│ ✅ Release scripts for building DMG                          │
│ ✅ Domain: superdimmer.app (assuming it's configured)        │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                    WHAT'S MISSING                            │
├─────────────────────────────────────────────────────────────┤
│ ❌ No UpdateChecker.swift in the app                        │
│ ❌ No Sparkle framework integrated                          │
│ ❌ No EdDSA keys generated                                  │
│ ❌ No "Check for Updates" menu item                         │
│ ❌ No update checking on app launch                         │
└─────────────────────────────────────────────────────────────┘
```

---

## 🎯 DECISION: Which Approach?

### Option A: Simple JSON (1-2 hours) ⭐ RECOMMENDED FIRST

```
App checks version.json → Shows alert → User clicks Download → 
Opens browser → User installs DMG manually
```

**Best for:** Getting updates working quickly, initial releases

### Option B: Sparkle Framework (4-6 hours)

```
App checks appcast.xml → Downloads DMG → Verifies signature → 
Installs automatically → Relaunches app
```

**Best for:** Professional polish, after you have users to update

---

## 📋 IMPLEMENTATION CHECKLIST

### Simple JSON Approach (Start Here)

- [ ] Create `UpdateChecker.swift` (see main document)
- [ ] Add to app launch in `SuperDimmerApp.swift`
- [ ] Add menu item in `MenuBarController.swift`
- [ ] Test with current version
- [ ] Test by changing version.json to "2.0.0"
- [ ] Document release process

**Time: 1-2 hours**

### Sparkle Approach (Later)

- [ ] Add Sparkle via Swift Package Manager
- [ ] Generate EdDSA keys with `generate_keys`
- [ ] Backup private key securely
- [ ] Update Info.plist with `SUFeedURL` and `SUPublicEDKey`
- [ ] Create `UpdateManager.swift`
- [ ] Sign all DMGs with `sign_update` tool
- [ ] Update appcast.xml with real signatures
- [ ] Test full auto-update flow

**Time: 4-6 hours + ongoing DMG signing**

---

## 🚀 RELEASING UPDATES

### How to Release New Version (After Update Code is Added)

```bash
# 1. Build and notarize app (your existing process)
cd /Users/ak/UserRoot/Github/SuperDimmer/SuperDimmer-Mac-App
./packaging/build-release.sh

# 2. Copy DMG to website
cp packaging/output/SuperDimmer-v1.0.1.dmg \
   /Users/ak/UserRoot/Github/SuperDimmer/SuperDimmer-Website/releases/

# 3. Update version.json
cd /Users/ak/UserRoot/Github/SuperDimmer/SuperDimmer-Website
cat > version.json << 'EOF'
{
  "version": "1.0.1",
  "build": 7,
  "downloadURL": "https://superdimmer.app/releases/SuperDimmer-v1.0.1.dmg",
  "releaseNotesURL": "https://superdimmer.app/release-notes/v1.0.1.html",
  "minSystemVersion": "13.0",
  "releaseDate": "2026-01-19"
}
EOF

# 4. Commit and push
git add .
git commit -m "Release v1.0.1"
git push

# 5. Wait 60 seconds for Cloudflare to deploy
# Done! Users will see update on next check ✅
```

---

## 🔐 SECURITY & HOSTING

### Is It Secure?

**Simple JSON:**
- ✅ HTTPS from Cloudflare (encrypted download)
- ✅ Apple Notarization (Gatekeeper validates DMG)
- ✅ Trusted source (your GitHub → Cloudflare)
- ⚠️ No additional signature verification

**Sparkle:**
- ✅ Everything from Simple JSON, PLUS
- ✅ EdDSA cryptographic signature verification
- ✅ Can't install tampered updates even if server hacked

### How Hosting Works

```
Your Mac
   ↓ (git push)
GitHub (SuperDimmer-Website repo)
   ↓ (auto-deploy)
Cloudflare Pages
   ↓ (HTTPS)
https://superdimmer.app/
   ├── version.json
   ├── sparkle/appcast.xml
   └── releases/SuperDimmer-v1.0.1.dmg
```

**No manual uploads needed!** Just `git push` and Cloudflare handles the rest.

### Same DMG for Everything?

**YES!** One DMG works for:
- ✅ Initial download from website
- ✅ Simple JSON update downloads
- ✅ Sparkle automatic updates

It's just a disk image with your `.app` inside. Doesn't matter how it's downloaded.

---

## 📞 QUICK ANSWERS

**Q: Can I use the DMG I already created?**  
A: Yes! No special format needed. Same DMG for install and updates.

**Q: Do I need to upload to a special server?**  
A: No! Just commit to GitHub, Cloudflare auto-deploys.

**Q: What if I want to test updates?**  
A: Change version.json to a higher version number, push to GitHub, wait 60 seconds, then check for updates in the app.

**Q: Can I migrate from Simple JSON to Sparkle later?**  
A: Yes! They can even coexist. Many apps start simple, add Sparkle later.

**Q: What about beta/pre-release updates?**  
A: Sparkle supports channels. Simple JSON doesn't (but you could add a `beta.json` file).

---

## 📚 FULL DOCUMENTATION

See `AUTO_UPDATE_STATUS_AND_SETUP.md` for:
- Complete UpdateChecker.swift code
- Detailed Sparkle setup guide
- Security considerations
- Reference to existing documentation

---

## 🎬 RECOMMENDED NEXT STEP

1. **Read** `AUTO_UPDATE_STATUS_AND_SETUP.md` (full details)
2. **Implement** Simple JSON UpdateChecker (1-2 hours)
3. **Test** with temporary version.json change
4. **Ship** your first release with working updates!
5. **Consider** Sparkle later for auto-install

**Start with Simple. Upgrade to Sparkle when needed.**

---

*Last Updated: January 19, 2026*
