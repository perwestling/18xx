# frozen_string_literal: true

module Engine
  module Game
    module G1824
      module PossiblyBuyBonds
        def buy_shares(entity, shares, exchange: nil, swap: nil, allow_president_change: true, borrow_from: nil)
          puts "#### BUY SHARES"
          unless @game.bond_railway?(shares.corporation)
            return @game.depot.buy_shares(entity,
                                          shares,
                                          exchange: exchange,
                                          swap: swap,
                                          allow_president_change: allow_president_change,
                                          borrow_from: borrow_from)
          end

          puts "#### CHECK LEGAL"
          check_legal_buy(entity,
                          shares,
                          exchange: exchange,
                          swap: swap,
                          allow_president_change: false)
          puts "#### BUY SHARES"
          @game.share_pool.buy_shares(entity,
                                      shares,
                                      exchange: exchange,
                                      swap: swap,
                                      borrow_from: borrow_from,
                                      allow_president_change: false)
          puts "DONE!"
        end
      end
    end
  end
end
