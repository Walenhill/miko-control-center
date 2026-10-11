.pragma library

function clamp(value) { return Math.max(0, Math.min(1, Number(value) || 0)); }
function opacities(settings, autoBackground, autoContent) {
    if (!settings.enable) return {background: 1, content: 1};
    return {
        background: 1 - clamp(settings.automatic ? autoBackground : settings.backgroundTransparency),
        content: 1 - clamp(settings.automatic ? autoContent : settings.contentTransparency)
    };
}
