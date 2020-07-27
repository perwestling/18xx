# frozen_string_literal: true

require_relative '../special'

module Engine
  module Round
    module G18AL
      class Special < Special
        def _process_action(action)
          super

          return unless action.is_a? Action::Assign

          company = action.entity
          target = action.target

          # Add a revenue bonus for the corporation
          # that will be removed in phase 6
          ability = Engine::Ability::HexBonus.new(
            type: :hex_bonus,
            name: 'Coal Field token',
            value: target.id,
            bonus_name: "Visit hex #{target.id}",
            hex: target.id,
            bonus: 10
          )
          company.owner.add_ability(ability)
        end
      end
    end
  end
end
