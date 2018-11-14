#! /usr/bin/env python
# -*- coding: utf-8 -*-
from mastodon import Mastodon
import sys

mastodon = Mastodon(
        client_id="Mastodon/cred.txt",
        access_token="Mastodon/auth.txt",
        api_base_url = "https://pawoo.net")

argString = str(sys.argv[1])

mastodon.toot(argString) 
