require 'support/spec_helper'

describe CloudLogistics do
  describe CloudLogistics::Stop do
    let(:stop) { FactoryGirl.create(:stop) }

    it 'sets latitude and longitude' do
      expect(stop.latitude).to eq('26.7056725')
      expect(stop.longitude).to eq('-80.05099589999999')
    end

    it 'sets country code' do
      expect(stop.country).to eq('US')
    end
  end

  describe CloudLogistics::Feight do
    let(:feight) { FactoryGirl.create(:feight) }
    let(:stop) { FactoryGirl.create(:stop) }
    let(:origin) { FactoryGirl.create(:origin) }
    let(:destination) { FactoryGirl.create(:destination) }

    it 'has multiple stops' do
      3.times do
        output = StreetAddress::US.parse(
          '333 Las Ols Way Ft Lauderdale FL 33301')
        feight.stops.create(
          address_line_1: output.to_s(:line1),
          city: output.city,
          state: output.state,
          zipcode: output.postal_code
        )
      end
      expect(feight.stops.count).to eq(3)
    end

    it 'has a carrier' do
      expect(feight.carrier).to eq('YRC')
    end

    it 'has a origin' do
      expect(origin).to be_valid
    end

    it 'has a destination' do
      expect(destination).to be_valid
    end

    it 'saves address in the correct format' do
      output = StreetAddress::US.parse('333 Las Ols Way Ft Lauderdale FL 33301')
      address = feight.stops.create(
        address_line_1: output.to_s(:line1),
        city: output.city,
        state: output.state,
        zipcode: output.postal_code
      )
      expect(address.address_line_1).to eq('333 Las Ols Way Ft')
      expect(address.city).to eq('Fort Lauderdale')
      expect(address.state).to eq('Florida')
      expect(address.zipcode).to eq('33301')
    end

    it 'calculates the distance between current location and
      destination' do
      miles = Geocoder::Calculations.distance_between(
        [stop.latitude, stop.longitude],
        [destination.latitude, destination.longitude]
      )
      expect(miles.round(2)).to eq(0.41)
    end

    it 'mark stop as visited if in 10 miles' do
      miles = Geocoder::Calculations.distance_between(
        [stop.latitude, stop.longitude],
        [destination.latitude, destination.longitude]
      )
      if miles.round(2) < 10
        stop.update_attribute(:visited, true)
      end
      expect(stop.visited).to eq(true)
    end
  end
end
