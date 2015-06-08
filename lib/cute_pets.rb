Bundler.require
require './lib/cute_pets/pet_fetcher'
require './lib/cute_pets/tweet_generator'
require './lib/cute_pets/pet'
Dotenv.load

module CutePets
  extend self

  def post_pet
      TweetGenerator.tweet(PetFetcher.get_pet(ENV.fetch('pet_datasource')))
  end
end