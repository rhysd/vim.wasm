import * as path from 'path';
import { promises as fs } from 'fs';
import puppeteer = require('puppeteer');
import { createServer } from 'http-server';
import { imgDiff } from 'img-diff-js';
import open = require('open');

const SCREENSHOT_PATH = path.join(__dirname, 'actual.png');
const DIFF_PATH = path.join(__dirname, 'diff.png');
const EXPECTED_PATH = path.join(__dirname, 'expected.png');

function wait(ms: number) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

async function fileExists(file: string) {
    try {
        const s = await fs.stat(file);
        return s.isFile();
    } catch (_) {
        return false;
    }
}

function server(port: number) {
    const root = path.join(__dirname, '..');
    const server = createServer({ root });
    server.listen(port);
    return server;
}

async function takeScreenshot(browser: puppeteer.Browser, port: number) {
    const page = await browser.newPage();
    try {
        await page.setViewport({ width: 640, height: 320 });
        await page.goto(`http://localhost:${port}/vtest/index.html`);
        await wait(3000);

        await page.screenshot({ path: SCREENSHOT_PATH });
    } finally {
        await page.close();
    }
}

async function capture(port: number) {
    const browser = await puppeteer.launch({ args: ['--no-sandbox', '--disable-setuid-sandbox'] });
    try {
        await takeScreenshot(browser, port);
    } finally {
        await browser.close();
    }
}

async function check() {
    const result = await imgDiff({
        actualFilename: SCREENSHOT_PATH,
        expectedFilename: EXPECTED_PATH,
        diffFilename: DIFF_PATH,
        threshold: 0,
    });

    if (result.imagesAreSame) {
        console.error('SUCCESS');
        return 0;
    }

    console.error(`FAIL: ${result.diffCount} diffs found in ${result.width}x${result.height} image`);
    console.error(`  - See ${DIFF_PATH} for the diffs`);
    console.error(`  - See ${SCREENSHOT_PATH} for the actual screenshot`);
    console.error(`  - See ${EXPECTED_PATH} for the expected screenshot`);
    return 1;
}

async function firstTime() {
    await fs.copyFile(SCREENSHOT_PATH, EXPECTED_PATH);
    console.error('FAIL: Expected screenshot does not exist');
    console.error(`Please check a current screenshot ${SCREENSHOT_PATH} is fine manually`);
    console.error(`Since screenshot was copied to ${EXPECTED_PATH}, please remove it if it is not expected`);
    await open(SCREENSHOT_PATH);
}

async function main() {
    const port = 5963;
    const s = server(port);

    try {
        await capture(port);
    } finally {
        s.close();
    }

    if (!(await fileExists(EXPECTED_PATH))) {
        await firstTime();
        process.exit(1);
    }

    process.exit(await check());
}

main().catch(e => {
    console.error(e);
    process.exit(2);
});
