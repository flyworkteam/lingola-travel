// Social Authentication Utilities
const { OAuth2Client } = require('google-auth-library');
const appleSignin = require('apple-signin-auth');
const axios = require('axios');

/**
 * Verify Google ID Token
 */
async function verifyGoogleToken(idToken) {
  try {
    const clientIds = [
      process.env.GOOGLE_CLIENT_ID_IOS,
      process.env.GOOGLE_CLIENT_ID_ANDROID,
      process.env.GOOGLE_CLIENT_ID_WEB
    ].filter(Boolean);
    
    if (clientIds.length === 0) {
      console.error('No Google Client IDs configured');
      return null;
    }
    
    const client = new OAuth2Client();
    
    const ticket = await client.verifyIdToken({
      idToken: idToken,
      audience: clientIds
    });
    
    const payload = ticket.getPayload();
    
    return {
      sub: payload.sub, // Unique Google user ID
      email: payload.email,
      email_verified: payload.email_verified,
      name: payload.name,
      picture: payload.picture,
      given_name: payload.given_name,
      family_name: payload.family_name
    };
  } catch (error) {
    console.error('Google token verification error:', error);
    return null;
  }
}

/**
 * Verify Apple Identity Token
 */
async function verifyAppleToken(identityToken) {
  try {
    const appleIdTokenClaims = await appleSignin.verifyIdToken(identityToken, {
      audience: process.env.APPLE_CLIENT_ID,
      nonce: 'nonce_if_used' // Optional: verify nonce if you use one
    });
    
    return {
      sub: appleIdTokenClaims.sub, // Unique Apple user ID
      email: appleIdTokenClaims.email,
      email_verified: appleIdTokenClaims.email_verified === 'true'
    };
  } catch (error) {
    console.error('Apple token verification error:', error);
    return null;
  }
}

/**
 * Verify Facebook Access Token
 */
async function verifyFacebookToken(accessToken) {
  try {
    // Verify token with Facebook Graph API
    const appAccessToken = `${process.env.FACEBOOK_APP_ID}|${process.env.FACEBOOK_APP_SECRET}`;
    
    const debugResponse = await axios.get(
      `https://graph.facebook.com/debug_token?input_token=${accessToken}&access_token=${appAccessToken}`
    );
    
    if (!debugResponse.data.data.is_valid) {
      return null;
    }
    
    // Get user profile
    const profileResponse = await axios.get(
      `https://graph.facebook.com/me?fields=id,email,name,picture&access_token=${accessToken}`
    );
    
    const profile = profileResponse.data;
    
    return {
      sub: profile.id, // Unique Facebook user ID
      email: profile.email,
      name: profile.name,
      picture: profile.picture?.data?.url
    };
  } catch (error) {
    console.error('Facebook token verification error:', error);
    return null;
  }
}

module.exports = {
  verifyGoogleToken,
  verifyAppleToken,
  verifyFacebookToken
};
