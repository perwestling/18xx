# frozen_string_literal: true

require_relative '../config/game/g_18_al'
require_relative '../g_18_al/phase'
require_relative 'base'
require_relative 'company_price_50_to_150_percent'

module Engine
  module Game
    class G18AL < Base
      load_from_json(Config::Game::G18AL::JSON)
      AXES = { x: :number, y: :letter }.freeze

      GAME_LOCATION = 'Alabama, USA'
      GAME_RULES_URL = 'http://www.diogenes.sacramento.ca.us/18AL_Rules_v1_64.pdf'
      GAME_DESIGNER = 'Mark Derrick'

      include CompanyPrice50To150Percent

      def operating_round(round_num)
        Round::G18AL::Operating.new(@corporations, game: self, round_num: round_num)
      end

      def stock_round
        Round::G18AL::Stock.new(@players, game: self)
      end

      def initiate_special
        Round::G18AL::Special.new(@companies, game: self)
      end

      def init_phase
        Engine::G18AL::Phase.new(self.class::PHASES, self)
      end

      def setup
        setup_company_price_50_to_150_percent
        @corporations.each do |corporation|
          corporation.abilities(:destination) do |ability|
            hex = @hexes.select do |h|
              h.name == ability.hex
            end.first
            ability.value = hex.location_name
          end
        end
      end

      def revenue_for(route)
        ensure_terminus_first_or_last(route, %w[A4 Q2])
        revenue = super

        if route.train.name == '4D'
          revenue = 2 * revenue - route.stops
            .select { |stop| stop.hex.tile.towns.any? }
            .sum { |stop| stop.route_revenue(route.phase, route.train) }
        end

        route.corporation.abilities(:hex_bonus) do |ability|
          bonus = route.stops.sum { |stop| ability.hex == stop.hex.id ? ability.bonus : 0 }
          revenue += bonus if bonus.positive?
        end

        revenue
      end

      private

      def ensure_terminus_first_or_last(route, termini)
        termini.each do |terminus|
          index = route.hexes.index { |hex| hex.name == terminus }
          raise GameError, "#{route.hexes[index].location_name} must be first or last in route" unless
            index.nil? || index.zero? || index + 1 == route.hexes.length
        end
      end
    end
  end
end
