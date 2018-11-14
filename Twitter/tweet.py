#!/usr/bin/env python
# -*- coding: utf-8 -*-

import tweepy, sys

#enter the corresponding information from your Twitter application:
CONSUMER_KEY = ''
CONSUMER_SECRET = ''
ACCESS_KEY = ''
ACCESS_SECRET = ''
auth = tweepy.OAuthHandler(CONSUMER_KEY, CONSUMER_SECRET)
auth.set_access_token(ACCESS_KEY, ACCESS_SECRET)
api = tweepy.API(auth)

argString = str(sys.argv[1])

api.update_status(argString)

