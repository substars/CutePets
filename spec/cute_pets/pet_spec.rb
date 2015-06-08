require 'spec_helper'
require 'cute_pets/pet'

describe CutePets::Pet do
  it 'should introduce itself using a' do
    pet = CutePets::Pet.new('Moofle', 'neutured female fluffy dog', 'http://www.example.com/schooples', 'http://www.example.com/schooples.jpg')
    pet.introduction.must_match /Moofle. I am a neutered fluffy dog. http\:\/\/www\.example\.org\/moofle/
  end

  it 'should introduce itself using an' do
    pet = CutePets::Pet.new('Miffle', 'unaltered female kitten', 'http://www.example.org/miffle', nil)
    pet.introduction.must_match /Miffle. I am an unaltered female kitten. http\:\/\/www\.example\.org\/miffle/
  end

  it 'should use a greeting from the list' do
    pet = CutePets::Pet.new('Miffle', 'unaltered female kitten', 'http://www.example.org/miffle', nil)
    greetings = YAML.load(File.open('lib/greetings.yml'))
    expect(greetings).to include(pet.greeting)
  end
end
