# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G18SJ
      module Meta
        include Game::Meta

        DEV_STAGE = :alpha
        PROTOTYPE = true

        GAME_SUBTITLE = 'Let There Be Rail'
        GAME_DESIGNER = 'Örjan Wennman'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18SJ'
        GAME_LOCATION = 'Sweden and Norway'
        GAME_PUBLISHER = :self_published
        GAME_RULES_URL = 'https://drive.google.com/file/d/1WgvqSp5HWhrnCAhAlLiTIe5oXfYtnVt9/view?usp=drivesdk'

        PLAYER_RANGE = [2, 6].freeze
        OPTIONAL_RULES = [
          {
            sym: :oscarian_era,
            short_name: 'The Oscarian Era',
            desc: 'Full cap only, sell even if not floated, no par at 100',
          },
          {
            sym: :two_player_variant,
            short_name: 'A.W. Edelswärds 2 Player Variant',
            desc: 'A.W. Edelswärd "automa" plays the 3rd player',
            players: [2],
          },
        ].freeze
      end
    end
  end
end
