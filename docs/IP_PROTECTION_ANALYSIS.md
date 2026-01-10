# SuperDimmer - Intellectual Property Protection Analysis
## Due Diligence & Protection Strategy Guide
### January 8, 2026

---

## 📋 Executive Summary

SuperDimmer has a **potentially patentable core innovation**: **intelligent, automatic, region-specific screen dimming** based on real-time brightness detection. This document analyzes protection options, timing considerations, and practical recommendations.

**Key Finding:** SuperDimmer's unique feature (detecting bright regions within dark-themed apps and selectively dimming only those regions while preserving dark content) appears to be novel in the consumer macOS utility space. No existing apps (f.lux, MonitorControl, Lunar, Umbra) offer this specific functionality.

---

## 🔒 Types of IP Protection Available

### 1. **Copyright Protection** ✅ AUTOMATIC

| Aspect | Details |
|--------|---------|
| **What's Protected** | Source code, UI graphics, icons, documentation, website content |
| **Cost** | Free (automatic) / ~$45-65 for registration |
| **Duration** | Life of author + 70 years |
| **Registration Required?** | No, but registration enables statutory damages |
| **Action Needed** | Include © notices; consider registration |

**SuperDimmer Copyright Elements:**
- Swift source code (all `.swift` files)
- Menu bar icon designs
- Preferences window UI design
- Website design and copy
- Documentation

**Recommendation:** Add copyright notices to code files and app. Consider formal registration if pursuing investors or before any enforcement action.

---

### 2. **Utility Patent** 🔍 POTENTIALLY APPLICABLE

| Aspect | Details |
|--------|---------|
| **What's Protected** | Novel functional processes, methods, algorithms |
| **Cost** | $10,000 - $20,000+ (attorney + USPTO fees) |
| **Duration** | 20 years from filing |
| **Time to Grant** | 2-3+ years |
| **Requirements** | Novel, Non-obvious, Useful |

**SuperDimmer's Potentially Patentable Innovation:**

```
NOVEL METHOD: Real-time, region-specific screen content dimming
based on automatic brightness threshold detection

CLAIMS COULD INCLUDE:
1. A method for automatically detecting regions of a display 
   exceeding a brightness threshold in real-time
2. Applying selective dimming overlays only to detected bright 
   regions while preserving unaffected areas
3. Differentiating dimming intensity based on window focus state
   (active vs inactive window context awareness)
4. Grid-based luminance sampling with connected component analysis
   for efficient bright region detection
```

**Novelty Assessment:**

| Existing Solutions | What They Do | What SuperDimmer Does Differently |
|-------------------|--------------|-----------------------------------|
| f.lux | Uniform color temperature shift | Region-specific, brightness-based |
| MonitorControl | Uniform screen dimming | Selective regional dimming |
| Lunar | Full-screen overlay dimming | Per-region intelligent dimming |
| Night Shift (Apple) | Color temperature adjustment | No brightness detection |
| True Tone (Apple) | Ambient light adaptation | Hardware sensor, not content-based |

**Prior Art Risk Areas:**
- Automotive adaptive display systems (may have patents on region-based dimming)
- TV/Monitor OSD systems with local dimming zones
- General image processing brightness detection methods

**Recommendation:** Conduct a professional prior art search ($1,500-3,000) before investing in a full patent application.

---

### 3. **Provisional Patent Application** ⭐ RECOMMENDED FIRST STEP

| Aspect | Details |
|--------|---------|
| **What It Does** | Establishes priority date; "Patent Pending" status |
| **Cost** | $320 (micro entity) / $1,600 (large entity) USPTO fee + attorney ~$2,000-4,000 |
| **Duration** | 12 months to file full utility patent |
| **Benefit** | Buys time to validate market before full investment |

**Why This Makes Sense for SuperDimmer:**
1. **Low Cost:** ~$2,500-5,000 total (vs $15,000+ for full patent)
2. **Establishes Priority:** If the app succeeds, you have a priority date
3. **"Patent Pending" Status:** Can mark app and marketing materials
4. **Time to Validate:** 12 months to see if the market responds
5. **International Grace Period:** Maintains option for international filing

**Timeline Strategy:**
```
NOW (Before Release)
├── File provisional patent application
├── Establishes January 2026 priority date
└── Cost: ~$2,500-5,000

WITHIN 12 MONTHS (After Release, Based on Traction)
├── If successful → File full utility patent
├── If moderate → Evaluate ROI of full filing
└── If unsuccessful → Let provisional lapse (lost cost only ~$3k)
```

---

### 4. **Design Patent** 💡 OPTIONAL

| Aspect | Details |
|--------|---------|
| **What's Protected** | Ornamental appearance of UI, icons, visual design |
| **Cost** | $2,000 - $5,000 |
| **Duration** | 15 years from grant |
| **Time to Grant** | 12-18 months |

