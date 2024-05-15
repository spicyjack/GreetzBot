# GreetzBot #

A tech demo of [Vapor](https://vapor.codes) that includes Vapor
[Queues](https://github.com/vapor/queues), and localization using the
[Lingo](https://github.com/miroslavkovac/Lingo) library (using the bridge
library [Lingo Vapor](https://github.com/vapor-community/Lingo-Vapor)).

This tech demo is a "Telegram Bot", or a program that responds to incoming
Telegram API messages, processes those messages, and then replies to the
incoming messages using a separate API request via a Queue job.

The bot is currently "localized" to English and Russian.

The outbound Telegram API message queue is currently configured to use
PostgreSQL.  [Queues](https://github.com/vapor/queues) can use any database
supported by [Fluent](https://github.com/vapor/fluent), or you can use _Redis_,
which is what _Queues_ was originally designed to use and is the "official"
driver for _Queues_.

The bot also checks for and escapes any characters that can be interpreted as
Markdown markup characters, based on [Telegram's Markdown formatting
schema](https://core.telegram.org/bots/api#formatting-options).  If you do not
correctly escape any Markdown formatting in your bot API messages, then the
API server will usually reject your API message with an HTTP 400 message,
saying that there is unescaped Markdown tokens in the message.

## Running the Bot ##
Send a message to _BotFather_ on Telegram, and ask it to create a new bot.

You will receive an Telegram API key, which you need to add to the file `.env`
in the root of this repo.  You can use the file `env.txt` as a template for
creating this `.env` file, and fill it out with the appropriate information.

## Responding to Telegram API Messages ##
The [Telegram Bot FAQ](https://core.telegram.org/bots/faq) has a diagram that
shows the two methods of responding to API requests.

1. You can respond either directly to the API request from the Telegram server
with a new API message, or
2. Or you can send a Telegram API message in a separate HTTP request to the
Telegram API servers

The advantage of #2, sending the API message in a separate HTTP request, is
that if there is a problem with the formatting of the Telegram API message the
bot is trying to send to the API server, you will get an error response from
the API server explaining the issue.  If you reply directly to the API request
from the Telegram server, if there is an error, you will never find out what
the issue is.

## Links ##
- [Vapor](https://vapor.codes/)
   - [Vapor Docs](https://docs.vapor.codes/) - pretty much all of the Vapor
     support libraries (_Fluent_, _Queues_, etc.) is documented here and not
     in their respective GitHub repos below.
   - [Fluent](https://github.com/vapor/fluent), Vapor's ORM
   - [Vapor Queues](https://github.com/vapor/queues), which can use either
     _Redis_ or _Fluent_ for persisting queue messages.
   - [Lingo](https://github.com/miroslavkovac/Lingo) - A localization library
   - [Lingo Vapor](https://github.com/vapor-community/Lingo-Vapor)
     connector/injector
- Telegram Docs
   - [Telegram Bot API](https://core.telegram.org/bots/api)
   - [Telegram Bots: An Introduction for Developers](https://core.telegram.org/bots)
   - [Telegram Bot Features](https://core.telegram.org/bots/features)
   - [Telegram Bot FAQ](https://core.telegram.org/bots/faq) - this FAQ has a
     diagram that shows the two methods of responding to API requests (see
     section above)

