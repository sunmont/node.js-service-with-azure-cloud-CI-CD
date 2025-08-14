import Bull from 'bull';
import { config } from './config';
import { uploadToSftp } from './sftpService';

export const fileQueue = new Bull('file-uploads', {
  redis: { host: config.redis.host, port: config.redis.port }
});

fileQueue.process(async (job) => {
  const { localPath, remoteName } = job.data;
  await uploadToSftp(localPath, remoteName);
});