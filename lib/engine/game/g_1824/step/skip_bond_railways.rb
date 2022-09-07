# frozen_string_literal: true

require_relative '../../../step/buy_company'

module Engine
  module Game
    module G1824
      module SkipBondRailways
        def actions(entity)
          return [] if @game.bond_railway == entity

          super
        end
      end
    end
  end
end
