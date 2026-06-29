# bot.rb
require 'telegem'
require 'httparty'
require 'logger'
require_relative 'start'
require_relative 'anime'
require_relative 'donghua'
require_relative 'account'
require_relative 'refer'
require_relative 'admin'
require_relative 'help'

logger = Logger.new($stdout)
logger.level = Logger::DEBUG

bot = Telegem.new(ENV['BOT_TOKEN'], logger: logger)

Handlers::Start.register(bot)
Handlers::Anime.register(bot)
Handlers::Donghua.register(bot)
Handlers::Account.register(bot)
Handlers::Refer.register(bot)
Handlers::Admin.register(bot)
Handlers::Help.register(bot)

logger.info "Bot starting..."
bot.start_polling
