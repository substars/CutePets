require 'cute_pets/pet_fetcher'
require 'webmock/minitest'
require 'vcr'

describe CutePets::PetFetcher do
  VCR.configure do |c|
    c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
    c.hook_into :webmock
  end

  describe '.get_pet' do
    # mocking class methods in minitest is weird
    it 'should call get_petfinder_pet' do
      mock = MiniTest::Mock.new
      mock.expect(:call, nil)
      CutePets::PetFetcher.stub(:get_petfinder_pet, mock) do
        CutePets::PetFetcher.get_pet('petfinder')
      end
      mock.verify
    end

    it 'should call get_petharbor_pet' do
      mock = MiniTest::Mock.new
      mock.expect(:call, nil)
      CutePets::PetFetcher.stub(:get_petharbor_pet, mock) do
        CutePets::PetFetcher.get_pet('petharbor')
      end
      mock.verify
    end

    it 'should blow up' do
      assert_raises(RuntimeError, "ENV['pet_datasource'] not specified") do
        CutePets::PetFetcher.get_pet('lolidk')
      end
    end
  end

  describe '.get_petfinder_pet' do
    it 'returns a hash of pet data when the API request is successful' do
      VCR.use_cassette('petfinder', record: :once) do
        pet_hash = CutePets::PetFetcher.get_petfinder_pet
        pet_hash[:description].must_equal 'altered male ferret'
        pet_hash[:pic].must_equal 'http://photos.petfinder.com/photos/pets/30078059/1/?bust=1409196072&width=500&-x.jpg'
        pet_hash[:link].must_equal 'https://www.petfinder.com/petdetail/30078059'
        pet_hash[:name].must_equal 'Joey'
      end
    end

    it 'raises when the API request fails' do
      stub_request(:get, /^http\:\/\/api\.petfinder\.com\/pet\.getRandom/).to_return(:status => 500)
      lambda { CutePets::PetFetcher.get_petfinder_pet }.must_raise RuntimeError
    end
  end

  describe '.get_petharbor_pet' do
    it 'returns a hash of pet data when the request is successful' do
      CutePets::PetFetcher.stub(:get_petharbor_pet_type, 'dog') do
        VCR.use_cassette('petharbor', record: :once) do
          pet_hash = CutePets::PetFetcher.get_petharbor_pet
          pet_hash[:description].must_equal 'neutered male white bichon frise'
          pet_hash[:pic].must_equal 'http://www.PetHarbor.com/get_image.asp?RES=Thumb&ID=A223117&LOCATION=DNVR'
          pet_hash[:link].must_equal 'http://www.PetHarbor.com/detail.asp?ID=A223117&LOCATION=DNVR&searchtype=rnd&shelterlist=\'DNVR\'&where=dummy&kiosk=1'
          pet_hash[:name].must_equal 'Morty'
        end
      end
    end
  end

  it 'raises when the request fails' do
    stub_request(:get, /^http\:\/\/www\.petharbor\.com\/petoftheday\.asp/).to_return(:status => 500)
    lambda { CutePets::PetFetcher.get_petharbor_pet }.must_raise RuntimeError
  end

  describe 'get_petfinder_option' do
    it 'uses friendly values' do
      CutePets::PetFetcher.send(:get_petfinder_option, {"option" => {"$t" => "housebroken"}}).must_equal 'house trained'
      CutePets::PetFetcher.send(:get_petfinder_option, {"option" => {"$t" => "housetrained"}}).must_equal 'house trained'
      CutePets::PetFetcher.send(:get_petfinder_option, {"option" => {"$t" => "noClaws"}}).must_equal 'declawed'
      CutePets::PetFetcher.send(:get_petfinder_option, {"option" => {"$t" => "altered"}}).must_equal 'altered'
    end

    it 'handles multiple values in the options hash' do
      CutePets::PetFetcher.send(:get_petfinder_option,
                      {"option" => [{"$t" => "hasShots"},
                                    {"$t" => "noClaws"}]}).must_equal 'declawed'
    end

    it 'ignores some possible values' do
      CutePets::PetFetcher.send(:get_petfinder_option,
                      {"option" => [{"$t" => "hasShots"},
                                    {"$t" => "noCats"},
                                    {"$t" => "noDogs"},
                                    {"$t" => "noKids"},
                                    {"$t" => "totally not in the xsd"},
                      ]}).must_equal nil

    end
  end

  describe 'get_petfinder_breed' do
    it 'works with a single hash' do
      CutePets::PetFetcher.send(:get_petfinder_breed, {"breed" => {"$t" => "Spaniel"}}).must_equal 'Spaniel'
    end

    it 'works with an array of hashes' do
      CutePets::PetFetcher.send(:get_petfinder_breed, {"breed" => [{"$t" => "Spaniel"}, {"$t" => "Pomeranian"}]}).must_equal 'Spaniel/Pomeranian mix'
    end
  end
end
