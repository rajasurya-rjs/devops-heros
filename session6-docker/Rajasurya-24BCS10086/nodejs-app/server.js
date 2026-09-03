const express = require('express');
const os = require('os');

const app = express();
const PORT = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.send(`<!DOCTYPE html>
<html>
  <head><title>Node.js Hello World</title></head>
  <body style="font-family: sans-serif; text-align: center; margin-top: 80px;">
    <h1>Hello World from Node.js!</h1>
    <p>Running inside a Docker container</p>
    <p>container hostname: ${os.hostname()}</p>
    <p>node version: ${process.version}</p>
  </body>
</html>`);
});

app.get('/health', (req, res) => res.json({ status: 'ok', app: 'nodejs-app' }));

app.listen(PORT, '0.0.0.0', () => {
  console.log(`nodejs-app listening on port ${PORT}`);
});
