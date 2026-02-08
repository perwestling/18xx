# frozen_string_literal: true

require_relative '../../g_1880/step/track'

module Engine
  module Game
    module G1880RomaniaRegatul
      module Step
        class Track < G1880::Step::Track
          def pay_tile_cost!(entity_or_entities, tile, rotation, hex, spender, _cost, _extra_cost)
            return super unless @game.amira_corporation?(spender)

            @log << "#{@game.acting_for_entity(entity_or_entities).name} acts for #{spender.name} and lays tile ##{tile.name} with rotation #{rotation} on #{hex.name}"\
                    "#{tile.location_name.to_s.empty? ? '' : " (#{tile.location_name})"}"
          end
        end
      end
    end
  end
end
