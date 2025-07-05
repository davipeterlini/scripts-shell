const express = require('express');
const { Storage } = require('@google-cloud/storage');
const app = express();

const storage = new Storage();
const BUCKET_NAME = process.env.BUCKET_NAME; // nome do bucket

app.get('/download/:filename', async (req, res) => {
  const { filename } = req.params;
  const file = storage.bucket(BUCKET_NAME).file(filename);
  const [exists] = await file.exists();
  if (!exists) return res.status(404).send('Arquivo não encontrado');

  res.setHeader('Content-Disposition', `attachment; filename="${filename}"`);
  file.createReadStream().pipe(res);
});

const port = process.env.PORT || 8080;
app.listen(port, () => console.log(`App rodando na porta ${port}, bucket: ${BUCKET_NAME}`));
