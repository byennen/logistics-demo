require 'spec_helper'

describe CloudLogistics do
  describe CloudLogistics::Stop do
    before do
      @stop = CloudLogistics::Stop.new
      @stop.address = 'West Palm Beach'
      @stop.save
    end

    it 'has an address' do
      expect(@stop.address).to eq('West Palm Beach')
    end
  end

  describe CloudLogistics::Feight do
    before do
      @feight = CloudLogistics::Feight.new
      @feight.stops.new(address: 'Orlando')
      @feight.stops.new(address: 'Chicago')
      @feight.stops.new(address: 'New York')
      @feight.carrier = 'YRC'
      @feight.origin = 'Ft Lauderdale'
      @feight.destination = 'Orlando'
      @feight.save
    end

    it 'has multiple stops' do
      expect(@feight.stops.count).to eq(3)
    end

    it 'has a carrier' do
      expect(@feight.carrier).to eq('YRC')
    end

    it 'has a origin' do
      expect(@feight.origin).to eq('Ft Lauderdale')
    end

    it 'has a destination' do
      expect(@feight.destination).to eq('Orlando')
    end
  end
end
