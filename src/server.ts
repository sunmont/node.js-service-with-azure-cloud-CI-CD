import express from 'express';
import restUpload from './routes/restUpload';
import { setupSoap } from './routes/soapUpload';
import { config } from './config';
import fs from 'fs';
import path from 'path';

const tmpDir = path.join(__dirname, '../tmp');
if (!fs.existsSync(tmpDir)) fs.mkdirSync(tmpDir);

const app = express();
app.use(express.json());
app.use('/api', restUpload);
setupSoap(app);

app.listen(config.port, () => {
  console.log(`Server running on port ${config.port}`);
});