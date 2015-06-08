module CutePets
  Pet = Struct.new(:name, :description, :pic, :link) do
    MESSAGES = YAML.load(File.open('lib/greetings.yml'))

    def introduction
      full_description = %w(a e i o u).include?(description[0]) ? "an #{description}" : "a #{description}"
      "#{greeting} #{name}. I am #{full_description}. #{link}"
    end

    def greeting
      MESSAGES.sample
    end
  end
end