**SuperDimmer Design Patent Candidates:**
- Menu bar icon set (sun states showing dim levels)
- Preferences window layout/design
- Overlay appearance and animation style

**Recommendation:** Lower priority than utility patent. Consider only if you develop truly distinctive, recognizable UI that becomes a brand identifier.

---

### 5. **Trademark Protection** ✅ RECOMMENDED

| Aspect | Details |
|--------|---------|
| **What's Protected** | "SuperDimmer" name, logo, tagline |
| **Cost** | ~$250-350 per class (USPTO) + attorney ~$500-1,000 |
| **Duration** | Indefinite (with renewal every 10 years) |
| **Action Needed** | File before/at launch |

**SuperDimmer Trademark Strategy:**
- **Word Mark:** "SuperDimmer" (Class 9: Computer software)
- **Logo Mark:** If you develop a distinctive logo
- **Tagline:** "Your eyes' intelligent shield" (if used consistently)

**Pre-Filing Checklist:**
- [x] Check USPTO TESS database for conflicts
- [ ] Check domain availability (superdimmer.app ✓)
- [ ] Search App Store for similar names
- [ ] Consider international markets (WIPO Madrid System)

**Recommendation:** File trademark application for "SuperDimmer" in Class 9 before or immediately at launch. Cost: ~$350-500 DIY or ~$800-1,200 with attorney.

---

### 6. **Trade Secrets** 🔐 AUTOMATIC (WITH PRECAUTIONS)

| Aspect | Details |
|--------|---------|
| **What's Protected** | Proprietary algorithms, internal processes |
| **Cost** | $0 (but requires confidentiality measures) |
| **Duration** | As long as kept secret |
| **Risk** | Lost if disclosed or independently discovered |

**SuperDimmer Trade Secret Candidates:**
- Specific optimization techniques for brightness analysis
- Performance tuning parameters
- Any proprietary algorithms not disclosed in patent

**Protection Measures:**
- Keep detailed optimization code in private repos
- Use NDAs with any contractors
- Don't open-source core detection algorithms

**Note:** Trade secret and patent are mutually exclusive for the same information. Patent = public disclosure; Trade secret = kept confidential.

---

## ⏰ Timing: Must You Protect Before Release?

### Critical Deadlines

| Protection Type | Deadline | Consequence of Missing |
|-----------------|----------|----------------------|
| **Utility Patent** | File before public disclosure (OR within 1-year U.S. grace period) | Loss of international rights immediately; loss of U.S. rights after 1 year |
| **Copyright** | None (automatic) | Can still register anytime |
| **Trademark** | None required, but first-to-use matters | Weaker position if competitor registers first |
| **Trade Secret** | Before any disclosure | Once disclosed, cannot become trade secret |

### The U.S. One-Year Grace Period

**In the U.S.**, you have **12 months after first public disclosure** to file a patent application. However:

⚠️ **International Warning:** Most countries (EU, China, Japan, etc.) have **no grace period**. Public disclosure = immediate loss of patent rights internationally.

**What Counts as "Public Disclosure"?**
- App Store release
- Public website download
- Demo at a conference
- Blog post describing how it works
- GitHub public repository (if code reveals the method)

**Recommendation:** If you want international patent rights, file a provisional patent application BEFORE releasing the app publicly.

---

## 📝 Disclosure Requirements in the App

### What You MUST Include

| Requirement | Mandatory? | Recommendation |
|-------------|------------|----------------|
| Copyright notice | No (but helpful) | Yes - include © 2026 SuperDimmer |
| Patent pending notice | No (if applicable) | Yes - adds deterrent value |
| Open source licenses | Yes (if using OSS) | Attribution for Sparkle, KeyboardShortcuts, etc. |
| Privacy policy | Yes (for App Store, EU) | Already have on website |

### What You SHOULD Include

```
About SuperDimmer:
© 2026 SuperDimmer. All rights reserved.
[Patent Pending - if filed]

Portions of this software utilize:
- Sparkle Framework (MIT License)
- KeyboardShortcuts (MIT License)
- [Other attributions]
```

### What You MAY Include (Marketing Value)

- "Patent Pending" on website/marketing (only if actually filed)
- "™" after SuperDimmer (can use before registration)
- "®" after SuperDimmer (only AFTER trademark registration approved)

---

## 💰 Cost-Benefit Analysis

### Protection Investment Scenarios

#### Scenario A: Minimum Protection (Budget: ~$500-1,000)
| Action | Cost | Benefit |
|--------|------|---------|
| Copyright notices | $0 | Basic protection |
| Trademark search | $0 (DIY) | Avoid conflicts |
| Trademark filing (DIY) | $350 | Name protection |
| **Total** | ~$350-500 | Basic brand protection |

