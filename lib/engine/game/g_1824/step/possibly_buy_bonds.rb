# frozen_string_literal: true

module Engine
  module Game
    module G1824
      module PossiblyBuyBonds
        def buy_shares(entity, shares, exchange: nil, swap: nil, allow_president_change: true, borrow_from: nil)
          president_change_allowed = @game.bond_railway?(shares.corporation) ? false : allow_president_change
          check_legal_buy(entity,
            shares,
            exchange: exchange,
            swap: swap,
            allow_president_change: president_change_allowed)

          @game.share_pool.buy_shares(entity,
                                  shares,
                                  exchange: exchange,
                                  swap: swap,
                                  borrow_from: borrow_from,
                                  allow_president_change: president_change_allowed)

          maybe_place_home_token(shares.corporation)
        end
      end
    end
  end
end
