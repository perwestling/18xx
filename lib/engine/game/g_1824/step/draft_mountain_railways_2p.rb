# frozen_string_literal: true

require_relative 'draft_stacks_2p'
require_relative 'action_buy_minor'

module Engine
  module Game
    module G1824
      module Step
        class DraftMountainRailways2p < DraftStacks2p
          attr_reader :mountain_railways
          include ActionBuyMinor

          ACTIONS = %w[bid pass].freeze

          def setup
            @mountain_railways = @game.companies.select { |c| c.type == 'Mountain Railway' && !c.closed? }.sort
            entities.each(&:unpass!)
          end

          def help
            'Optionally buy one Mountain Railway. When both players have had the chance to buy one, any unsold are removed from the game.'
          end

          def tiered_auction_companies
            [@mountain_railways.dup]
          end

          def pass_description
            'Pass (Buy)'
          end

          def available
            @mountain_railways
          end

          def name
            'Draft Mountain Railways'
          end

          def description
            'Buy one or pass'
          end

          def finished?
            entities.all?(&:passed?)
          end

          def actions(entity)
            return [] if finished?

            entity == current_entity ? ACTIONS : []
          end

          def process_pass(action)
            @log << "#{action.entity.name} passes"
            action.entity.pass!
            @round.next_entity_index!
            action_finalized
          end

          def process_bid(action)
            buy_mountain_railway(action.entity, action.company, action.price)
            @mountain_railways.delete(action.company) 
            action.entity.pass! # Use pass so that we know when both players have acted
            @round.next_entity_index!
            action_finalized
          end

          def action_finalized
            return unless finished?

            puts "Finalized"
            @mountain_railways.each do |m|
              puts "Mountain  railway #{m}"
              @log << "Mountain Railway #{m.name} is removed from the game."
              m.close!
            end
            puts "Reset entity index"
            @round.reset_entity_index!
          end
        end
      end
    end
  end
end
