require 'twitter'
require 'net/http'
require 'net/https'
require 'uri'
require 'json'
require 'time'
# package with:
# > cd functions/top-tweets
# > docker run -v `pwd`:`pwd` -w `pwd` -i -t lambci/lambda:build-ruby2.5 bundle install --deployment
# > chmod 644 $(find ./vendor/ -type f)
# > chmod 755 $(find ./vendor/ -type d)
# > zip -r function.zip function.rb vendor

class TopTweets
  def self.handler(event:, context:)

    post_url = ENV.fetch("POST_URL")

    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV.fetch("TWITTER_CONSUMER_KEY")
      config.consumer_secret     = ENV.fetch("TWITTER_CONSUMER_SECRET")
      config.access_token        = ENV.fetch("TWITTER_ACCESS_TOKEN")
      config.access_token_secret = ENV.fetch("TWITTER_ACCESS_SECRET")
    end

    def collect_with_max_id(collection=[], max_id=nil, &block)
      response = yield(max_id)
      collection += response
      response.empty? ? collection.flatten : collect_with_max_id(collection, response.last.id - 1, &block)
    end

    def client.get_all_tweets(user, exclude_replies: , include_rts: )
      collect_with_max_id do |max_id|
        options = {count: 200, exclude_replies: exclude_replies, include_rts: include_rts}
        options[:max_id] = max_id unless max_id.nil?
        user_timeline(user, options)
      end
    end

    timeline = if ENV.fetch("NUMBER_OF_TWEETS").to_i > 0
                client.user_timeline(ENV.fetch("TWITTER_USERNAME"), count: ENV.fetch("NUMBER_OF_TWEETS"), exclude_replies: false, include_rts: false)
               else
                 client.get_all_tweets(ENV.fetch("TWITTER_USERNAME"), exclude_replies: false, include_rts: false)
               end

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
        https.use_ssl = true
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
          puts "successfully posted to github pages, unfavoriting"
          client.unfavorite(tweet)
        else
          puts "failed to posted to github pages:"
          puts json.inspect

          if json['error']['nextValidRequestDate']
            next_valid_time = Time.parse(json['error']['nextValidRequestDate'])
            puts "next valid time is: #{next_valid_time}"

            seconds_until_next_valid_time = next_valid_time.to_i - Time.now.to_i
            puts "seconds_until_next_valid_time: #{seconds_until_next_valid_time}"

            if seconds_until_next_valid_time > 0
              puts "sleeping"
              sleep seconds_until_next_valid_time + 10
            end
          end
        end

      end
    end

  end
end