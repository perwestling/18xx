# frozen_string_literal: true

require_relative '../base'

module Engine
  module Step
    module G18SJ
      class ChoosePriority < Base
        ACTIONS = %w[choose].freeze

        def round_state
          {
            choice_done: false,
          }
        end

        def actions(_entity)
          return [] unless choice_available?(@chooser)

          ACTIONS
        end

        def description
          'Choose Priority'
        end

        def current_entity
          return chooser if choice_available?(chooser)

          super
        end

        def active_entities
          [chooser]
        end

        def choice_name
          'Get priority deal'
        end

        def choices
          @choices = Hash.new { |h, k| h[k] = [] }
          @choices['activate'] = 'Use ability'
          @choices['wait'] = 'Wait for now'
          @choices
        end

        def help
          return super unless choice_available?(chooser)

          "Do you want to active the ability of #{@game.nils_ericsson.name} to become priority dealer?"
        end

        def active?
          choice_available?(chooser)
        end

        def blocking?
          choice_available?(chooser)
        end

        def purchasable_companies(_entity = nil)
          []
        end

        def process_choose(action)
          @round.choice_done = true
          return if action.choice == 'wait'

          @log << "#{chooser.name} becomes the new priority dealer by using #{@game.nils_ericsson.name} ability"
          @round.goto_entity!(chooser)
          @game.abilities(@game.nils_ericsson, :base) do |ability|
            @game.nils_ericsson.remove_ability(ability)
          end
        end

        def choice_available?(entity)
          return false unless entity == chooser

          # Make this active if:
          #  1. Nils Ericsson still open
          #  2. Priority Deal ability not used
          #  3. ability to choose not used this round
          !@round.choice_done &&
          chooser&.player? &&
          !@game.nils_ericsson.closed? &&
          @game.abilities(@game.nils_ericsson, :base)
        end

        private

        def chooser
          @chooser ||= @game.nils_ericsson&.owner
        end
      end
    end
  end
end
