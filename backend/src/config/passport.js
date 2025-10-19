import passport from 'passport'
import { Strategy as FacebookStrategy } from 'passport-facebook'
import { Strategy as GoogleStrategy } from 'passport-google-oauth20'
import dotenv from 'dotenv'
import User from '../models/User.model.js'

dotenv.config()

// === FACEBOOK STRATEGY ===
passport.use(new FacebookStrategy({
  clientID: process.env.FACEBOOK_APP_ID,
  clientSecret: process.env.FACEBOOK_APP_SECRET,
  callbackURL: process.env.FACEBOOK_CALLBACK,
  profileFields: ['id', 'displayName', 'emails', 'name']
}, async (accessToken, refreshToken, profile, done) => {
  try {
    const email = profile.emails?.[0]?.value;
    if (!email) {
      return done(new Error('Facebook account does not have an email associated.'), null);
    }

    // 1. Find user by facebookId
    let user = await User.findOne({ facebookId: profile.id });
    if (user) {
      return done(null, user);
    }

    // 2. Find user by email and link account
    user = await User.findOne({ email: email });
    if (user) {
      user.facebookId = profile.id;
      // You might want to update the provider field as well
      // user.provider = 'facebook'; 
      await user.save();
      return done(null, user);
    }

    // 3. Create new user
    const newUser = new User({
      facebookId: profile.id,
      email: email,
      displayName: profile.displayName,
      firstName: profile.name?.givenName || profile.displayName.split(' ')[0],
      lastName: profile.name?.familyName || profile.displayName.split(' ').slice(1).join(' '),
      provider: 'facebook'
    });
    await newUser.save();
    return done(null, newUser);

  } catch (err) {
    return done(err, null);
  }
}))

// === GOOGLE STRATEGY ===
passport.use(new GoogleStrategy({
  clientID: process.env.GOOGLE_CLIENT_ID,
  clientSecret: process.env.GOOGLE_CLIENT_SECRET,
  callbackURL: process.env.GOOGLE_CALLBACK
}, async (accessToken, refreshToken, profile, done) => {
  try {
    const email = profile.emails?.[0]?.value;
    if (!email) {
      return done(new Error('Google account does not have an email associated.'), null);
    }

    // 1. Find user by googleId
    let user = await User.findOne({ googleId: profile.id });
    if (user) {
      return done(null, user);
    }

    // 2. Find user by email and link account
    user = await User.findOne({ email: email });
    if (user) {
      user.googleId = profile.id;
      // user.provider = 'google'; // Or update a providers array
      await user.save();
      return done(null, user);
    }

    // 3. Create new user
    const newUser = new User({
      googleId: profile.id,
      email: email,
      displayName: profile.displayName,
      firstName: profile.name?.givenName || profile.displayName.split(' ')[0],
      lastName: profile.name?.familyName || profile.displayName.split(' ').slice(1).join(' '),
      provider: 'google'
    });
    await newUser.save();
    return done(null, newUser);

  } catch (err) {
    return done(err, null);
  }
}))

passport.serializeUser((user, done) => {
  done(null, user.id)
})

passport.deserializeUser(async (id, done) => {
  try {
    const user = await User.findById(id)
    done(null, user)
  } catch (err) {
    done(err, null)
  }
})

export default passport
