# FI-YOU Transparent Glass v5 Acceptance Criteria

Date: 2026-06-21  
Target: FI-YOU Flutter Android 1st official release  
Role: UI Design / Visual System Lead

## Decision

Liquid Glass v4 is deprecated.

FI-YOU v5 is **transparent glass only**:

- No colored tint.
- No colored glow.
- No specular flare.
- No chromatic edge.
- No colored gradient.
- No milky fill.
- No dark panel fill.

Glass should look transparent because the background passes through it. It should not look beautiful because color effects were added.

## Scope

Allowed:

- Visual style of boxes, cards, containers, buttons, bottom navigation, Android system navigation bar, and shared glass helpers.
- Token and helper cleanup that preserves current UI layout.

Not allowed:

- Screen redesign.
- Layout reordering.
- Copy changes.
- Route/backend/Supabase changes.
- U-Map graph structure changes.
- Full undo/revert.

## v5 Definition

A v5 glass surface is built only from:

- `BackdropFilter` blur.
- Transparent body or almost transparent white body.
- Thin white alpha border.
- Very weak black ambient shadow.
- Optional white alpha press overlay for buttons.

The surface must not use semantic colors as material:

- Purple is not glass.
- Cyan is not glass.
- Gold is not glass.
- `#A8A0D8` is not glass.

Semantic colors may appear only in content: icon, text, graph data, Star meaning, or active nav foreground.

## Global v5 Tokens

Recommended minimum token set:

```dart
glassTransparent: Colors.transparent

glassBlurLarge: 14-16
glassBlurMedium: 12-14
glassBlurSmall: 8-10
glassBlurCta: 14-16
glassBlurNav: 18-24

glassRadiusLarge: 28
glassRadiusMedium: 22
glassRadiusSmall: 18
glassRadiusPill: 999

glassFillLarge: Colors.white alpha 0.055-0.075
glassFillMedium: Colors.white alpha 0.045-0.065
glassFillSmall: Colors.white alpha 0.035-0.055
glassFillCtaEnabled: Colors.white alpha 0.075-0.095
glassFillCtaPressed: Colors.white alpha 0.10-0.12
glassFillDisabled: Colors.white alpha 0.035-0.045
glassFillNav: Colors.white alpha 0.030-0.055

glassBorderLarge: Colors.white alpha 0.18-0.24
glassBorderMedium: Colors.white alpha 0.16-0.22
glassBorderSmall: Colors.white alpha 0.14-0.20
glassBorderCta: Colors.white alpha 0.24-0.32
glassBorderCtaPressed: Colors.white alpha 0.34
glassBorderDisabled: Colors.white alpha 0.12
glassBorderNav: Colors.white alpha 0.14-0.22

glassShadowLarge: Colors.black alpha 0.10-0.14, blur 18-22, y 8-10
glassShadowMedium: Colors.black alpha 0.08-0.12, blur 14-18, y 6-8
glassShadowSmall: none or Colors.black alpha <= 0.08, blur 8-12, y 4
glassShadowCta: Colors.black alpha 0.08-0.10, blur 14-18, y 6-8
glassShadowNav: Colors.black alpha 0.05-0.10, blur 18-24, y 8-12

glassPressScale: 0.985-0.992
glassPressOverlay: Colors.white alpha 0.08-0.12
glassDisabledContentOpacity: 0.42-0.55
```

## Deprecated v4 Tokens / Effects

Remove or deprecate these as v5 glass material:

