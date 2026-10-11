import QtQuick
import qs.modules.common
import "MaterialMath.js" as Materials

QtObject {
    property var transparencySettings: Config.options.appearance.transparency
    property real automaticBackground: Appearance.autoBackgroundTransparency
    property real automaticContent: Appearance.autoContentTransparency
    readonly property var materialOpacities: Materials.opacities(transparencySettings, automaticBackground, automaticContent)
    readonly property real backgroundOpacity: materialOpacities.background
    readonly property real contentOpacity: materialOpacities.content
    property bool reducedMotion: false
    function alpha(color, value) {
        return Qt.rgba(color.r, color.g, color.b, value);
    }

    function mixOpaque(base, tint, amount) {
        const ratio = Math.max(0, Math.min(1, amount));
        return Qt.rgba(
            base.r * (1 - ratio) + tint.r * ratio,
            base.g * (1 - ratio) + tint.g * ratio,
            base.b * (1 - ratio) + tint.b * ratio,
            1
        );
    }

    readonly property color ink: Appearance.colors.colOnLayer0
    readonly property color mutedInk: alpha(ink, 0.64)
    readonly property color disabledInk: alpha(ink, 0.38)
    readonly property color windowSurface: Qt.rgba(
        Appearance.colors.colLayer0Base.r,
        Appearance.colors.colLayer0Base.g,
        Appearance.colors.colLayer0Base.b,
        backgroundOpacity
    )
    readonly property color sectionSurface: Qt.rgba(
        Appearance.colors.colLayer1Base.r,
        Appearance.colors.colLayer1Base.g,
        Appearance.colors.colLayer1Base.b,
        contentOpacity
    )
    readonly property color controlSurface: Qt.rgba(
        Appearance.colors.colLayer2Base.r,
        Appearance.colors.colLayer2Base.g,
        Appearance.colors.colLayer2Base.b,
        contentOpacity
    )
    readonly property color cardSurface: sectionSurface
    // Hover changes tint, not opacity: materials remain stable during input.
    readonly property color hoverSurface:
        alpha(mixOpaque(Appearance.colors.colLayer1Base, ink, 0.06), contentOpacity)
    readonly property color activeSurface:
        alpha(mixOpaque(Appearance.colors.colLayer1Base, ink, 0.11), contentOpacity)
    // Strong accent is reserved for an actual choice or primary action.
    readonly property color selectedSurface: Appearance.colors.colPrimary
    readonly property color selectedSurfaceHover:
        mixOpaque(selectedSurface, selectedInk, 0.07)
    readonly property color selectedSurfaceActive:
        mixOpaque(selectedSurface, selectedInk, 0.13)
    readonly property color selectedInk: Appearance.colors.colOnPrimary
    // A quieter accent keeps status and large surfaces from becoming loud.
    readonly property color accentContainer: Appearance.colors.colPrimaryContainer
    readonly property color accentContainerInk: Appearance.colors.colOnPrimaryContainer
    // Soft tinted accents for hero/accent cards without opaque shouting color
    readonly property color accentSubtle: alpha(selectedSurface, 0.14)
    readonly property color accentSubtleBorder: alpha(selectedSurface, 0.30)
    // Refined selection state for list rows and choice cards
    readonly property color selectedCardBackground: alpha(selectedSurface, 0.18)
    readonly property color selectedCardBorder: alpha(selectedSurface, 0.50)
    readonly property color selectedCardHover: alpha(selectedSurface, 0.24)
    readonly property color hairline: alpha(ink, 0.08)
    readonly property color strongHairline: alpha(ink, 0.14)
    readonly property color focusRing: alpha(Appearance.colors.colPrimary, 0.72)

    // Three predictable geometry levels. A nested surface must never look
    // rounder than the window containing it.
    readonly property int radiusWindow: 24
    readonly property int radiusSection: 18
    readonly property int radiusControl: 12
    readonly property int radiusNavigation: 14
    readonly property int radiusSegment: 10
    readonly property int radiusIcon: 14
    readonly property int controlHeight: 42
    readonly property int gapSection: 16
    readonly property int gapControl: 10
    readonly property int cardPadding: 16

    // Desktop motion: responsive and calm, without the long expressive
    // overshoot used by the shell's larger widgets.
    readonly property int motionFast: reducedMotion ? 0 : 120
    readonly property int motionNormal: reducedMotion ? 0 : 180
    readonly property int motionSlow: reducedMotion ? 0 : 260
    readonly property int motionEnter: reducedMotion ? 0 : 220
    readonly property var motionCurve: Appearance.animationCurves.standard
    readonly property var motionEnterCurve:
        Appearance.animationCurves.emphasizedDecel
}
