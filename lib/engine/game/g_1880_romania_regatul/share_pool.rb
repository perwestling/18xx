# frozen_string_literal: true

require_relative '../../share_pool'

module Engine
  module Game
    module G1880RomaniaRegatul
      class SharePool < Engine::SharePool
        def transfer_shares(bundle,
                            to_entity,
                            spender: nil,
                            receiver: nil,
                            price: nil,
                            allow_president_change: true,
                            swap: nil,
                            borrow_from: nil,
                            swap_to_entity: nil,
                            corporate_transfer: nil)
          return super unless @game.amira_corporation?(bundle.corporation)

          # Do not change president when transferring shares of the Amira corporation
          super(
            bundle,
            to_entity,
            spender: spender,
            receiver: receiver,
            price: price,
            allow_president_change: false,
            swap: swap,
            borrow_from: borrow_from,
            swap_to_entity: swap_to_entity,
            corporate_transfer: corporate_transfer
          )
        end
      end
    end
  end
end