#### Scenario B: Strategic Protection (Budget: ~$5,000-8,000) ⭐ RECOMMENDED
| Action | Cost | Benefit |
|--------|------|---------|
| Copyright registration | $65 | Enhanced enforcement |
| Trademark (with attorney) | $1,200 | Solid name protection |
| Prior art search | $2,000-3,000 | Informed decision |
| Provisional patent | $2,500-4,000 | 12-month priority |
| **Total** | ~$5,500-8,000 | Strategic position |

#### Scenario C: Full Protection (Budget: ~$20,000-30,000)
| Action | Cost | Benefit |
|--------|------|---------|
| All of Scenario B | $8,000 | Foundation |
| Full utility patent | $12,000-18,000 | 20-year monopoly |
| International (PCT) | $3,000-5,000 | Global priority |
| Design patent | $3,000 | UI protection |
| **Total** | ~$25,000-35,000 | Maximum protection |

---

## 🎯 Due Diligence Checklist

### Before Release

- [ ] **Prior Art Search:** Look for existing patents on regional screen dimming
- [ ] **Trademark Search:** Verify "SuperDimmer" is clear (USPTO TESS, domain, App Store)
- [ ] **Decision: Provisional Patent?** Decide if filing based on cost-benefit
- [ ] **Copyright Notices:** Add to source code and app
- [ ] **Open Source Compliance:** Verify all licenses are compatible, add attributions
- [ ] **Privacy Policy:** Complete (you have this)
- [ ] **Terms of Service:** Complete (you have this)

### At/After Release

- [ ] **Trademark Filing:** Submit application
- [ ] **Document Everything:** Keep records of first public use date
- [ ] **Monitor Competition:** Watch for similar apps
- [ ] **12-Month Deadline:** If provisional filed, decide on full patent

---

## 🔍 Quick Prior Art Search Results

Based on initial research, here's what exists in the market:

### Direct Competitors (No Region-Specific Dimming)
| App | What It Does | Region-Specific? |
|-----|--------------|------------------|
| f.lux | Color temperature shift | ❌ Full screen |
| Night Shift | Color temperature shift | ❌ Full screen |
| MonitorControl | DDC brightness control | ❌ Full screen |
| Lunar | Software overlay dimming | ❌ Full screen |
| Umbra | Wallpaper management | ❌ N/A |

### Related Patents to Investigate
- Apple patents on True Tone / adaptive display
- TV/Monitor local dimming zone patents (hardware-based)
- Automotive HUD adaptive brightness patents
- General image processing / luminance detection patents

**Recommendation:** A professional prior art search by a patent attorney ($2,000-3,000) would provide much more thorough analysis before investing in a patent application.

---

## 📊 Decision Framework

### Is This Worth Protecting?

Answer these questions to decide your investment level:

| Question | If YES | If NO |
|----------|--------|-------|
| Is the region-specific dimming your main differentiator? | Protect it | Consider skipping patent |
| Do you expect significant revenue ($100K+/year)? | Full protection makes sense | Minimum protection |
| Are you seeking investors? | They expect IP protection | Less critical |
| Do you plan to sell the company? | IP adds value | Less critical |
| Is there risk of well-funded competitors? | Protect early | Monitor situation |
| Are international markets important? | File before release | U.S. grace period OK |

---

## ✅ Recommended Action Plan

### Immediate (This Week)
1. **Trademark Search:** Verify "SuperDimmer" is clear
2. **Decision Point:** Decide on provisional patent (Y/N)
3. **Add Copyright Notices:** To all source files

### Before Release (If Pursuing Patent)
1. **Consult Patent Attorney:** Get professional opinion on patentability
2. **File Provisional Patent:** Establish priority date
3. **Document Innovation:** Create detailed technical description

### At Release
1. **File Trademark Application:** "SuperDimmer" in Class 9
2. **Include Proper Notices:** © and "Patent Pending" if applicable
3. **Record Release Date:** Document first public availability

### Post-Release (Within 12 Months)
1. **Evaluate Market Response:** Is the app successful enough to justify full patent?
2. **Make Patent Decision:** File full utility patent or let provisional lapse
3. **Monitor Competition:** Watch for copycats

---

## 📚 Resources

### USPTO
- Patent Search: https://patft.uspto.gov/
- Trademark Search (TESS): https://tmsearch.uspto.gov/
- Provisional Patent Info: https://www.uspto.gov/patents/basics/types-patent-applications/provisional-application-patent

### Professional Help
- Patent Attorney (recommended for patent applications)
- IP search firms (for thorough prior art searches)
- Trademark attorneys (optional, can DIY for straightforward filings)

### Cost-Effective Options
- LegalZoom / Rocket Lawyer (for basic trademark filings)
- USPTO Pro Bono Program (if qualify)
- Law school IP clinics (reduced-cost assistance)

---

## ⚠️ Disclaimer

This document provides general information about intellectual property options. It is not legal advice. For specific guidance on your situation, consult with a qualified intellectual property attorney.

---

*Document Version: 1.0*  
*Last Updated: January 8, 2026*  
*Status: Research Complete - Decision Needed*
