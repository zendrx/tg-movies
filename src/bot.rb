# bot.rb
require 'telegem'
require 'httparty'
require_relative 'start'
require_relative 'search'
require_relative 'watch'
require_relative 'account'
require_relative 'admin'
require_relative 'help'

bot = Telegem.new(ENV['BOT_TOKEN'])

Handlers::Start.register(bot)
Handlers::Search.register(bot)
Handlers::Watch.register(bot)
Handlers::Account.register(bot)
Handlers::Admin.register(bot)
Handlers::Help.register(bot)

bot.start_polling
