const puppeteer = require('puppeteer-core');

const defaultConfig = {
  executablePath: '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
  // devtools: true,
  defaultViewport: null,
  headless: false,
  userDataDir: '/tmp/data',
  args: [
    '--disable-extensions-except=/Users/igor/Projects/ifood-party/server/uBlock0.chromium',
    '--load-extension=/Users/igor/Projects/ifood-party/server/uBlock0.chromium',
  ],
};

async function workMyCollection(asyncFunc, arr) {
  let final = {};
  await arr.reduce((promise, item) => {
    return promise
      .then(() => asyncFunc(item))
      .catch(console.error);
  }, Promise.resolve());
  return final;
}

async function setUpAddToCart(cookies, url) {
  const browser = await puppeteer.launch(defaultConfig);
  const page = await browser.newPage();

  cookies.forEach(async (c) => {
    await page.setCookie({
      name: c[0],
      value: c[1],
      domain: 'www.ifood.com.br',
      path: '/',
    });
  });

  await page.goto('https://www.ifood.com.br/minha-conta/enderecos', { waitUntil: 'networkidle0' });

  await Promise.all([
    page.waitForNavigation({ waitUntil: 'networkidle0' }),
    page.click('[data-lid="13237266"]'),
  ]);

  await page.goto(url, { waitUntil: 'networkidle0' });

  return page;
};

async function addToCart(page, entry) {
  await page.click(`#item-${entry.dishId}`);
  await page.waitFor(2000);

  let index = 0;
  await workMyCollection(async (options) => {
    await workMyCollection((option) => page.click(`.li-garnish-${option} .ico-plus`), options);
    await page.click(`#btn_${index}`);
    index++;
    await page.waitFor(500);
  }, entry.garnishes);
};



const cookies = process.env.IFOOD_COOKIE.split(/; ?/).map((c) => c.split('='));
const entry = {
  dishId: '38178309',
  garnishes: [['38178322', '38178310'], [], [], []],
}
const url = 'https://www.ifood.com.br/delivery/sao-paulo-sp/now-burger-perdizes';

(async () => {
  const page = await setUpAddToCart(cookies, url);
  await addToCart(page, entry);

  await page.waitFor(120000);
  await browser.close();
})();
