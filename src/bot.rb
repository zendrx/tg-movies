# bot.rb
require 'telegem'
require 'httparty'
require 'webrick'
require_relative 'start'
require_relative 'anime'
require_relative 'donghua'
require_relative 'account'
require_relative 'refer'
require_relative 'admin'
require_relative 'help'

bot = Telegem.new(ENV['BOT_TOKEN'])

Handlers::Start.register(bot)
Handlers::Anime.register(bot)
Handlers::Donghua.register(bot)
Handlers::Account.register(bot)
Handlers::Refer.register(bot)
Handlers::Admin.register(bot)
Handlers::Help.register(bot)

# Keep-alive web server
bot.start_polling
