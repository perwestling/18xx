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

      def stock_round
        Round::G18AL::Stock.new(@players, game: self)
      end

      def init_phase
        Engine::G18AL::Phase.new(self.class::PHASES, self)
      end

      def operating_round(round_num)
        Round::Operating.new(self, [
          Step::Bankrupt,
          Step::DiscardTrain,
          Step::G18AL::BuyCompany,
          Step::HomeToken,
          Step::G18AL::Track,
          Step::G18AL::Token,
          Step::Route,
          Step::Dividend,
          Step::G18AL::Train,
          [Step::BuyCompany, blocks: true],
        ], round_num: round_num)
      end

      def action_processed(action)
        case action
        when Action::Assign
          company = action.entity
          target = action.target

          # Add a revenue bonus for the corporation
          # that will be removed in phase 6
          ability = Engine::Ability::HexBonus.new(
            type: :hex_bonus,
            name: 'Coal Field token',
            value: target.id,
            **{
              'bonus_name' => "Visit hex #{target.id}",
              'hex' => target.id,
              'bonus' => 10,
            }
          )
          company.owner.add_ability(ability)
        end

        @corporations.dup.each do |corporation|
          close_corporation(corporation) if corporation.share_price&.price&.zero?
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
        inside_names = route.hexes[1...-1].map(&:name)
        (termini & inside_names).each do |name|
          city_name = route.hexes.detect { |h| h.name == name }.location_name
          raise GameError, "#{city_name} must be first or last in route"
        end
      end
    end
  end
end
