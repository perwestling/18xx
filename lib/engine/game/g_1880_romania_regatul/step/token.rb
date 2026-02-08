# frozen_string_literal: true

require_relative '../../g_1880/step/token'

module Engine
  module Game
    module G1880RomaniaRegatul
      module Step
        class Token < G1880::Step::Token
          def place_token(entity, city, token, connected: true, extra_action: false,
                          special_ability: nil, check_tokenable: true, spender: nil, same_hex_allowed: false)
            super
            
            return unless @game.amira_corporation?(entity)

            @game.log << "#{@game.acting_for_entity(entity).name} places the token for #{entity.name}"
          end
        end
      end
    end
  end
end
