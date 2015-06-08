require 'cute_pets'
require 'minitest/autorun'

# Couldn't find a way to effectively mock modules via minitest :(
describe 'CutePets' do
  describe '.post_pet' do
    before do
      @pet = CutePets::Pet.new(
        'schooples',
        'neutured female fluffy dog',
        'http://www.example.com/schooples',
        'http://www.example.com/schooples.jpg')
    end

    it 'fetches pet finder data when the env var datasource is set to petfinder' do
      ENV.stub :fetch, 'petfinder' do
        PetFetcher.stub(:get_pet, @pet) do
          TweetGenerator.stub(:tweet, nil, [String, String]) do
            CutePets.post_pet
          end
        end
      end
    end
  end
end
