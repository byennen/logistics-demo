require 'active_record'
require 'sqlite3'
require 'street_address'
require 'geocoder'
require_relative 'sqlite'

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
      # Challenge 4 don't ask for stops?
      # ask_question(@feight, 'Stop number', Stop, @stops)
      ask_question(@feight, 'Destination:', Delivery)
      ask_question(@feight, 'Current Location:', Stop)
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

    def distance_between_stops(current_location, destination)
      miles = Geocoder::Calculations.distance_between(
        [current_location.latitude, current_location.longitude],
        [destination.latitude, destination.longitude]
      )

      if miles.round(2) < 10
        current_location.update_attribute(:visited, true)
        puts "Location, #{current_location.address_line_1}, "\
             "#{current_location.city}, #{current_location.state}. "\
             "#{current_location.zipcode}, is within #{miles.round(2)} miles, "\
             'marking the destination as visited!'
      else
        puts "Location, #{current_location.address_line_1}, "\
             "#{current_location.city}, #{current_location.state}. "\
             "#{current_location.zipcode}."
      end
    end

    def run
      create_feight
      @origin = @feight.stops.load_stops.first
      @delivery = @feight.stops.delivery_stops.first
      @current_location = @feight.stops.pit_stops.last
      print_bill(@feight)
      print_address('Origin:', @origin)
      # challenge 4 no stops in output
      # print_stops(@feight)
      print_address('Destination:', @delivery)
      distance_between_stops(@current_location, @delivery)
    end
  end
end

@feight = CloudLogistics::Feight.new
puts @feight.run
