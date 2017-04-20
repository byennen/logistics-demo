require 'active_record'
require 'sqlite3'
require 'street_address'
require 'geocoder'

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
    belongs_to :feight

    include ActiveModel::Validations
    validates_presence_of :address_line_1, :city, :state, :zipcode

    extend ::Geocoder::Model::ActiveRecord

    # Find latitude & Longitude
    geocoded_by :address
    after_validation :geocode

    # Reverse lookup if missing city, zip, country code
    reverse_geocoded_by :latitude, :longitude do |obj, results|
      if geo = results.first
        obj.city    = geo.city
        obj.state   = geo.state
        obj.zipcode = geo.postal_code
        obj.country = geo.country_code
      end
    end
    after_validation :reverse_geocode

    scope :load_stops, -> { where type: 'CloudLogistics::Load' }
    scope :delivery_stops, -> { where type: 'CloudLogistics::Delivery' }
    scope :pit_stops, -> { where type: nil }

    def address
      [address_line_1, city, state].compact.join(', ')
    end
  end

  class Load < Stop
  end

  class Delivery < Stop
  end

  class Feight < ActiveRecord::Base
    has_many :stops

    include ActiveModel::Validations
    validates_presence_of :carrier

    def create_feight
      @feight = Feight.new
      @stops = ask_for_number_of_stops
      @feight.carrier = ask_for_carrier
      @feight.save!
      ask_question(@feight, 'Origin:', Load)
      ask_question(@feight, 'Stop number', Stop, @stops)
      ask_question(@feight, 'Destination:', Delivery)
    end

    def ask_for_number_of_stops
      puts 'Number of stops:'
      while (input = gets.chomp.to_i) <= 0
        puts 'Please enter a valid number:'
      end
      input
    end

    def ask_for_carrier
      puts 'Carrier name:'
      while (input = gets.chomp) && input.empty? || input.nil?
        puts 'Please enter a valid answer'
      end
      input
    end

    def ask_question(feight, question, type, stops = nil)
      if stops.nil?
        puts question
        input = gets.chomp
        create_address(feight, input, type)
      else
        stops.times do |stop|
          puts "#{question} #{stop + 1}:"
          input = gets.chomp
          create_address(feight, input, type)
        end
      end
    end

    def create_address(feight, input, type)
      loop do
        output = StreetAddress::US.parse(input)
        if output.nil?
          puts 'Please enter a valid address'
        elsif output.postal_code.nil?
          puts 'Please include zipcode with your address'
        else
          feight.stops << type.new(
            address_line_1: output.to_s(:line1),
            city: output.city,
            state: output.state,
            zipcode: output.postal_code
          )
          break
        end
        input = gets.chomp
      end
    end

    def print_full_address(stop)
      "#{stop.address_line_1}, #{stop.city}, "\
      "#{stop.state}. #{stop.zipcode}, #{stop.latitude}, #{stop.longitude}"
    end

    def print_bill(feight)
      puts '---'
      puts "Bill of lading number #{feight.stops.pit_stops.count}, " \
           "being carried by #{feight.carrier}"
    end

    def print_address(type, stop)
      puts "- #{type} #{print_full_address(stop)}"
    end

    def print_stops(feight)
      feight.stops.pit_stops.each_with_index do |stop, i|
        puts "- #{i + 1} stop: #{print_full_address(stop)}"
      end
    end

    def run
      create_feight
      @origin = @feight.stops.load_stops.first
      @delivery = @feight.stops.delivery_stops.first
      print_bill(@feight)
      print_address('Origin:', @origin)
      print_stops(@feight)
      print_address('Destination:', @delivery)
    end
  end
end

@feight = CloudLogistics::Feight.new
puts @feight.run
