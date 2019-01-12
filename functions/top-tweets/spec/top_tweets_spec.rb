require 'spec_helper'
require_relative '../function'

# TO RUN:
# cd jonathandean.github.io
# bundle install
# Create .env locally if not there
# > cd functions/top-tweets
# > rspec

RSpec.describe TopTweets do
  subject { TopTweets }
  let!(:context) { {} }
  let!(:event) { {} }

  let(:response) { subject.handler(event: event, context: context) }

  describe "#handler" do

    it "doesn't blow up" do
      expect{ response }.to_not raise_exception
    end

  end

end