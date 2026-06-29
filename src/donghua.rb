# donghua.rb
require 'httparty'

module Handlers
  module Donghua
    DM_API = "https://api.dailymotion.com"
    BILI_API = "https://api.bilibili.com/x/web-interface/search/type"
    CODES_FILE = "codes.txt"

    def self.register(bot)
      bot.hears('📺 Donghua') do |ctx|
        ctx.session[:waiting_for] = 'donghua'
        ctx.reply(
          "📺 *Search Donghua*\n\n" \
          "Send me the donghua name and your code in one message:\n\n" \
          "Example: `Mo Dao Zu Shi 12345`",
          parse_mode: "Markdown"
        )
      end

      bot.on(:message, chat_type: 'private') do |ctx|
        next unless ctx.session[:waiting_for] == 'donghua'
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
            "Usage: `Donghua Name 12345`",
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

        # Search both sources
        dm_video = search_dailymotion(name)
        bili_video = search_bilibili(name)

        if dm_video.nil? && bili_video.nil?
          ctx.reply(
            "❌ *#{name}* not found on any server.\n\n" \
            "Try another title.",
            parse_mode: "Markdown"
          )
          next
        end

        # Build watch link with both IDs
        dm_param = dm_video ? "dm=#{dm_video[:id]}" : ""
        bili_param = bili_video ? "bil=#{bili_video[:id]}" : ""
        watch_link = "https://tomoviestv.netlify.app/donghua.html?#{dm_param}&#{bili_param}"

        # Build message showing both sources
        sources = []
        sources << "🎬 *Dailymotion:* #{dm_video[:title]}" if dm_video
        sources << "📺 *Bilibili:* #{bili_video[:title]}" if bili_video

        message = <<~MSG
          ✅ *#{name}*

          #{sources.join("\n")}

          🔗 Switch between servers in player!
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

    def self.search_dailymotion(name)
      response = HTTParty.get(
        "#{DM_API}/videos",
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
        title: v["title"]
      }
    rescue => e
      nil
    end

    def self.search_bilibili(name)
      response = HTTParty.get(
        BILI_API,
        query: {
          keyword: name,
          search_type: "media_bangumi"
        },
        headers: {
          "User-Agent" => "Mozilla/5.0",
          "Referer" => "https://search.bilibili.com"
        }
      )

      return nil unless response.success?

      data = response.parsed_response
      return nil unless data["data"]["result"]

      result = data["data"]["result"].first
      return nil unless result

      {
        id: result["season_id"],
        title: result["title"].gsub(/<[^>]+>/, '')
      }
    rescue => e
      nil
    end
  end
end
