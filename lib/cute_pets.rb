Bundler.require
require './lib/cute_pets/pet_fetcher'
require './lib/cute_pets/tweet_generator'
Dotenv.load

module CutePets
  extend self

  def post_pet
    if pet = PetFetcher.get_pet(ENV.fetch('pet_datasource'))
      message = TweetGenerator.create_message(pet[:name], pet[:description], pet[:link])
      TweetGenerator.tweet(message, pet[:pic])
    end
  end
end