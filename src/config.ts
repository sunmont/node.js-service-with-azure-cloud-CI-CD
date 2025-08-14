const dotenv = require('dotenv')

dotenv.config();

export const config = {
  port: process.env.PORT || 3000,
  azure: {
    issuer: process.env.AZURE_ISSUER!,
    jwksUri: process.env.AZURE_JWKS_URI!,
    allowedScopes: (process.env.AZURE_ALLOWED_SCOPES || '').split(','),
    allowedRoles: (process.env.AZURE_ALLOWED_ROLES || '').split(',')
  },
  redis: {
    host: process.env.REDIS_HOST || 'localhost',
    port: parseInt(process.env.REDIS_PORT || '6379')
  },
  sftp: {
    host: process.env.SFTP_HOST!,
    port: parseInt(process.env.SFTP_PORT || '22'),
    user: process.env.SFTP_USER!,
    pass: process.env.SFTP_PASS!,
    remoteDir: process.env.SFTP_REMOTE_DIR || '/uploads'
  }
};