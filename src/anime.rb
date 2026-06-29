# anime.rb
require 'httparty'

module Handlers
  module Anime
    API_BASE = "https://api.dailymotion.com"
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

        video = search_video(name)

        if video.nil?
          ctx.reply(
            "❌ *#{name}* not found.\n\n" \
            "Try another title.",
            parse_mode: "Markdown"
          )
          next
        end

        watch_link = "https://tomoviestv.netlify.app/anime.html?id=#{video[:id]}"

        message = <<~MSG
          ✅ *#{video[:title]}*

          ⭐ Rating: #{video[:rating] || 'N/A'}
          👁 Views: #{format_views(video[:views])}
          ⏱ Duration: #{format_duration(video[:duration])}
        MSG

        keyboard = Telegem.inline do
          row url("▶️ Watch Now", watch_link)
        end

        ctx.reply(message, parse_mode: "Markdown", reply_markup: keyboard)
      end
    end

    private

    def self.valid_code?(code)
      return false unless File.exist?(CODES_FILE)
      File.readlines(CODES_FILE).map(&:strip).include?(code)
    end

    def self.search_video(name)
      response = HTTParty.get(
        "#{API_BASE}/videos",
        query: {
          search: name,
          limit: 1,
          fields: "id,title,duration,views_total,rating"
        }
      )

      return nil unless response.success?

      data = response.parsed_response
      return nil if data["list"].nil? || data["list"].empty?

      v = data["list"].first
      {
        id: v["id"],
        title: v["title"],
        duration: v["duration"],
        views: v["views_total"],
        rating: v["rating"]
      }
    rescue => e
      nil
    end

    def self.format_views(num)
      return "N/A" unless num
      if num >= 1_000_000
        "#{(num / 1_000_000.0).round(1)}M"
      elsif num >= 1_000
        "#{(num / 1_000.0).round(1)}K"
      else
        num.to_s
      end
    end

    def self.format_duration(seconds)
      return "N/A" unless seconds
      min, sec = seconds.divmod(60)
      hr, min = min.divmod(60)
      hr > 0 ? "#{hr}h #{min}m" : "#{min}m"
    end
  end
end
