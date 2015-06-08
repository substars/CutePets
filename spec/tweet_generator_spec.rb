require 'cute_pets/tweet_generator'
require 'minitest/autorun'

describe CutePets::TweetGenerator do
  describe '.tweet' do
    it 'uses the twitter gem to post a tweet' do
      pet = MiniTest::Mock.new
      pet.expect(:introduction, 'Hi! I am Woofles. I am a neutered female nerdy cat. http://www.example.org/woofles')
      pet.expect(:pic, 'spec/fixtures/cat.jpg')
      twitter_client = MiniTest::Mock.new
      CutePets::TweetGenerator.stub :client, twitter_client do
        twitter_client.expect(:update_with_media, nil, [String, File])
        CutePets::TweetGenerator.tweet(pet)
      end
      pet.verify
      twitter_client.verify
    end
  end
end
