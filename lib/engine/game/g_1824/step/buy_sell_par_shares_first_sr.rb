# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'
require_relative 'action_buy_minor'
module Engine
  module Game
    module G1824
      module Step
        class BuySellParSharesFirstSr < Engine::Step::BuySellParShares
          include ActionBuyMinor

          def can_buy_company?(_player, _company)
            !bought?
          end

          def can_buy?(_entity, bundle)
            super && @game.buyable?(bundle.corporation)
          end

          def can_sell?(_entity, bundle)
            super && @game.buyable?(bundle.corporation)
          end

          def can_gain?(_entity, bundle, exchange: false)
            return false if exchange

            super && @game.buyable?(bundle.corporation)
          end

          def can_exchange?(_entity)
            false
          end

          def process_buy_company(action)
            entity = action.entity
            company = action.company
            price = action.price
            company.value = price

            super

            action_buy_minor(entity, company, price)
          end
        end
      end
    end
  end
end
