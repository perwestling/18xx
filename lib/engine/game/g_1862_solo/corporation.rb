# frozen_string_literal: true

require_relative '../../corporation'

module Engine
  module Game
    module G1862Solo
      class Corporation < Engine::Corporation
        def total_shares
          7
        end

        def floated?
          @floated
        end

        def percent_to_float
          return 0 if @floated

          @ipo_owner.percent_of(self) - 40
        end
      end
    end
  end
end
