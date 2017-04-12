require 'active_record'
require 'sqlite3'
require 'street_address'

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: ':memory:'
)

ActiveRecord::Schema.define do
  create_table :feights do |table|
    table.column :carrier, :string
  end
  create_table :stops do |table|
    table.column :feight_id, :integer
    table.column :address_line_1, :string
    table.column :city, :string
    table.column :state, :string
    table.column :zipcode, :string
    table.column :country, :string
    table.column :latitude, :string
    table.column :longitude, :string
    table.column :type, :string
  end
end

module CloudLogistics
  class Stop < ActiveRecord::Base
    belongs_to :feights

    scope :load_stops, -> { where type: 'CloudLogistics::Load' }
    scope :delivery_stops, -> { where type: 'CloudLogistics::Delivery' }
    scope :pit_stops, -> { where type: nil}
  end

  class Load < Stop
  end

  class Delivery < Stop
  end

  class Feight < ActiveRecord::Base
    has_many :stops

    # can we do validations with this?
    #include ActiveModel::Validations #allows us to perform validations
    # validates_presence_of

    def load_questions
      @feight = Feight.new
      @stops = number_of_stops
      @feight.carrier = question_string('Carrier name:')
      stop(@feight, 'Origin:', Load)
      stop(@feight, 'Stop number', Stop, @stops)
      stop(@feight, 'Destination:', Delivery)
      @feight.save
    end

    def run
      load_questions
      puts '---'
      puts "Bill of lading number #{@feight.stops.pit_stops.count}, being carried by #{@feight.carrier}"
      @origin = @feight.stops.load_stops.first
      puts "- Origin: #{@origin.address_line_1}, #{@origin.city}, #{@origin.state}. #{@origin.zipcode}"
      @feight.stops.pit_stops.each_with_index do |stop, i|
        puts "- #{i + 1} stop: #{stop.address_line_1}, #{stop.city}, #{stop.state}. #{stop.zipcode}"
      end
      @delivery = @feight.stops.delivery_stops.first
      puts "- Destination: #{@delivery.address_line_1}, #{@delivery.city}, #{@delivery.state}. #{@delivery.zipcode}"
    end

    private

    def number_of_stops
      puts 'Number of stops:'
      while (input = gets.chomp.to_i) <= 0
        puts 'Please enter a valid number'
      end
      input
    end

    def question_string(question)
      puts question
      while (input = gets.chomp) && input.empty? ||
            input.nil? || input.match(/^[-+]?[0-9]*$/)
        puts 'Please enter a valid answer'
      end
      input
    end

    def stop(feight, question, type, stops=nil)
      if stops == nil
        puts question
        while (input = gets.chomp) && input.empty? ||
              input.nil? || input.match(/^[-+]?[0-9]*$/)
          puts 'Please enter a valid answer'
        end
      else
        stops.times do |stop|
          puts "#{question} #{stop + 1}:"
          while (input = gets.chomp.to_s) && input.empty? || input.nil? ||
                input.match(/^[-+]?[0-9]*$/)
            puts 'Please enter a valid answer'
          end
        end
      end
      address = StreetAddress::US.parse(input)

      feight.stops << type.new(
        address_line_1: address.to_s(:line1),
        city: address.city,
        state: address.state,
        zipcode: address.postal_code,
        #county: address.country
        #latitude: address.latitude
        #longitude: address.longitude
      )
      puts feight.stops.inspect
    end
  end
end

@feight = CloudLogistics::Feight.new
puts @feight.run