- `glassTintViolet`
- `glassTintCyan`
- `glassInnerGlowCyan`
- `glassInnerGlowViolet`
- `glassGlowIntensity`
- `glassSpecularWhite`
- `glassSpecularSmall`
- `glassSpecularCta`
- `glassHighlightShadow`
- `glassLargeHighlightShadow`
- `glassSmallHighlightShadow`
- `glassChromaticAberration`
- `glassChromaticCyanEdge`
- `glassChromaticVioletEdge`
- `glassV3BodyTint`
- `glassV3SmallTint`
- `glassV4BodyTint`
- `glassV4SmallTint`
- `nativeBarPillFill`
- colored `BoxShadow`
- colored `LinearGradient`
- colored `RadialGradient`
- `bodyTint` as a glass API
- `tint` as a glass API
- `borderColor` as semantic color injection for glass
- rest-state accent glow
- specular flare rectangles
- chromatic edge painters
- colored sweep/dust/sparkle inside glass painter

Allowed semantic color usage:

- Gold: Star icon, Star text, Star price/balance, `Logo_gold.png`.
- `#A8A0D8`: active nav icon/text only.
- Cyan/purple/gold: graph/data/icon/text meaning only, not glass material.

## Failure Criteria

Fail if any are true:

- Card appears as a purple, blue, gray, or gold block.
- Button has colored fill, glow, or gradient.
- Large card looks milky, frosted, or fogged.
- Surface reads as a dark panel.
- Screen-specific glass values differ.
- `bodyTint`, `tint`, or semantic `borderColor` changes the glass body.
- `#A8A0D8` appears in nav fill, nav border, nav shadow, pill fill, ripple, or glow.
- Gold appears in any glass border/fill/shadow/gradient.
- CTA grows brighter through color glow instead of neutral white alpha press.

## LargeTransparentGlassV5

Use for:

- Main Home panels.
- Large U-Map panels.
- Diary large containers.
- My profile card.
- Large Store/Settings section cards when they are content containers.

Suggested values:

```dart
radius: 28
blur: 14-16
fill: white alpha 0.055-0.075
border: white alpha 0.18-0.24, width 1.0
shadow: black alpha 0.10-0.14, blur 18-22, y 8-10
```

Pass:

- Background remains visible through the card.
- Card does not have color personality.
- Border is a thin neutral white alpha line.
- Shadow only separates depth, not mood.

Fail:

- Uses accent `bodyTint`.
- Uses colored gradient.
- Uses specular flare or chromatic edge.
- Looks like frosted/milky white.
- Looks like dark navy panel.

## MediumTransparentGlassV5

Use for:

- Medium list sections.
- Diary cards.
- Settings groups.
- Store row groups.
- Text fields if a surface is needed.

Suggested values:

```dart
radius: 22
blur: 12-14
fill: white alpha 0.045-0.065
border: white alpha 0.16-0.22, width 0.9-1.0
shadow: black alpha 0.08-0.12, blur 14-18, y 6-8
```

Pass:

- Supports readability while remaining transparent.
- Repeated cards do not form gray stacks.

Fail:

- Uses cyan/purple/gold as tint.
- Uses gradient highlight.
- Becomes more visually heavy than LargeTransparentGlassV5.

## SmallTransparentGlassV5

Use for:

- Icon boxes.
- Metric boxes.
- Chips.
- Pills.
- Star price pill glass body, with gold only in icon/text.

Suggested values:

```dart
radius: 18 or 999 for pill
blur: 8-10
fill: white alpha 0.035-0.055
border: white alpha 0.14-0.20, width 0.8-1.0
shadow: none preferred, or black alpha <= 0.08, blur 8-12, y 4
hitTarget: min 48x48 for interactive controls
```

Pass:

- Small controls are neutral glass, not colored badges.
- Meaning color appears only in icon/text.

Fail:

- Gold border/fill around Star pill.
- Cyan/purple pill background.
- Actual hit target below 48dp.

## CtaTransparentGlassV5

Use for:

- Primary question start.
- Save/submit.
- Main next action.

Suggested values:

```dart
height: 50-58
radius: 18
blur: 14-16
fillEnabled: white alpha 0.075-0.095
fillPressed: white alpha 0.10-0.12
fillDisabled: white alpha 0.035-0.045
borderEnabled: white alpha 0.24-0.32
borderPressed: white alpha 0.34
borderDisabled: white alpha 0.12
shadow: black alpha 0.08-0.10, blur 14-18, y 6-8
pressScale: 0.985-0.992
overlay: white alpha 0.08-0.12
```

