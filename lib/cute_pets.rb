Bundler.require
require './lib/cute_pets/pet_fetcher'
require './lib/cute_pets/tweet_generator'
require './lib/cute_pets/pet'
Dotenv.load

module CutePets
  extend self

  def post_pet
    if pet = PetFetcher.get_pet(ENV.fetch('pet_datasource'))
      TweetGenerator.tweet(pet.introduction, pet.pic)
    end
  end
end