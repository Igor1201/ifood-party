const https = require('https');
const fs = require('fs');
const fetch = require('node-fetch');
const childProcess = require('child_process');

const agent = new https.Agent({
  key: fs.readFileSync(`${process.env.CLIENT_AUTH_PROD}/key.pem`),
  cert: fs.readFileSync(`${process.env.CLIENT_AUTH_PROD}/cert.pem`),
});
const token = JSON.parse(childProcess.execSync(`cat ${process.env.CLIENT_AUTH_PROD}/NuUser_DataSource | base64 -D -i -`).toString()).access_token;
const requestMoneyMutation = `
mutation createMoneyRequest_createMoneyRequestMutation(
    $input: CreateMoneyRequestInput!
  ) {
    createMoneyRequest(input: $input) {
      moneyRequest {
        id
        amount
        message
        url
    }
  }
}
`;

async function requestMoney(amount) {
  return await fetch(process.env.STORMSHIELD_URL, {
    method: 'POST',
    headers: {
      'Accept': 'application/json',
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    },
    agent,
    body: JSON.stringify({
      'query': requestMoneyMutation,
      'variables': {
        'input': {
          'amount': amount,
          'savingsAccountId': process.env.SAVINGS_ACCOUNT_ID,
          'message': process.env.REQUEST_MONEY_MESSAGE,
        },
      },
    }),
  }).then(res => res.json())
  .then(r => r.data.createMoneyRequest.moneyRequest);
}

module.exports = requestMoney;
