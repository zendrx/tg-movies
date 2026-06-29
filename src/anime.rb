# anime.rb
require 'httparty'

module Handlers
  module Anime
    API_BASE = "https://api.4animo.xyz"
    CODES_FILE = "codes.txt"

    def self.register(bot)
      bot.hears('🎬 Anime') do |ctx|
        ctx.session[:waiting_for] = 'anime'
        ctx.reply(
          "🎬 *Search Anime*\n\n" \
          "Send me the anime name and your code in one message:\n\n" \
          "Example: `Attack on Titan 12345`",
          parse_mode: "Markdown"
        )
      end

      bot.on(:message, chat_type: 'private') do |ctx|
        next unless ctx.session[:waiting_for] == 'anime'
        next if ctx.text&.start_with?('/')

        text = ctx.text&.strip
        if text.nil? || text.empty?
          ctx.reply("❌ Please send a valid name and code.")
          next
        end

        parts = text.split(' ')
        if parts.length < 2
          ctx.reply(
            "❌ Invalid format.\n\n" \
            "Usage: `Anime Name 12345`",
            parse_mode: "Markdown"
          )
          next
        end

        code = parts.last
        name = parts[0...-1].join(' ')

        unless valid_code?(code)
          ctx.reply(
            "❌ Invalid code. Get a valid code from @tgtomovies2",
            parse_mode: "Markdown"
          )
          next
        end

        ctx.session.delete(:waiting_for)
        ctx.typing

        anime = search_anime(name)

        if anime.nil?
          ctx.reply(
            "❌ *#{name}* not found.\n\n" \
            "Try another title.",
            parse_mode: "Markdown"
          )
          next
        end

        watch_link = "https://tomoviestv.netlify.app/anime.html?id=#{anime[:id]}&ep=1"

        message = <<~MSG
          ✅ *#{anime[:title]}*

          📺 *Type:* #{anime[:type] || 'TV'}
          🎬 *Episodes:* #{anime[:episodes] || 'N/A'}
          ⭐ *Status:* #{anime[:status] || 'N/A'}
        MSG

        keyboard = Telegem.inline do
          row url("▶️ Watch Episode 1", watch_link)
        end

        ctx.reply(message, parse_mode: "Markdown", reply_markup: keyboard)
      end
    end

    private

    def self.valid_code?(code)
      return false unless File.exist?(CODES_FILE)
      File.readlines(CODES_FILE).map(&:strip).include?(code)
    end

    def self.search_anime(name)
      response = HTTParty.get(
        "#{API_BASE}/api/v2/hianime/search",
        query: { q: name }
      )

      return nil unless response.success?

      data = response.parsed_response
      return nil unless data["success"]
      return nil if data["data"]&.empty?

      anime = data["data"].first
      {
        id: anime["id"],
        title: anime["title"],
        type: anime["type"],
        episodes: anime["episodes"]&.dig("sub"),
        status: anime["status"]
      }
    rescue => e
      nil
    end
  end
end
