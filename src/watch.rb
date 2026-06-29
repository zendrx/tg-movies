# watch.rb
require 'httparty'

module Handlers
  module Watch
    API_BASE = "https://api.dailymotion.com"
    CODES_FILE = "codes.txt"

    def self.register(bot)
      bot.command('watch') do |ctx|
        args = ctx.command_args&.strip

        if args.nil? || args.empty?
          ctx.reply(
            "🎬 *Watch a movie*\n\n" \
            "Usage: `/watch <movie name> <code>`\n" \
            "Example: `/watch the last blade of ming 12345`",
            parse_mode: "Markdown"
          )
          next
        end

        parts = args.split(' ')
        if parts.length < 2
          ctx.reply(
            "❌ Missing code.\n\n" \
            "Usage: `/watch <movie name> <code>`",
            parse_mode: "Markdown"
          )
          next
        end

        code = parts.last
        name = parts[0...-1].join(' ')

        unless valid_code?(code)
          ctx.reply(
            "❌ Invalid code. Get a valid code from the group.",
            parse_mode: "Markdown"
          )
          next
        end

        ctx.typing

        video = find_video(name)

        if video.nil?
          ctx.reply(
            "❌ *#{name}* not found.\n\n" \
            "Try `/search #{name}` first.",
            parse_mode: "Markdown"
          )
          next
        end

        watch_link = "https://tomoviestv.netlify.app/watch.html?id=#{video[:id]}"

        message = <<~MSG
          ✅ *#{video[:title]}*

          ⭐ Rating: #{video[:rating] || 'N/A'}
          👁 Views: #{format_views(video[:views])}
          ⏱ Duration: #{format_duration(video[:duration])}

          🔗 [Watch Now](#{watch_link})
        MSG

        ctx.reply(message, parse_mode: "Markdown", disable_web_page_preview: true)
      end
    end

    private

    def self.valid_code?(code)
      return false unless File.exist?(CODES_FILE)
      File.readlines(CODES_FILE).map(&:strip).include?(code)
    end

    def self.find_video(name)
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
