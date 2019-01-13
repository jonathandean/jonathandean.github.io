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
#
# run test with:
# > cd [project root]
# > rspec functions/top-tweets/spec/

class TopTweets

  def self.collect_with_max_id(collection=[], max_id=nil, &block)
    response = yield(max_id)
    collection += response
    response.empty? ? collection.flatten : collect_with_max_id(collection, response.last.id - 1, &block)
  end
  
  def self.new_authenticated_twitter_client
    Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV.fetch("TWITTER_CONSUMER_KEY")
      config.consumer_secret     = ENV.fetch("TWITTER_CONSUMER_SECRET")
      config.access_token        = ENV.fetch("TWITTER_ACCESS_TOKEN")
      config.access_token_secret = ENV.fetch("TWITTER_ACCESS_SECRET")
    end
  end

  def self.fetch_timeline(twitter_client)
    def twitter_client.get_all_tweets(user, exclude_replies: , include_rts: )
      collect_with_max_id do |max_id|
        options = {count: 200, exclude_replies: exclude_replies, include_rts: include_rts}
        options[:max_id] = max_id unless max_id.nil?
        user_timeline(user, options)
      end
    end

    max_number_of_tweets = ENV.fetch("MAX_NUMBER_OF_TWEETS").to_i

    if max_number_of_tweets > 0
       puts "Fetching timeline up to #{max_number_of_tweets} tweets..."
       twitter_client.user_timeline(ENV.fetch("TWITTER_USERNAME"), count: max_number_of_tweets, exclude_replies: false, include_rts: false)
     else
       puts "Fetching timeline as far back as allowed..."
       twitter_client.get_all_tweets(ENV.fetch("TWITTER_USERNAME"), exclude_replies: false, include_rts: false)
     end
  end

  def self.should_post_to_github?(tweet)
    tweet.attrs[:favorited]
  end

  def self.extract_values_from_tweet(tweet)
    puts "==="
    # puts "extracting values from tweet:"
    # puts tweet.attrs

    tweet_id = tweet.id
    tweet_url = tweet.url.to_s
    tweet_created_at = tweet.created_at

    tweet_text = tweet.full_text ? tweet.full_text : tweet.text

    if tweet.attrs[:is_quote_status]
      puts "this tweet quotes another tweet"
      if tweet.attrs[:quoted_status]
        tweet_text = "#{tweet_text} <blockquote>@#{tweet.attrs[:quoted_status][:user][:screen_name]}: #{tweet.attrs[:quoted_status][:text]}</blockquote>"
      else
        tweet_text = "#{tweet_text} <blockquote>This tweet is unavailable.</blockquote>"
      end
    elsif tweet.attrs[:in_reply_to_screen_name]
      puts "this tweet replies to another tweet"
      tweet_text = "RE @#{tweet.attrs[:in_reply_to_screen_name]}: #{tweet_text}"
    end

    puts "tweet_id: #{tweet_id}"
    puts "tweet_url: #{tweet_url}"
    puts "tweet_created_at: #{tweet_created_at}"

    puts "tweet_text:"
    puts tweet_text

    return tweet_id, tweet_url, tweet_text, tweet_created_at
  end
  
  def self.post_data_to_staticman_then_unfavorite(data:, twitter_client:, tweet:)

    staticman_url = ENV.fetch("STATICMAN_POST_URL")

    puts "-- posting to staticman --"
    puts data.inspect
    puts "--------------------------"

    if ENV.fetch('STATICMAN_POSTING_ENABLED') === 'true'
      uri = URI.parse(staticman_url)
      https = Net::HTTP.new(uri.host,uri.port)
      https.use_ssl = true
      req = Net::HTTP::Post.new(uri.path)
      req.set_form_data(data)
      res = https.request(req)

      json = JSON.parse(res.body)

      if json['success'] === true
        puts "successfully posted to github pages, unfavoriting"
        twitter_client.unfavorite(tweet)
      else
        puts "failed to post to github pages:"
        puts json.inspect

        if json['error'] && json['error']['nextValidRequestDate']
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
    else
      puts "(posting to staticman disabled, ignoring)"
    end
  end
  
  def self.handler(event:, context:)

    twitter_client = new_authenticated_twitter_client

    timeline = fetch_timeline(twitter_client)

    timeline.each do |tweet|

      if should_post_to_github?(tweet)

        tweet_id, tweet_url, tweet_text, tweet_created_at = extract_values_from_tweet(tweet)

        post_data_for_staticman = {
          "fields[tweet_id]" => tweet_id,
          "fields[url]" => tweet_url,
          "fields[text]" => tweet_text,
          "fields[created_at]" => tweet_created_at,
        }
        
        post_data_to_staticman_then_unfavorite(data: post_data_for_staticman, twitter_client: twitter_client, tweet: tweet)
        
      # else # TODO remove me, only for debugging when parsing all tweets is valuable
      #   extract_values_from_tweet(tweet)
      end

    end

  end
end