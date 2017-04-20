# frozen_string_literal: true
require 'spec_helper'

describe Exercise::Calculator do
  context 'with dhh github url' do
    before do
      @score = Exercise::Calculator.new
      @url = 'https://api.github.com/users/dhh/events/public'
    end

    it '#initialize' do
      expect(@score.is_a?(Exercise::Calculator)).to eq true
      expect(@score.url).to eq @url
      expect(@score.commit_type.is_a?(Hash)).to eq true
    end

    it '#calculate_score' do
      expect { @score.calculate_score }.to change { @score.score }.by_at_least(1)
      expect(@score.calculate_score.is_a?(Integer)).to eq true
    end

    it '#run' do
      output = @score.run
      expect(output.include?("DHH's github score is")).to eq true
    end
  end
end
