# AppleMusicAnimeBot

This program uses **Apple Music API** to requests album id by id. Find Anime albums and post it on Twitter and Mastodon.

## Apple Music (Swift)

To access Apple Music API, you need a **Developer Account** and generate a **token**. 

You can follow [Apple's documentation](https://developer.apple.com/documentation/applemusicapi/getting_keys_and_creating_tokens) to get set up.  
I recommend use [apple-music-token-generator](https://github.com/pelauimagineering/apple-music-token-generator) to hurry up production, it's very easy to get tokens.

Once you got a token. Put it in `Sources/Token.swift`.

Then you can start it with: 

```
swift run
```

If you are getting this error (bug [SR-8017](https://bugs.swift.org/browse/SR-8017)), try using Swift 4.2 or higher version.

```
Fatal error: Trying to access a behaviour for a task that in not in the registry.: file
Foundation/URLSession/TaskRegistry.swift, line 105
Illegal instruction
```

Build & Run

```
$ swift build -c release 
warning: PackageDescription API v3 is deprecated and will be removed in the future; used by package(s): SwiftClibxml2, Cider
Compile Swift Module 'Kanna' (6 sources)
Compile Swift Module 'Cider' (22 sources)
Compile Swift Module 'AppleMusicAnime' (5 sources)
Linking ./.build/armv7-unknown-linux-gnueabihf/release/AppleMusicAnime
$ ./.build/release/AppleMusicAnime
```

## Twitter (python)

You need a [Twitter App](https://apps.twitter.com) for your bot account to post Tweets via API.  
You'll need **Consumer Key**, **Consumer Secret**, **Access Token** and **Access Token Secret**.

Edit `Twitter/tweet.py` and enter the information.

Install dependency [tweepy](https://github.com/tweepy/tweepy).

```
pip install tweepy
```

Post a test Tweet via API:

```
python Twitter/tweet.py "Hello, World!"
```

Edit `Sources/main.swift`, comment out the following code to stop tweeting.

```
shell("python", "Twitter/tweet.py", contentText)
```

## Mastodon (python)

Mastodon is much easier than Twitter, you just need a Mastodon account.

Edit `Mastodon/setup.py`, change username, password, url(Mastodon instance).

`Mastodon/cred.txt` and `Mastodon/cred.txt` will be generated with:

```
python Mastodon/setup.py
```

Install dependency [Mastodon.py](https://github.com/halcy/Mastodon.py)

```
pip install Mastodon.py
```

If you failed to install `cryptography` on Raspbian Jessy. See [this page](https://raspberrypi.stackexchange.com/q/62364).

Change `api_base_url` in `Mastodon/toot.py`.

Post a test toot:

```
python Mastodon/toot.py "Hello, World!"
```

Edit `Sources/main.swift`, comment out the following code to stop tooting.

```
shell("python", "Mastodon/toot.py", contentText)
```
