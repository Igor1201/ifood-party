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
    id: await node.$eval('.result-text a[id*="item-"]', (node) => node.id.replace(/item-/, '')),
    image: await node.$eval('.photo-item img', (node) => node.src).catch(() => undefined),
    name: await node.$eval('.text-wrap h4', (node) => node.innerText.trim()),
    description: await node.$eval('.text-wrap p', (node) => node.innerText.trim()).catch(() => undefined),
    price: parseFloat(await node.$eval('.result-actions span', (node) => node.innerText.trim().match(/(\d+,\d+)$/)[1].replace(/,/, '.'))),
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

async function getAllItems(url) {
  const browser = await puppeteer.launch(defaultConfig);
  const page = await browser.newPage();
  await page.goto(url);
  
  const items = await page.$$('.result')
    .then((nodes) => Promise.all(nodes.map(nodeToItem)));

  await browser.close();

  return items;
}

async function click(page, selector) {
  await page.evaluate((selector) => document.querySelector(selector).click(), selector);
}

async function getGarnishTab(tab) {
  return {
    min: await tab.$eval('[name="minGarnish"]', (node) => parseInt(node.value)),
    max: await tab.$eval('[name="maxGarnish"]', (node) => parseInt(node.value)),
    options: await tab.$$('li[class*="li-garnish"]').then((nodes) => Promise.all(nodes.map(nodeToGarnish))),
  };
}

async function getSingleGarnish(page, item) {
  await click(page, `#item-${item.id}`);
  return page.waitFor('#garnish', { timeout: 2000 })
    .then(async () => {
      await page.waitFor(500);

      const garnishes = await page.$$('div[id*="garnish-tab"]')
        .then((tabs) => Promise.all(tabs.map(getGarnishTab)));

      await click(page, 'button#cboxClose');
      await click(page, 'div.closeBtn');

      await page.waitFor(500);

      return { key: item.id, value: { ...item, garnishes } };
    })
    .catch(async () => {
      await click(page, 'div.closeBtn');
      return { key: item.id, value: item };
    });
}

async function fakeGetAllItems(url) {
  return [
    {
      'id': '26362040',
      'image': 'https://static-images.ifood.com.br/image/upload/f_auto,t_thumbnail/pratos/e0bf90d6-2690-40e8-ab06-4d130014ace3/201804201010_26362040.jpg',
      'name': 'Fritas 🍟',
      'description': 'Porção de fritas levemente salgada.',
      'price': 10.3,
    },
    {
      'id': '43893618',
      'image': 'https://static-images.ifood.com.br/image/upload/f_auto,t_thumbnail/pratos/e0bf90d6-2690-40e8-ab06-4d130014ace3/201807041943_26417362.JPG',
      'name': 'Single Bacon Burger (não vai queijo) 🍔🥓',
      'description': '100% ANGUS BEEF - SEM CONSERVANTES - um hambúrguer 120g, pão de hambúrguer com gergelim, bacon e mais 13 molhos grátis a sua escolha',
      'price': 21.9,
    },
  ];
}

async function getRestaurantData(url) {
  return getAllItems(url)
    .then(async (allItems) => {
      const browser = await puppeteer.launch(defaultConfig);
      const page = await browser.newPage();
      await page.goto(url, { waitUntil: 'networkidle0' });

      const fullItems = Object.values(await workMyCollection((item) => getSingleGarnish(page, item), allItems));

      await browser.close();

      return fullItems;
    });
}

getRestaurantData('https://www.ifood.com.br/delivery/sao-paulo-sp/now-burger-perdizes').then(a => console.log(JSON.stringify(a)));

// getAllItems().then(console.log);

// (async () => {
//   const data = require('./data.json');

//   console.log(data.map((i) => `${i.id}, ${i.price}, ${i.name}`));
// })();
