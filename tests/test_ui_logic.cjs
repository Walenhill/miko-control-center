const assert = require('node:assert/strict');
const test = require('node:test');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');

function load(name) {
    const context = vm.createContext({});
    const source = fs.readFileSync(path.join(__dirname, '../src/controlcenter', name), 'utf8');
    vm.runInContext(source.replace(/^\.pragma library\s*/, ''), context);
    return context;
}
const search = load('SearchIndex.js');
const undo = load('AppearanceUndo.js');
const profiles = load('AppearanceProfiles.js');
const materials = load('MaterialMath.js');
const items = [
    {pageId: 'displays', target: 'modes', title: 'Resolution', subtitle: 'Display modes'},
    {pageId: 'system', target: 'performance', title: 'Performance', subtitle: 'CPU and memory'},
    {pageId: 'sound', target: 'mixer', title: 'Application volume', subtitle: 'Mixer'},
];
const pages = [{id: 'displays', title: 'Displays'}, {id: 'system', title: 'System'}, {id: 'sound', title: 'Sound'}];

test('search aliases work in both languages regardless of interface locale', () => {
    for (const query of ['герцовка', 'частота', 'частота обновления', 'refresh rate', '144 hz', 'resolution']) {
        // 144 is intentionally not a static synonym; it comes from item keywords.
        const data = items.map(item => ({...item, keywords: item.target === 'modes' ? '144 hz' : ''}));
        assert.equal(search.search(data, query, pages)[0].target, 'modes');
    }
    assert.equal(search.search(items, 'громкость приложений', pages)[0].target, 'mixer');
});
test('search matches all words, returns categories and handles an empty result', () => {
    assert.equal(search.search(items, 'refresh volume', pages).length, 0);
    assert.equal(search.search(items, 'mixer', pages)[0].category, 'Sound');
    assert.equal(search.search(items, 'no-such-option', pages).length, 0);
    assert.equal(search.search(items, '', pages).length, items.length);
});
test('exact titles outrank synonym matches and normalization accepts yo and hyphens', () => {
    assert.equal(search.search([{pageId: 'sound', target: 'mixer', title: 'Something'},
        {pageId: 'sound', target: 'master', title: 'Mixer'}], 'mixer', pages)[0].title, 'Mixer');
    assert.equal(search.normalize('  ТЁМНАЯ Wi-Fi  '), 'темная wi fi');
});
test('grouped options revert together and no-op changes create no history', () => {
    const options = {bar: {bottom: false, vertical: false}};
    const changes = undo.changes(options, {'bar.bottom': true, 'bar.vertical': true});
    undo.write(options, changes, 'after');
    assert.equal(undo.matches(options, changes), true);
    undo.write(options, changes, 'before');
    assert.deepEqual(options.bar, {bottom: false, vertical: false});
    assert.equal(undo.changes(options, {'bar.bottom': false}).length, 0);
});
test('external changes disable undo and unknown paths fail before writing', () => {
    const options = {bar: {bottom: false}};
    const changes = undo.changes(options, {'bar.bottom': true});
    undo.write(options, changes, 'after');
    options.bar.bottom = false;
    assert.equal(undo.matches(options, changes), false);
    assert.throws(() => undo.changes(options, {'bar.bottom': true, 'bar.missing': 1}));
    assert.equal(options.bar.bottom, false);
});

test('appearance profiles accept only versioned, portable appearance fields', () => {
    const profile = {format: 'miko-appearance', version: 1, name: 'Test',
        options: {'appearance.fonts.main': 'Installed', 'dock.height': 60},
        theme: {palette: 'scheme-tonal-spot', dark: true, accent: '#abcdef'}};
    assert.equal(profiles.validate(profile), profile);
    for (const key of ['background.wallpaperPath', 'lock.requirePasswordToPower', '__proto__', 'bar.screenList']) {
        const options = JSON.parse(JSON.stringify(profile.options));
        Object.defineProperty(options, key, {value: 'unsafe', enumerable: true});
        assert.throws(() => profiles.validate({...profile, options}));
    }
    assert.throws(() => profiles.validate({...profile, command: 'anything'}));
    assert.throws(() => profiles.validate({...profile, version: 2}));
    assert.throws(() => profiles.validate({...profile, options: {'dock.height': 900}}));
    assert.throws(() => profiles.validate({...profile, theme: {...profile.theme, accent: 'red; command'}}));
});
test('profile planning skips unavailable fonts and missing runtime capabilities', () => {
    const profile = {format: 'miko-appearance', version: 1, name: 'Test',
        options: {'appearance.fonts.main': 'Missing', 'dock.height': 60, 'overview.rows': 3}};
    const configuration = {appearance: {fonts: {main: 'Current'}}, dock: {height: 48}};
    const plan = profiles.plan(profile, configuration, ['Current']);
    assert.equal(plan.options['dock.height'], 60);
    assert.equal(plan.skipped.length, 2);
    assert.equal(configuration.dock.height, 48);
});
test('captured appearance profile excludes personal paths and screen positions', () => {
    const profile = profiles.capture({background: {wallpaperPath: 'private.png', widgets: {clock: {enable: true, x: 700}}},
        appearance: {fonts: {main: 'Installed'}, transparency: {enable: true}}},
        {palette: 'auto', dark: false, accent: ''}, 'Portable', ['widgets', 'fonts', 'materials']);
    assert.equal(profile.options['background.widgets.clock.enable'], true);
    assert.equal(profile.options['background.wallpaperPath'], undefined);
    assert.equal(profile.options['background.widgets.clock.x'], undefined);
    assert.equal(profile.theme.palette, 'auto');
});
test('profile import enforces UTF-8 byte limits before parsing', () => {
    assert.equal(profiles.byteLength('AaБб😀'), 10);
    assert.throws(() => profiles.parse('я'.repeat(65537)), /128 KiB/);
    assert.throws(() => profiles.parse('{invalid json}'));
});
test('material opacity has no hidden plateau and off is fully opaque', () => {
    for (const amount of [0, .1, .2, .42, .6, .9]) {
        const result = materials.opacities({enable: true, automatic: false, backgroundTransparency: amount, contentTransparency: amount}, .22, .9);
        assert.equal(result.background, 1 - amount);
        assert.equal(result.content, 1 - amount);
    }
    const off = materials.opacities({enable: false, automatic: true}, .2, .9);
    assert.equal(off.background, 1);
    assert.equal(off.content, 1);
});
test('automatic material mode reports actual values and clamps invalid auto output', () => {
    const auto = materials.opacities({enable: true, automatic: true, backgroundTransparency: .07, contentTransparency: .42}, .15, .9);
    assert.equal(auto.background, .85);
    assert.ok(Math.abs(auto.content - .1) < 1e-9);
    assert.equal(materials.opacities({enable: true, automatic: true}, -.12, 2).background, 1);
});
