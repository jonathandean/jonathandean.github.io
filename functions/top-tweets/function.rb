require 'twitter'
require 'net/http'
require 'net/https'
require 'uri'
require 'json'

class TopTweets
  def self.handler(event:, context:)

    post_url = ENV.fetch("POST_URL")

    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV.fetch("TWITTER_CONSUMER_KEY")
      config.consumer_secret     = ENV.fetch("TWITTER_CONSUMER_SECRET")
      config.access_token        = ENV.fetch("TWITTER_ACCESS_TOKEN")
      config.access_token_secret = ENV.fetch("TWITTER_ACCESS_SECRET")
    end

    timeline = client.user_timeline(ENV.fetch("TWITTER_USERNAME"), count: ENV.fetch("NUMBER_OF_TWEETS"), exclude_replies: true, include_rts: false)

    timeline.each do |tweet|
      favorited = tweet.attrs[:favorited]
      puts "id: #{tweet.id}"
      puts "url: #{tweet.url}"
      puts tweet.text
      puts tweet.full_text
      puts "created_at: #{tweet.created_at}"
      puts "favs: #{tweet.favorite_count}"
      puts "rts: #{tweet.retweet_count}"
      puts "post to github: #{favorited}"
      puts "==="

      if favorited
        uri = URI.parse(post_url)
        https = Net::HTTP.new(uri.host,uri.port)
        # https.use_ssl = true
        req = Net::HTTP::Post.new(uri.path)

        data = {
          "fields[tweet_id]" => tweet.id,
          "fields[url]" => tweet.url,
          "fields[text]" => tweet.text,
          "fields[created_at]" => tweet.created_at,
        }
        req.set_form_data(data)
        res = https.request(req)

        json = JSON.parse(res.body)

        if json['success'] === true
          client.unfavorite(tweet)
        end

      end
    end

  end
end