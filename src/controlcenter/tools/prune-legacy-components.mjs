#!/usr/bin/env node

import fs from "node:fs";

const legacyIds = [
    "overviewPageLegacy",
    "connectionsPageLegacy",
    "applicationsPageLegacy",
    "appearancePageLegacy",
    "servicesPageEmbeddedLegacy",
    "servicesPageLegacy",
    "systemPageLegacy",
    "displaysPageLegacy",
    "devicesPageLegacy",
    "soundPageLegacy",
];

const target = process.argv.find(argument => !argument.startsWith("--")
    && argument !== process.argv[0] && argument !== process.argv[1]);
const apply = process.argv.includes("--apply");

if (!target) {
    console.error(
        "usage: prune-legacy-components.mjs [--apply] /path/to/control-center.qml",
    );
    process.exit(2);
}

function matchingBrace(source, openingBrace) {
    let depth = 0;
    let state = "code";
    let escaped = false;

    for (let index = openingBrace; index < source.length; index += 1) {
        const current = source[index];
        const next = source[index + 1];

        if (state === "line-comment") {
            if (current === "\n")
                state = "code";
            continue;
        }
        if (state === "block-comment") {
            if (current === "*" && next === "/") {
                state = "code";
                index += 1;
            }
            continue;
        }
        if (state !== "code") {
            if (escaped) {
                escaped = false;
                continue;
            }
            if (current === "\\") {
                escaped = true;
                continue;
            }
            if ((state === "single-quote" && current === "'")
                    || (state === "double-quote" && current === "\"")
                    || (state === "template" && current === "`")) {
                state = "code";
            }
            continue;
        }

        if (current === "/" && next === "/") {
            state = "line-comment";
            index += 1;
        } else if (current === "/" && next === "*") {
            state = "block-comment";
            index += 1;
        } else if (current === "'") {
            state = "single-quote";
        } else if (current === "\"") {
            state = "double-quote";
        } else if (current === "`") {
            state = "template";
        } else if (current === "{") {
            depth += 1;
        } else if (current === "}") {
            depth -= 1;
            if (depth === 0)
                return index;
        }
    }

    throw new Error(`unbalanced block starting at byte ${openingBrace}`);
}

const original = fs.readFileSync(target, "utf8");
const removals = legacyIds.map(id => {
    const marker = new RegExp(
        `^[ \\t]*Component[ \\t]*\\{[ \\t]*\\n[ \\t]*id:[ \\t]*${id}[ \\t]*$`,
        "m",
    );
    const match = marker.exec(original);
    if (!match)
        throw new Error(`legacy component not found: ${id}`);

    const start = match.index;
    const openingBrace = original.indexOf("{", start);
    let end = matchingBrace(original, openingBrace) + 1;
    while (original[end] === " " || original[end] === "\t")
        end += 1;
    if (original[end] === "\n")
        end += 1;
    if (original[end] === "\n")
        end += 1;

    return { id, start, end };
}).sort((left, right) => right.start - left.start);

let result = original;
for (const removal of removals)
    result = result.slice(0, removal.start) + result.slice(removal.end);

for (const id of legacyIds) {
    if (new RegExp(`\\bid:[ \\t]*${id}\\b`).test(result))
        throw new Error(`legacy id survived rewrite: ${id}`);
}

const beforeLines = original.split("\n").length;
const afterLines = result.split("\n").length;
console.log(
    `${apply ? "pruned" : "would prune"} ${removals.length} components: `
        + `${beforeLines} -> ${afterLines} lines, `
        + `${original.length} -> ${result.length} bytes`,
);
console.log(removals.map(removal => removal.id).reverse().join("\n"));

if (apply)
    fs.writeFileSync(target, result);
