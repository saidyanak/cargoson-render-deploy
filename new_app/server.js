const express = require('express');
const path = require('path');
const app = express();
const port = process.env.PORT || 8080;

// Sunulacak statik dosyaların klasörünü ayarla
app.use(express.static(path.join(__dirname, 'build/web')));

// Tüm diğer istekleri ana index.html dosyasına yönlendir (SPA için önemli)
app.get('*', (req, res) => {
  res.sendFile(path.resolve(__dirname, 'build/web', 'index.html'));
});

app.listen(port, () => {
  console.log('Server is running on port', port);
});