# frozen_string_literal: true

require_relative '../../../step/track'

module Engine
  module Game
    module G1824
      module Step
        class Track < Engine::Step::Track
          def can_lay_tile?(entity)
            # Rule X.4: Regional created by construction railway does not lay any tiles
            return false if @game.bond_railway?(entity)

            super
          end

          # Rule X.4: Construction railway lay tiles for free
          def pay_tile_cost!(_entity_or_entities, tile, rotation, hex, spender, _cost, _extra_cost)
            return super unless @game.construction_railway?(spender)

            @log << "#{spender.name} lays tile ##{tile.name} with rotation #{rotation} on #{hex.name}"\
                "#{tile.location_name.to_s.empty? ? '' : " (#{tile.location_name})"}"
          end

          def lay_tile_action(action, entity: nil, spender: nil)
            tile = action.tile
            hex = action.hex

            old_tile = action.hex.tile
            tile_lay = get_tile_lay(action.entity)

            super

            # Rule XI.4: Trigger potential Vienna tokening (for 2 players) when Vienna upgraded to brown
            if track_upgrade?(old_tile, tile, action.hex) && action.hex.id == 'E12' && tile.name == '493'
              @game.set_token_vienna_entity(action.entity)
            end
          end
        end
      end
    end
  end
end
