.pragma library

// Portable, versioned allow-list. Never serialize the entire Config object:
// it contains local paths, monitor names and security settings.
var paletteModes = ["auto", "scheme-content", "scheme-expressive", "scheme-fidelity", "scheme-fruit-salad", "scheme-monochrome", "scheme-neutral", "scheme-rainbow", "scheme-tonal-spot"];
var fields = {};
function field(path, category, type, constraint) { fields[path] = {category: category, type: type, constraint: constraint}; }
function bool(path, category) { field(path, category, "boolean"); }
function number(path, category, min, max) { field(path, category, "number", [min, max]); }
function choice(path, category, values) { field(path, category, "string", values); }
function string(path, category, limit) { field(path, category, "string", limit); }
bool("appearance.transparency.enable", "materials");
bool("appearance.transparency.automatic", "materials");
number("appearance.transparency.backgroundTransparency", "materials", 0, 0.8);
number("appearance.transparency.contentTransparency", "materials", 0, 0.9);
["main", "numbers", "title", "iconNerd", "monospace", "reading", "expressive"].forEach(function(role) { string("appearance.fonts." + role, "fonts", 120); });
var clock = "background.widgets.clock.";
bool(clock + "enable", "widgets");
bool(clock + "showOnlyWhenLocked", "widgets");
choice(clock + "style", "widgets", ["cookie", "digital"]);
choice(clock + "styleLocked", "widgets", ["cookie", "digital"]);
choice(clock + "placementStrategy", "widgets", ["free", "leastBusy", "mostBusy"]);
choice(clock + "cookie.dialNumberStyle", "widgets", ["dots", "numbers", "full", "none"]);
choice(clock + "cookie.hourHandStyle", "widgets", ["classic", "fill", "hollow", "hide"]);
choice(clock + "cookie.minuteHandStyle", "widgets", ["classic", "thin", "medium", "bold", "hide"]);
choice(clock + "cookie.secondHandStyle", "widgets", ["dot", "line", "classic", "hide"]);
choice(clock + "cookie.dateStyle", "widgets", ["border", "rect", "bubble", "hide"]);
number(clock + "cookie.sides", "widgets", 3, 40);
["timeIndicators", "hourMarks", "dateInClock", "constantlyRotate", "useSineCookie"].forEach(function(key) { bool(clock + "cookie." + key, "widgets"); });
["adaptiveAlignment", "showDate", "animateChange", "vertical"].forEach(function(key) { bool(clock + "digital." + key, "widgets"); });
string(clock + "digital.font.family", "fonts", 120);
number(clock + "digital.font.weight", "widgets", 100, 900);
number(clock + "digital.font.width", "widgets", 25, 200);
number(clock + "digital.font.size", "widgets", 24, 180);
number(clock + "digital.font.roundness", "widgets", 0, 100);
bool(clock + "quote.enable", "widgets");
string(clock + "quote.text", "widgets", 500);
bool("background.widgets.weather.enable", "widgets");
choice("background.widgets.weather.placementStrategy", "widgets", ["free", "leastBusy", "mostBusy"]);
["vertical", "bottom", "showBackground", "borderless", "verbose"].forEach(function(key) { bool("bar." + key, "shell"); });
["enable", "monochromeIcons", "pinnedOnStartup", "hoverToReveal"].forEach(function(key) { bool("dock." + key, "shell"); });
number("dock.height", "shell", 36, 100);
bool("overview.enable", "shell");
bool("overview.centerIcons", "shell");
number("overview.scale", "shell", 0.08, 0.3);
number("overview.rows", "shell", 1, 6);
number("overview.columns", "shell", 2, 12);

function read(object, path) { return path.split(".").reduce(function(value, key) { return value === undefined || value === null ? undefined : value[key]; }, object); }
function byteLength(text) {
    var bytes = 0;
    for (var i = 0; i < text.length; ++i) {
        const code = text.charCodeAt(i);
        if (code < 128) bytes++;
        else if (code < 2048) bytes += 2;
        else if (code >= 0xd800 && code <= 0xdbff && i + 1 < text.length && text.charCodeAt(i + 1) >= 0xdc00 && text.charCodeAt(i + 1) <= 0xdfff) { bytes += 4; i++; }
        else bytes += 3;
    }
    return bytes;
}
function parse(text) {
    if (byteLength(text) > 131072) throw new Error("Profile exceeds 128 KiB");
    return validate(JSON.parse(text));
}
function validValue(rule, value) {
    if (typeof value !== rule.type) return false;
    if (rule.type === "number") return isFinite(value) && value >= rule.constraint[0] && value <= rule.constraint[1];
    if (rule.type === "string") return Array.isArray(rule.constraint) ? rule.constraint.indexOf(value) >= 0 : value.length <= rule.constraint && !/[\u0000-\u001f]/.test(value);
    return true;
}
function validate(profile) {
    if (!profile || Array.isArray(profile) || profile.format !== "miko-appearance" || profile.version !== 1)
        throw new Error("Unsupported appearance profile format");
    if (Object.keys(profile).some(function(key) { return ["format", "version", "name", "options", "theme"].indexOf(key) < 0; }))
        throw new Error("Unknown profile field");
    if (typeof profile.name !== "string" || !profile.name.trim() || profile.name.length > 80)
        throw new Error("Invalid profile name");
    if (!profile.options || typeof profile.options !== "object" || Array.isArray(profile.options)) throw new Error("Invalid options");
    Object.keys(profile.options).forEach(function(path) {
        if (!Object.prototype.hasOwnProperty.call(fields, path) || !validValue(fields[path], profile.options[path]))
            throw new Error("Invalid appearance option: " + path);
    });
    if (profile.theme !== undefined) {
        const theme = profile.theme;
        if (!theme || Object.keys(theme).sort().join(",") !== "accent,dark,palette" || typeof theme.dark !== "boolean"
            || paletteModes.indexOf(theme.palette) < 0 || typeof theme.accent !== "string" || (theme.accent !== "" && !/^#[0-9a-f]{6}$/i.test(theme.accent)))
            throw new Error("Invalid theme");
    }
    return profile;
}
function capture(configuration, theme, name, categories) {
    const options = {};
    Object.keys(fields).forEach(function(path) {
        const rule = fields[path], value = read(configuration, path);
        if (categories.indexOf(rule.category) >= 0 && validValue(rule, value)) options[path] = value;
    });
    const profile = {format: "miko-appearance", version: 1, name: name.trim(), options: options};
    if (categories.indexOf("materials") >= 0) profile.theme = {palette: theme.palette, dark: theme.dark, accent: theme.accent || ""};
    return validate(profile);
}
function plan(profile, configuration, availableFonts) {
    validate(profile);
    const options = {}, skipped = [];
    Object.keys(profile.options).forEach(function(path) {
        const value = profile.options[path];
        if (read(configuration, path) === undefined || (fields[path].category === "fonts" && availableFonts.indexOf(value) < 0)) skipped.push(path);
        else options[path] = value;
    });
    return {options: options, skipped: skipped, theme: profile.theme};
}
