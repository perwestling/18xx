# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1824
      module Step
        class BuyCoalRailway2p < Engine::Step::Base
          ACTIONS = %w[choose].freeze

          def actions(entity)
            puts "### ACTIONS for #{entity}"
            return [] unless entity == current_entity
            puts "#####"
            return [] unless find_company(entity)
            puts "#### Return actions"
            ACTIONS
          end

          def choice_name
            "Choose buy price for #{@company.sym} (#{@company.name})" if @company
          end

          def choices
            return {} unless buy_to_complete

            buy_prices = {}
            [120, 140, 160, 180, 200].each do |p|
              buy_prices[p.to_s] = p
            end
            
            buy_prices
          end

          def description
            'Choose'
          end

          def buy_to_complete
            puts "BUY TO COMPLETE CALLED!"
            @game.buy_to_complete
          end

          def process_choose(action)
            raise GameError, "Not yet implemented"
        # @game.company_made_choice(@company, action.choice, :choose)
        #     @company = nil
        #     pass!
          end

          # def skip!
          #   pass!
          # end

          def find_company(entity)
            return nil unless (result = buy_to_complete)
            return nil unless entity == result[:player]

            @company = result[:coal_railway]
            @company
          end
        end
      end
        # class BuyCoalRailway < Engine::Step::SpecialBuy
        #   attr_reader :par1

        #   def buyable_items(entity)
        #     return [@par1, @par2, @par3, @par4, @par5] if buy_to_complete

        #     []
        #   end

        #   def description
        #     'Select price'
        #   end

        #   def short_description
        #     'SP'
        #   end

        #   def active_entities
        #     return unless (result = buy_to_complete)

        #     [result[:player]]
        #   end
    
        #   def active?
        #     buy_to_complete
        #   end
    
        #   def blocks?
        #     buy_to_complete
        #   end
    
        #   def buy_to_complete
        #     puts "BUY TO COMPLETE CALLED!"
        #     @game.buy_to_complete
        #   end

        #   def process_special_buy(_action)
        #     raise GameError, "Not yet implemented"
        #     # if !@game.loading && !@game.can_buy_coal_marker?(action.entity)
        #     #   raise GameError, 'Must be connected to Virigina Coalfields to purchase'
        #     # end

        #     # @game.buy_coal_marker(action.entity)
        #   end

        #   def setup
        #     super
        #     @par1 ||= Item.new(description: '120', cost: 120)
        #     @par2 ||= Item.new(description: '140', cost: 140)
        #     @par3 ||= Item.new(description: '160', cost: 160)
        #     @par4 ||= Item.new(description: '180', cost: 180)
        #     @par5 ||= Item.new(description: '200', cost: 200)
        #   end
        # end
      # end
    end
  end
end
