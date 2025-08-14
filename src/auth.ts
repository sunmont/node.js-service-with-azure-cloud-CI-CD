import * as oauth from 'oauth4webapi';
import * as jose from 'jose';
import { config } from './config';
import { Request, Response, NextFunction } from 'express';

// Define a type for our expected claims to improve type safety.
interface AppClaims {
  iss?: string;
  sub?: string;
  aud?: string | string[];
  exp?: number;
  iat?: number;
  scp?: string;
  roles?: string[];
  [key: string]: unknown; // Allow other claims
}

// Cache for the authorization server configuration
let authServerConfigPromise: Promise<oauth.AuthorizationServer>;

async function getAuthServerConfig(): Promise<oauth.AuthorizationServer> {
  if (!authServerConfigPromise) {
    authServerConfigPromise = (async () => {
      try {
        console.log('Discovering authorization server configuration...');
        const issuerUrl = new URL(config.azure.issuer);
        const authServer = await oauth.discoveryRequest(issuerUrl);
        const authServerConfig = await oauth.processDiscoveryResponse(issuerUrl, authServer);
        console.log('Discovered Authorization Server:', authServerConfig.issuer);
        return authServerConfig;
      } catch (error) {
        console.error('Failed to discover authorization server. It will be retried on the next request.', error);
        // Reset the promise so it can be retried
        authServerConfigPromise = undefined as any;
        throw error;
      }
    })();
  }
  return authServerConfigPromise;
}

// Cache for JWKS
let jwksPromise: Promise<jose.GetKeyFunction<jose.JWTHeaderParameters, jose.FlattenedJWSInput>>;

async function getJWKS(): Promise<jose.GetKeyFunction<jose.JWTHeaderParameters, jose.FlattenedJWSInput>> {
  if (!jwksPromise) {
    jwksPromise = (async () => {
      try {
        const authServer = await getAuthServerConfig();
        if (!authServer.jwks_uri) {
          throw new Error('No JWKS URI found in authorization server metadata');
        }
        
        const jwks = jose.createRemoteJWKSet(new URL(authServer.jwks_uri));
        return jwks;
      } catch (error) {
        console.error('Failed to create JWKS. It will be retried on the next request.', error);
        // Reset the promise so it can be retried
        jwksPromise = undefined as any;
        throw error;
      }
    })();
  }
  return jwksPromise;
}

// Extend Express's Request type to include the user claims
declare global {
  namespace Express {
    export interface Request {
      user?: AppClaims;
    }
  }
}

export async function verifyToken(req: Request, res: Response, next: NextFunction) {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).send('Unauthorized: Missing or invalid Authorization header.');
    }

    const token = authHeader.substring(7); // "Bearer ".length

    // Get the authorization server configuration and JWKS
    const [authServer, getKey] = await Promise.all([
      getAuthServerConfig(),
      getJWKS()
    ]);

    // Verify the JWT token
    // Note: You may need to adjust the audience based on your Azure AD configuration
    // Common options: config.azure.clientId, config.azure.issuer, or a specific audience from your token
    const { payload } = await jose.jwtVerify(token, getKey, {
      issuer: authServer.issuer,
      // audience: 'your-client-id-here', // Uncomment and set the correct audience if needed
      clockTolerance: '5s', // Allow 5 seconds of clock skew
    });

    const claims = payload as AppClaims;
    const scopes = (claims.scp || '').split(' ').filter(s => s.length > 0);
    const roles = claims.roles || [];

    // Authorization Check: Ensure the token has at least one of the required scopes and roles.
    if (config.azure.allowedScopes.length > 0 && !config.azure.allowedScopes.some(s => scopes.includes(s))) {
      return res.status(403).send('Forbidden: Insufficient scope.');
    }
    if (config.azure.allowedRoles.length > 0 && !config.azure.allowedRoles.some(r => roles.includes(r))) {
      return res.status(403).send('Forbidden: Insufficient role.');
    }

    // Attach claims to the request object for downstream use
    req.user = claims;
    next();
  } catch (err: any) {
    console.error('Token verification failed:', err.message);
    
    // Provide more specific error messages based on the error type
    if (err.code === 'ERR_JWT_EXPIRED') {
      return res.status(401).send('Unauthorized: Token has expired.');
    }
    if (err.code === 'ERR_JWT_INVALID') {
      return res.status(401).send('Unauthorized: Invalid token format.');
    }
    if (err.code === 'ERR_JWS_SIGNATURE_VERIFICATION_FAILED') {
      return res.status(401).send('Unauthorized: Token signature verification failed.');
    }
    
    res.status(401).send('Unauthorized: Invalid token.');
  }
}