#! /usr/bin/env python
# -*- coding: utf-8 -*-

from mastodon import Mastodon

url = "https://pawoo.net"

Mastodon.create_app("AppleMusicAnimeBot",
    api_base_url = url,
    to_file = "Mastodon/cred.txt"
    )

mastodon = Mastodon(
    client_id="Mastodon/cred.txt",
    api_base_url = url
    )

mastodon.log_in(
    "xxx@xxx",
    "enter your password",
    to_file="Mastodon/auth.txt"
    )
