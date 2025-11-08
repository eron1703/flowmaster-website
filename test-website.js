const puppeteer = require('puppeteer');
const fs = require('fs');
const path = require('path');

/**
 * FlowMaster Website Automated Testing
 * Tests all pages, captures screenshots, and rates design quality
 */

const BASE_URL = process.env.SITE_URL || 'http://localhost:8090';
const SCREENSHOT_DIR = path.join(__dirname, 'screenshots');

// Ensure screenshot directory exists
if (!fs.existsSync(SCREENSHOT_DIR)) {
    fs.mkdirSync(SCREENSHOT_DIR, { recursive: true });
}

const pages = [
    { name: 'Home', url: `${BASE_URL}/` },
    { name: 'Company', url: `${BASE_URL}/company/` },
    { name: 'Platform', url: `${BASE_URL}/platform/` },
    { name: 'Industries', url: `${BASE_URL}/industries/` },
    { name: 'Careers', url: `${BASE_URL}/careers/` },
    { name: 'Contact', url: `${BASE_URL}/contact/` },
];

async function testPage(browser, page, pageInfo) {
    console.log(`\n========================================`);
    console.log(`Testing: ${pageInfo.name}`);
    console.log(`URL: ${pageInfo.url}`);
    console.log(`========================================`);

    const newPage = await browser.newPage();
    await newPage.setViewport({ width: 1920, height: 1080 });

    const results = {
        name: pageInfo.name,
        url: pageInfo.url,
        accessible: false,
        loadTime: 0,
        errors: [],
        warnings: [],
        screenshot: null,
        rating: 0,
    };

    try {
        // Track console errors
        newPage.on('console', msg => {
            if (msg.type() === 'error') {
                results.errors.push(msg.text());
            } else if (msg.type() === 'warning') {
                results.warnings.push(msg.text());
            }
        });

        // Navigate and measure load time
        const startTime = Date.now();
        await newPage.goto(pageInfo.url, {
            waitUntil: 'networkidle2',
            timeout: 30000
        });
        results.loadTime = Date.now() - startTime;
        results.accessible = true;

        // Capture screenshot
        const screenshotPath = path.join(SCREENSHOT_DIR, `${pageInfo.name.toLowerCase()}.png`);
        await newPage.screenshot({
            path: screenshotPath,
            fullPage: true
        });
        results.screenshot = screenshotPath;

        // Get page title
        const title = await newPage.title();
        console.log(`  Title: ${title}`);
        console.log(`  Load Time: ${results.loadTime}ms`);

        // Check for basic quality indicators
        const hasImages = await newPage.$$eval('img', imgs => imgs.length > 0);
        const hasNavigation = await newPage.$$eval('nav', navs => navs.length > 0);
        const hasHeadings = await newPage.$$eval('h1, h2, h3', headings => headings.length > 0);

        console.log(`  Has Images: ${hasImages}`);
        console.log(`  Has Navigation: ${hasNavigation}`);
        console.log(`  Has Headings: ${hasHeadings}`);

        // Console errors/warnings
        console.log(`  Console Errors: ${results.errors.length}`);
        console.log(`  Console Warnings: ${results.warnings.length}`);

        if (results.errors.length > 0) {
            console.log(`  Error Details:`, results.errors.slice(0, 3));
        }

        // Calculate rating (1-10)
        let rating = 10;
        if (results.loadTime > 3000) rating -= 2;
        if (results.errors.length > 0) rating -= results.errors.length;
        if (!hasImages) rating -= 2;
        if (!hasNavigation) rating -= 2;
        if (!hasHeadings) rating -= 2;
        results.rating = Math.max(1, Math.min(10, rating));

        console.log(`  RATING: ${results.rating}/10`);
        console.log(`  Screenshot: ${screenshotPath}`);

    } catch (error) {
        console.log(`  ERROR: ${error.message}`);
        results.errors.push(error.message);
        results.rating = 1;
    } finally {
        await newPage.close();
    }

    return results;
}

async function main() {
    console.log('======================================== ');
    console.log('FlowMaster Website Automated Testing');
    console.log('========================================');
    console.log(`Testing ${pages.length} pages...`);
    console.log(`Base URL: ${BASE_URL}`);
    console.log('');

    const browser = await puppeteer.launch({
        headless: true,
        args: ['--no-sandbox', '--disable-setuid-sandbox']
    });

    const allResults = [];

    for (const pageInfo of pages) {
        const results = await testPage(browser, null, pageInfo);
        allResults.push(results);
        await new Promise(resolve => setTimeout(resolve, 1000)); // Wait 1s between tests
    }

    await browser.close();

    // Summary
    console.log('\n');
    console.log('========================================');
    console.log('TEST SUMMARY');
    console.log('========================================');

    const accessiblePages = allResults.filter(r => r.accessible).length;
    const averageLoadTime = allResults.reduce((sum, r) => sum + r.loadTime, 0) / allResults.length;
    const averageRating = allResults.reduce((sum, r) => sum + r.rating, 0) / allResults.length;
    const totalErrors = allResults.reduce((sum, r) => sum + r.errors.length, 0);

    console.log(`Pages Tested: ${pages.length}`);
    console.log(`Pages Accessible: ${accessiblePages}/${pages.length}`);
    console.log(`Average Load Time: ${Math.round(averageLoadTime)}ms`);
    console.log(`Total Console Errors: ${totalErrors}`);
    console.log(`Average Rating: ${averageRating.toFixed(1)}/10`);
    console.log('');

    console.log('Individual Ratings:');
    allResults.forEach(r => {
        const status = r.accessible ? 'OK' : 'FAIL';
        console.log(`  [${status}] ${r.name}: ${r.rating}/10 (${r.loadTime}ms)`);
    });

    console.log('');
    console.log('Screenshots saved to:', SCREENSHOT_DIR);

    // Save results to JSON
    const resultsPath = path.join(__dirname, 'test-results.json');
    fs.writeFileSync(resultsPath, JSON.stringify(allResults, null, 2));
    console.log('Results saved to:', resultsPath);

    // Overall assessment
    console.log('\n========================================');
    console.log('OVERALL ASSESSMENT');
    console.log('========================================');

    if (averageRating >= 9) {
        console.log('Status: EXCELLENT - Professional quality website');
    } else if (averageRating >= 7) {
        console.log('Status: GOOD - Minor improvements needed');
    } else if (averageRating >= 5) {
        console.log('Status: FAIR - Significant improvements needed');
    } else {
        console.log('Status: POOR - Major redesign required');
    }

    if (averageRating < 8) {
        console.log('\nRecommended improvements:');
        if (averageLoadTime > 3000) console.log('  - Optimize load time (currently >3s)');
        if (totalErrors > 0) console.log('  - Fix console errors');
        if (accessiblePages < pages.length) console.log('  - Fix inaccessible pages');
    }

    console.log('');
}

main().catch(console.error);
