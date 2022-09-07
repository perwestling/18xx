# frozen_string_literal: true

require_relative '../../../step/base'
require_relative 'action_buy_minor'

module Engine
  module Game
    module G1824
      module Step
        class DraftStacks2p < Engine::Step::Base
          attr_reader :companies, :choices
          include ActionBuyMinor

          ACTIONS = %w[bid].freeze
          # BID_CHOICES = [120, 140, 160, 180, 200].freeze

          # def bid_choices
          #   BID_CHOICES
          # end

          # def min_bid(_company)
          #   120
          # end
          
          # def min_increment
          #   20
          # end
          
          # def max_bid(_entity, _company)
          #   200
          # end

          # def max_place_bid(_entity, _company)
          #   200
          # end

          def setup
            @companies = @game.companies.reject { |c| c.owned_by_player? || !c.stack }.sort
            entities.each(&:unpass!)
          end

          def tiered_auction_companies
            stacked_companies.sort_by { |k, _v| k }.to_h.values
          end

          def stacked_companies
            @companies.reject { |c| c.owned_by_player? }.group_by(&:stack)
          end

          def pass_description
            'Pass (Buy)'
          end

          def available
            @companies
          end

          def may_purchase?(_company)
            false
          end

          def may_choose?(_company)
            true
          end

          def auctioning; end

          def bids
            {}
          end

          def visible?
            true
          end

          def players_visible?
            true
          end

          def name
            'Draft Round'
          end

          def description
            'Draft Stack'
          end

          def finished?
            @companies.all? { |c| c.owned_by_player? }
          end

          def actions(entity)
            return [] if finished?

            entity == current_entity ? ACTIONS : []
          end

          def process_bid(action)
            choose_company(action.entity, action.company)
            @round.next_entity_index!
            action_finalized
          end

          def choose_company(player, company)
            available_companies = available

            raise GameError, "Cannot choose #{company.name}" unless available_companies.include?(company)

            other_player = (@game.players - [player]).first
            other_company = (stacked_companies[company.stack] - [company]).first

            @log << "#{player.name} selects #{company.name} and #{other_player.name} gets #{other_company.name}"
            company.owner = player
            other_company.owner = other_player
            if company.stack == 4
              @game.coal_railways_to_draft = [company, other_company]
              @log << "The price for the Coal Railways will be chosen later"
            else
              action_buy_minor(player, company, company.value)
              action_buy_minor(other_player, other_company, company.value)
            end
          end

          def action_finalized
            return unless finished?

            @round.reset_entity_index!
          end

          def may_choose?(company)
            true
          end

          def may_bid?(company)
            false
          end

          def committed_cash(_player, _show_hidden = false)
            0
          end
        end
      end
    end
  end
end
