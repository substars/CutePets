require 'net/http'
require 'json'

module PetFetcher
  extend self

  def get_pet(source)
    case source.downcase
      when 'petfinder'
        get_petfinder_pet
      when 'petharbor'
        get_petharbor_pet
      else
        raise "ENV['pet_datasource'] not specified"
    end
  end

  def get_petfinder_pet
    uri = URI('http://api.petfinder.com/pet.getRandom')
    params = {
      format:    'json',
      key:        ENV.fetch('petfinder_key'),
      shelterid:  get_petfinder_shelter_id,
      output:    'full'
    }
    uri.query = URI.encode_www_form(params)
    response = Net::HTTP.get_response(uri)

    if response.kind_of? Net::HTTPSuccess
      json = JSON.parse(response.body)
      pet_json  = json['petfinder']['pet']
      {
        pic:   get_photo(pet_json),
        link:  "https://www.petfinder.com/petdetail/#{pet_json['id']['$t']}",
        name:  pet_json['name']['$t'].capitalize,
        description: [get_petfinder_option(pet_json['options']), get_petfinder_sex(pet_json['sex']['$t']),  get_petfinder_breed(pet_json['breeds'])].compact.join(' ').downcase
      }
    else
      raise 'PetFinder api request failed'
    end
  end

  def get_petharbor_pet
    uri = URI('http://www.petharbor.com/petoftheday.asp')

    params = {
      shelterlist: "\'#{get_petharbor_shelter_id}\'",
      type: get_petharbor_pet_type,
      availableonly: '1',
      showstat: '1',
      source: 'results'
    }
    uri.query = URI.encode_www_form(params)
    response = Net::HTTP.get_response(uri)
    if response.kind_of? Net::HTTPSuccess
      # The html response comes wrapped in some js :(
      response_html = response.body.gsub(/^document.write\s+\(/, '').gsub(/\);/, '').gsub('\"', '"')
      doc = Oga.parse_html(response_html)
      pet_url = doc.at_css('A').attribute('href').value
      pet_pic_url = doc.at_css('A IMG').attribute('SRC').value
      name = doc.at_css('FONT').inner_text.match(/^(?<name>\w+)\s+/)['name'].capitalize
      description = doc.css('FONT')[2].inner_text.downcase
      {
        pic:   pet_pic_url,
        link:  pet_url,
        name:  name,
        description: description
      }
    else
      raise 'PetHarbor request failed'
    end
  end

private

  def get_petfinder_sex(sex_abbreviation)
    sex_abbreviation.downcase == 'f' ? 'female' : 'male'
  end

  def get_petharbor_pet_type
    ENV.fetch('petharbor_pet_types').split.sample
  end

  PETFINDER_ADJECTIVES = {
    'housebroken' => 'house trained',
    'housetrained' => 'house trained',
    'noClaws'     => 'declawed',
    'altered'     => 'altered',
    'noDogs'      => nil,
    'noCats'      => nil,
    'noKids'      => nil,
    'hasShots'    => nil
  }.freeze

  def get_petfinder_option(option_hash)
    if option_hash['option']
      [option_hash['option']].flatten.map { |hsh| PETFINDER_ADJECTIVES[hsh['$t']] }.compact.first
    else
      option_hash['$t']
    end
  end

  def get_petfinder_breed(breeds)
    if breeds['breed'].is_a?(Array)
      "#{breeds['breed'].map(&:values).flatten.join('/')} mix"
    else
      breeds['breed']['$t']
    end
  end

  def self.get_photo(pet)
    if !pet['media']['photos']['photo'].nil?
      pet['media']['photos']['photo'][2]['$t']
    end
  end

  def get_petharbor_sex(html_text)
    html_text =~ /female/i ? 'female' : 'male'
  end

  def get_petfinder_shelter_id
    get_shelter_id(ENV.fetch('petfinder_shelter_id'))
  end

  def get_petharbor_shelter_id
    get_shelter_id(ENV.fetch('petharbor_shelter_id'))
  end

  def get_shelter_id(id)
    id.split(',').sample
  end
end
