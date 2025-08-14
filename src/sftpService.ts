import Client from 'ssh2-sftp-client';
import fs from 'fs';
import { config } from './config';

export async function uploadToSftp(localPath: string, remoteName: string) {
  const sftp = new Client();
  await sftp.connect({
    host: config.sftp.host,
    port: config.sftp.port,
    username: config.sftp.user,
    password: config.sftp.pass
  });
  await sftp.put(localPath, `${config.sftp.remoteDir}/${remoteName}`);
  await sftp.end();
  fs.unlinkSync(localPath);
}