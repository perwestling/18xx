# frozen_string_literal: true

require_relative '../config/game/g_18_al'
require_relative 'base'
require_relative 'company_price_50_to_150_percent'

module Engine
  module Game
    class G18AL < Base
      load_from_json(Config::Game::G18AL::JSON)
      AXES = { x: :number, y: :letter }.freeze

      DEV_STAGE = :alpha

      GAME_LOCATION = 'Alabama, USA'
      GAME_RULES_URL = 'http://www.diogenes.sacramento.ca.us/18AL_Rules_v1_64.pdf'
      GAME_DESIGNER = 'Mark Derrick'
      GAME_END_CHECK = { bankrupt: :immediate, stockmarket: :current_or, bank: :current_or }.freeze

      include CompanyPrice50To150Percent

      def setup
        setup_company_price_50_to_150_percent

        @corporations.each do |corporation|
          corporation.abilities(:destination) do |ability|
            ability.value = @hexes.detect { |h| h.name == ability.hex }.location_name
          end
        end
      end

      def operating_round(round_num)
        Round::Operating.new(self, [
          Step::Bankrupt,
          Step::DiscardTrain,
          Step::BuyCompany,
          Step::HomeToken,
          Step::G18AL::Track,
          Step::G18AL::Token,
          Step::Route,
          Step::Dividend,
          Step::SingleDepotTrainBuyBeforePhase4,
          [Step::BuyCompany, blocks: true],
        ], round_num: round_num)
      end

      def revenue_for(route)
        ensure_terminus_first_or_last(route, %w[A4 Q2])

        revenue = super

        if route.train.name == '4D'
          revenue = 2 * revenue - route.stops
            .select { |stop| stop.hex.tile.towns.any? }
            .sum { |stop| stop.route_revenue(route.phase, route.train) }
        end

        revenue
      end

      private

      def ensure_terminus_first_or_last(route, termini)
        inside_names = route.hexes[1...-1].map(&:name)
        (termini & inside_names).each do |name|
          city_name = route.hexes.detect { |h| h.name == name }.location_name
          raise GameError, "#{city_name} must be first or last in route"
        end
      end
    end
  end
end
