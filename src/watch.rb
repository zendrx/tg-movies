# watch.rb
require 'httparty'
require 'cgi'

module Handlers
  module Watch
    API_BASE = "https://api.dailymotion.com"
    CODES_FILE = "codes.txt"

    def self.register(bot)
      bot.command('watch') do |ctx|
        args = ctx.command_args&.strip
        parts = args&.split(' ')

        if parts.nil? || parts.length < 2
          ctx.reply(
            "🎬 *Watch Anime / Donghua*\n\n" \
            "Usage: `/watch <name> <code>`\n" \
            "Example: `/watch the last blade of ming 12345`",
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

        stream_url = get_stream_url(video[:id])

        if stream_url.nil?
          ctx.reply(
            "❌ Stream unavailable for *#{name}*.\n" \
            "Try another title.",
            parse_mode: "Markdown"
          )
          next
        end

        watch_link = "https://tomoviestv.netlify.app/watch.html?stream=#{CGI.escape(stream_url)}&title=#{CGI.escape(video[:title])}"

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

    def self.get_stream_url(video_id)
      response = HTTParty.get(
        "https://www.dailymotion.com/player/metadata/video/#{video_id}"
      )
      return nil unless response.success?

      data = response.parsed_response
      qualities = data["qualities"]
      return nil unless qualities

      auto = qualities["auto"]&.first
      return auto["url"] if auto && auto["type"] == "application/x-mpegURL"

      qualities.each do |key, streams|
        next unless streams.is_a?(Array)
        hls = streams.find { |s| s["type"] == "application/x-mpegURL" }
        return hls["url"] if hls
      end

      nil
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