Pass:

- CTA is still transparent glass.
- Emphasis comes from border clarity, slightly higher white alpha, and text/icon weight.
- Press feels like a slight inward press.

Fail:

- Colored CTA fill.
- Cyan/purple/gold glow.
- Button scales upward or emits glow.
- Star purchase CTA uses gold glass instead of gold icon/text.

## NavTransparentGlassV5

Use for:

- Floating app bottom nav.
- Active pill.
- Android system navigation bar treatment.

Allowed `#A8A0D8`:

- Active nav icon.
- Active nav label text.

Forbidden `#A8A0D8`:

- Nav capsule fill.
- Nav capsule border.
- Nav capsule shadow.
- Nav capsule glow.
- Nav gradient.
- Active pill fill.
- Active pill colored glow.
- Ripple/splash/highlight.
- Android system navigation bar fill.

Suggested values:

```dart
height: 68-72
radius: 32
blur: 18-24
fill: white alpha 0.030-0.055 or transparent
border: white alpha 0.14-0.22, width 0.8-1.0
shadow: black alpha 0.05-0.10, blur 18-24, y 8-12
activePillFill: white alpha 0.03-0.06 or none
activePillBorder: white alpha 0.16-0.24
activeIconLabel: #A8A0D8
inactiveIconLabel: textMuted alpha 0.75-0.90
splash/highlight: white alpha 0.04-0.08 or transparent
```

System nav:

```dart
preferred: transparent / edge-to-edge
fallback: FI-YOU dark background or near-background dark
forbidden: #A8A0D8 as system nav fill
```

Pass:

- Nav is transparent glass with active foreground only.
- `#A8A0D8` reads as selection, not material.

Fail:

- Current-style colored pill fill remains.
- Active ripple is purple.
- Nav border/glow uses accent.

## Implementation Order

1. Define v5 presets:
   - `largeTransparent`
   - `mediumTransparent`
   - `smallTransparent`
   - `ctaTransparent`
   - `navTransparent`
2. Remove color parameters from v5 glass API.
   - No `bodyTint`.
   - No `tint`.
   - No semantic `borderColor`.
3. Keep old V3/V4 helpers only as deprecated compatibility aliases.
4. Replace common glass implementation first in `fi_you_glass.dart`.
5. Remove colored tint calls from Home.
6. Convert `MySurface` to v5.
7. Remove U-Map gold/cyan/axis color from glass borders/fills.
8. Remove Explore `_gold`, `_primarySoft`, `_cyan` from glass material.
9. Remove Diary cyan border/body tint and colored overlay.
10. Verify nav uses `#A8A0D8` only for active foreground.

## First Effects To Remove

Priority 1:

- `bodyTint` pass-through in common surfaces.
- Colored gradient in glass decoration.
- Colored glow shadows.
- Specular flare painter.
- Chromatic edge painter.
- `nativeBarPillFill = Color(0x24A8A0D8)`.
- Nav accent border/glow.

Priority 2:

- Gold glass borders on Star cards/pills.
- Cyan glass borders on Diary/Explore/U-Map CTA.
- Purple/cyan/gold nebula-like glass backing.
- CTA press glow.

Priority 3:

- Any remaining screen-specific glass recipes.
- Any old V3/V4 alias used by new code.

## Screenshot QA

Pass screenshots only if:

- Large cards are transparent, not colored or milky.
- Buttons are neutral glass and retain text/icon meaning.
- Star gold appears only in Star icon/text/logo.
- `#A8A0D8` appears only in active nav icon/text.
- No glass border/fill/shadow uses purple, cyan, gold, or nav accent.
- Glass values are visually consistent across Home, Explore, Diary, U-Map, My, Store, Settings.
