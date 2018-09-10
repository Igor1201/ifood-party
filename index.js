const puppeteer = require('puppeteer-core');

async function workMyCollection(asyncFunc, arr) {
  let final = {};
  await arr.reduce((promise, item) => {
    return promise
      .then(() => asyncFunc(item).then(result => final[result.key] = result.value))
      .catch(console.error);
  }, Promise.resolve());
  return final;
}

async function nodeToItem(node) {
  return {
    id: await node.$eval('input[name="code"]', (node) => node.value),
    name: await node.$eval('input[name="description"]', (node) => node.value),
    price: parseFloat(await node.$eval('input[name="unitPrice"]', (node) => node.value)),
  }
}

async function nodeToGarnish(node) {
  return {
    id: await node.$eval('input.codeGarnishItemClass', (node) => node.value),
    name: await node.$eval('input[name="descriptionGarnishItem"]', (node) => node.value),
  }
}

const defaultConfig = {
  executablePath: '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
  devtools: true,
  userDataDir: '/tmp/data',
  args: [
    '--disable-extensions-except=/Users/igor/Projects/ifood-party/uBlock0.chromium',
    '--load-extension=/Users/igor/Projects/ifood-party/uBlock0.chromium',
  ],
};

async function getAllItems() {
  const browser = await puppeteer.launch(defaultConfig);
  const page = await browser.newPage();
  await page.goto('https://www.ifood.com.br/delivery/sao-paulo-sp/now-burger-perdizes');
  
  const items = await page.$$('form[id*="form"]')
    .then((nodes) => Promise.all(nodes.map(nodeToItem)));

  await browser.close();

  return items;
}

async function click(page, selector) {
  await page.evaluate((selector) => document.querySelector(selector).click(), selector);
}

async function getSingleGarnish(page, item) {
  console.log(`Getting single ${item.id}`);
  await click(page, `#item-${item.id}`);
  return page.waitFor('#garnish', { timeout: 2000 })
    .then(async () => {
      const garnishes = await page.$$('div[id*="garnish-tab"]')
        .then((tabs) => Promise.all(tabs.map((tab) => tab.$$('li[class*="li-garnish"]'))))
        .then((tabs) => Promise.all(tabs.map((nodes) => Promise.all(nodes.map(nodeToGarnish)))));

      await click(page, 'button#cboxClose');
      await click(page, 'div.closeBtn');

      return { key: item.id, value: { ...item, garnishes } };
    })
    .catch(async () => {
      await click(page, 'div.closeBtn');
      return { key: item.id, value: item };
    });
}

// getAllItems().then(console.log);

getAllItems()
  .then(async (allItems) => {
    const browser = await puppeteer.launch(defaultConfig);
    const page = await browser.newPage();
    await page.goto('https://www.ifood.com.br/delivery/sao-paulo-sp/now-burger-perdizes', { waitUntil: 'networkidle0' });

    const fullItems = await workMyCollection((item) => getSingleGarnish(page, item), allItems);

    console.log(JSON.stringify(Object.values(fullItems)));

    await browser.close();
  });
