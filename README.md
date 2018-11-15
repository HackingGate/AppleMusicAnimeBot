# AppleMusicAnimeBot

This program uses **Apple Music API** to requests album id by id. Find Anime albums and post it on Twitter and Mastodon.

## Apple Music (Swift 4.2)

To access Apple Music API, you need a **Developer Account** and generate a **token**. 

You can follow [Apple's documentation](https://developer.apple.com/documentation/applemusicapi/getting_keys_and_creating_tokens) to get set up.  
I recommend use [apple-music-token-generator](https://github.com/pelauimagineering/apple-music-token-generator) to hurry up production, it's very easy to get tokens.

Once you got a token. Put it in `Sources/Token.swift`.

Then you can start it with: 

```
swift run
```

## Twitter (python)

You need a [Twitter App](https://apps.twitter.com) for your bot account to post Tweets via API.  
You'll need `Consumer Key` `Consumer Secret` `Access Token` and `Access Token Secret`.

Edit `Twitter/tweet.py` and enter the information.

AppleMusicAnimeBot uses [tweepy](https://github.com/tweepy/tweepy) library.

```
pip install tweepy
```

Post a test Tweet via API:

```
python Twitter/tweet.py "Hello, World!"
```

## Mastodon (python)

Mastodon is much easier than Twitter, you just need a Mastodon account.

Edit `Mastodon/setup.py`, change username, password, url(Mastodon instance).

`Mastodon/cred.txt` and `Mastodon/cred.txt` will be generated with:

```
python setup.py
```

Change `api_base_url` in `Mastodon/toot.py`.

Post a test toot:

```
python Mastodon/toot.py "Hello, World!"
```
