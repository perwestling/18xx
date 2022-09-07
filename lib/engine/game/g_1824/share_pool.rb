# frozen_string_literal: true

require_relative '../../share_pool'

module Engine
  module Game
    module G1824
      class SharePool < Engine::SharePool
        def fit_in_bank?(bundle)
          return super unless @game.bond_railway?(bundle.corporation)

          true
        end

        def bank_at_limit?(corporation)
          return super unless @game.bond_railway?(corporation)

          false
        end
      end
    end
  end
end
