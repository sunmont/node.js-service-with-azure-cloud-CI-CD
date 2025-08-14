import soap from 'soap';
import fs from 'fs';
import path from 'path';
import { fileQueue } from '../queue';
import { verifyToken } from '../auth';
import { config } from '../config';
import { Application } from 'express';

export function setupSoap(app: Application) {
  const service = {
    FileService: {
      FilePort: {
        UploadFile: async (args: any) => {
          const buffer = Buffer.from(args.contentBase64, 'base64');
          const tmpPath = path.join(__dirname, '../../tmp', args.filename);
          fs.writeFileSync(tmpPath, buffer);
          await fileQueue.add({ localPath: tmpPath, remoteName: args.filename });
          return { status: 'Queued' };
        }
      }
    }
  };

  const wsdl = fs.readFileSync(path.join(__dirname, '../wsdl/upload.wsdl'), 'utf8');
  soap.listen(app, '/soap', service, wsdl);
}