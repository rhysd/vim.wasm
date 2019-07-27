const path = require('path');
const puppeteer = require('puppeteer');
const { createServer } = require('http-server');
const { imgDiff } = require('img-diff-js');

const SCREENSHOT_PATH = path.join(__dirname, 'actual', 'screenshot.png');

function wait(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

function server(port) {
    const root = path.join(__dirname, '..');
    const server = createServer({ root });
    server.listen(port);
    return server;
}

async function takeScreenshot(browser, port) {
    const page = await browser.newPage();
    try {
        page.setViewport({ width: 640, height: 320 });
        await page.goto(`http://localhost:${port}/vtest/index.html`);
        await wait(3000);

        await page.screenshot({ path: SCREENSHOT_PATH });
    } finally {
        await page.close();
    }
}

async function capture(port) {
    const browser = await puppeteer.launch({ args: ['--no-sandbox', '--disable-setuid-sandbox'] });
    try {
        await takeScreenshot(browser, port);
    } finally {
        await browser.close();
    }
}

async function test() {
    const diffFile = path.join(__dirname, 'diff.png');
    const expectedFile = path.join(__dirname, 'expected', 'screenshot.png');
    const result = await imgDiff({
        actualFilename: SCREENSHOT_PATH,
        expectedFilename: expectedFile,
        diffFilename: diffFile,
    });

    if (result.imagesAreSame) {
        console.error('SUCCESS');
        return 0;
    }

    console.error(`FAIL: ${result.diffCount} diffs found in ${result.width}x${result.height} image`);
    console.error(`  - See ${diffFile} for the diffs`);
    console.error(`  - See ${SCREENSHOT_PATH} for the actual screenshot`);
    console.error(`  - See ${expectedFile} for the expected screenshot`);
    return 1;
}

async function main() {
    const port = 5963;
    const s = server(port);
    try {
        await capture(port);
    } finally {
        s.close();
    }
    const code = await test();
    process.exit(code);
}

main().catch(console.error);
