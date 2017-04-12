# frozen_string_literal: true
require 'open-uri'
require 'json'

module Exercise
  class Calculator
    attr_accessor :url, :commit_type, :score

    def initialize
      @url = 'https://api.github.com/users/dhh/events/public'
      @commit_type = { 'IssuesEvent': 7,
                      'IssueCommentEvent': 6,
                      'PushEvent': 5,
                      'PullRequestReviewCommentEvent': 4,
                      'WatchEvent': 3,
                      'CreateEvent': 2,
                      'Any other event': 1 }
      @score = 0
    end

    def calculate_score
      @data = JSON.parse(open(url).read)
      @score = @data.inject(0) do |result, data|
        type = data['type'].to_sym
        result += if @commit_type.key? type
                    @commit_type[type]
                  else
                    @commit_type[:'Any other event']
                  end
        result
      end
    end

    def run
      calculate_score
      "DHH's github score is #{@score}"
    end
  end
end

@dhh_score = Exercise::Calculator.new
puts @dhh_score.run
