-- Hyprland 0.56+ Lua rules. Load AFTER the shell's default layer rules.
-- Native compositor blur uses the user's global enabled/size/passes values.
-- The Qt shadow uses alpha 0.30; its outer blurred fringe stays below 0.19.
-- Skip that fringe while retaining material alpha 0.20 (80% transparency).
hl.layer_rule({
    name = "miko-quickshell-materials",
    match = { namespace = "^quickshell:.*$" },
    blur = true,
    blur_popups = true,
    ignore_alpha = 0.19,
    xray = false,
})

-- Technical canvases are not frosted material surfaces. In particular, never
-- blur the wallpaper, screen-corner masks or screenshot selection content.
hl.layer_rule({
    name = "miko-quickshell-no-material",
    match = { namespace = "^quickshell:(background|screenCorners|overlay|regionSelector|screenshot|lockWindowPusher)$" },
    blur = false,
    blur_popups = false,
    ignore_alpha = 0,
})
