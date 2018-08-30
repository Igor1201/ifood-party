const puppeteer = require('puppeteer-core');

async function nodeToItem(node) {
  return {
    id: await node.$eval('input[name="code"]', (node) => node.value),
    name: await node.$eval('input[name="description"]', (node) => node.value),
    price: parseFloat(await node.$eval('input[name="unitPrice"]', (node) => node.value)),
  }
}

async function nodeToGarnish(node) {
  return {
    id: await node.$eval('input[name="codeGarnishItem"]', (node) => node.value),
    name: await node.$eval('input[name="descriptionGarnishItem"]', (node) => node.value),
  }
}

(async () => {
  const browser = await puppeteer.launch({ executablePath: '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome' });
  const page = await browser.newPage();
  await page.goto(`https://www.ifood.com.br/delivery/sao-paulo-sp/now-burger-perdizes`);
  await page.waitFor('body');
  
  await page.$$('form[id*="form"]')
    .then((nodes) => Promise.all(nodes.map(nodeToItem)))
    .then(console.log);

  await browser.close();
})();

(async () => {
  const browser = await puppeteer.launch({ executablePath: '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome' });
  const page = await browser.newPage();
  await page.goto(`https://www.ifood.com.br/delivery/sao-paulo-sp/now-burger-perdizes`);
  await page.waitFor('body');
  
  // await page.click('#item-38178309');
  await page.evaluate(() => {
    document.querySelector('#item-38178309').click();
  });

  await page.waitFor('#garnish');
  await page.$$('div[id*="garnish-tab"]')
    .then((tabs) => Promise.all(tabs.map((tab) => tab.$$('li[class*="li-garnish"]'))))
    .then((tabs) => Promise.all(tabs.map((nodes) => Promise.all(nodes.map(nodeToGarnish)))))
    .then(console.log);

  await browser.close();
})();
