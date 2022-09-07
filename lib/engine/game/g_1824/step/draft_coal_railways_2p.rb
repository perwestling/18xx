# frozen_string_literal: true

require_relative '../../../step/base'
require_relative 'action_buy_minor'

module Engine
  module Game
    module G1824
      module Step
        class DraftCoalRailways2p < Engine::Step::Base
          include ActionBuyMinor

          ACTIONS = %w[choose].freeze

          def setup
            entities.each(&:unpass!)
          end

          def actions(entity)
            return [] unless entity == current_entity
            return [] if finished?

            ACTIONS
          end

          def choice_name
            "Choose buy price for #{current_entity.sym} (#{current_entity.name})" if current_entity
          end

          def choices
            buy_prices = {}
            [120, 140, 160, 180, 200].each do |p|
              buy_prices[p.to_s] = p
            end
            
            buy_prices
          end

          def description
            'Choose'
          end

          def finished?
            entities.all?(&:passed?)
          end

          def process_choose(action)
            company = action.entity
            player = company.owner
            price = action.choice.to_i
            @game.log << "#{player.name} buys #{company.id} (#{company.name}) for #{@game.format_currency(price)}"
            action_buy_minor(player, company, price)
            action.entity.pass!
            @round.next_entity_index!
          end

          def action_finalized
            return unless finished?

            @round.reset_entity_index!
          end
        end
      end
    end
  end
end
