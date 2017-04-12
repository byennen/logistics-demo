require 'active_record'
require 'sqlite3'

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: ':memory:'
)

ActiveRecord::Schema.define do
  create_table :feights do |table|
    table.column :carrier, :string
    table.column :origin, :string
    table.column :destination, :string
  end
  create_table :stops do |table|
    table.column :feight_id, :integer
    table.column :address, :string
  end
end

module CloudLogistics
  class Stop < ActiveRecord::Base
    belongs_to :feights
  end

  class Feight < ActiveRecord::Base
    has_many :stops

    def load_questions
      @feight = Feight.new
      @stops = number_of_stops
      @feight.carrier = question_string('Carrier name:')
      @feight.origin = question_string('Origin:')
      ask_for_stops(@feight, @stops)
      @feight.destination = question_string('Destination:')
      @feight.save
    end

    def run
      load_questions
      puts '---'
      puts "Bill of lading number #{@feight.stops.count}, being carried by #{@feight.carrier}"
      puts "- Origin: #{@feight.origin}"
      @feight.stops.each do |stop|
        puts "- #{stop.id} stop: #{stop.address}"
      end
      puts "- Destination: #{@feight.destination}"
    end

    private

    def number_of_stops
      puts 'Number of stops:'
      while (input = gets.chomp.to_i) <= 0
        puts 'Please enter a valid number'
      end
      input
    end

    def ask_for_stops(feight, stops)
      stops.times do |stop|
        puts "Stop number #{stop + 1}:"
        while (input = gets.chomp.to_s) && input.empty? || input.nil? ||
              input.match(/^[-+]?[0-9]*$/)
          puts 'Please enter a valid answer'
        end
        feight.stops.new(address: input)
      end
    end

    def question_string(question)
      puts question
      while (input = gets.chomp) && input.empty? ||
            input.nil? || input.match(/^[-+]?[0-9]*$/)
        puts 'Please enter a valid answer'
      end
      input
    end
  end
end

@feight = CloudLogistics::Feight.new
puts @feight.run
