import express from 'express';
import multer from 'multer';
import path from 'path';
import { fileQueue } from '../queue';
import { verifyToken } from '../auth';

const router = express.Router();
const upload = multer({ dest: path.join(__dirname, '../../tmp') });

router.post('/upload', verifyToken, upload.single('file'), async (req, res) => {
  if (!req.file) return res.status(400).send('No file');
  await fileQueue.add({ localPath: req.file.path, remoteName: req.file.originalname });
  res.send('File queued for upload');
});

export default router;