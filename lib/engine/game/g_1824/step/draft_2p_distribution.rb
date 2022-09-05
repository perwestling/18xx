# frozen_string_literal: true

require_relative '../../../step/base'
require_relative 'action_buy_minor'

module Engine
  module Game
    module G1824
      module Step
        class Draft2pDistribution < Engine::Step::Base
          attr_reader :companies, :choices
          include ActionBuyMinor

          ACTIONS = %w[bid].freeze
          BID_CHOICES = [120, 140, 160, 180, 200].freeze

          def bid_choices
            BID_CHOICES
          end

          def min_bid(_company)
            120
          end
          
          def min_increment
            20
          end
          
          def max_bid(_entity, _company)
            200
          end

          def max_place_bid(_entity, _company)
            200
          end

          def setup
            @companies = @game.companies.reject { |c| c.owned_by_player? || !c.stack }.sort
            @stack_bought = false
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
            'Draft Companies'
          end

          def finished?
            @companies.all? { |c| c.owned_by_player? }
          end

          def actions(entity)
            return [] if finished?
            return [] if @game.buy_to_complete

            actions = ACTIONS

            entity == current_entity ? actions : []
          end

          # def process_pass(_action)
          #   raise GameError, 'Cannot pass' unless only_one_company?

          #   company = @companies[0]
          #   old_price = company.min_bid
          #   company.discount += 10
          #   new_price = company.min_bid
          #   @log << "#{company.name} price decreases from #{@game.format_currency(old_price)} "\
          #           "to #{@game.format_currency(new_price)}"

          #   @round.next_entity_index!

          #   return unless new_price == company.min_auction_price

          #   choose_company(current_entity, company)
          #   action_finalized
          # end

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
            action_buy_minor(player, company, company.value)
            company.owner = player

            if company.stack == 4
              @game.buy_to_complete = {player: other_player, coal_railway: other_company}
              @log << "#{other_player.name} will later select buy price for #{other_company.sym}"
            else
              action_buy_minor(other_player, other_company, company.value)
              other_company.owner = other_player
            end
            #   @companies.clear
            # else
            #   @log << "#{player.name} chooses a company"
            #   @companies -= available_companies
            #   discarded = available_companies.sort_by { @game.rand }
            #   discarded.delete(company)
            #   @companies.concat(discarded)
            # end

          end

          def action_finalized
            return unless finished?

            @round.reset_entity_index!

            # @choices.each do |player, companies|
            #   companies.each do |company|
            #     if blank?(company)
            #       company.owner = nil
            #       @log << "#{player.name} chose #{company.name}"
            #     else
            #       company.owner = player
            #       player.companies << company
            #       price = company.min_bid
            #       player.spend(price, @game.bank) if price.positive?

            #       float_minor(company)

            #       @log << "#{player.name} buys #{company.name} for #{@game.format_currency(price)}"
            #     end
            #   end
            # end
          end

          # def float_minor(company)
          #   return unless (minor = @game.minors.find { |m| m.id == company.id })

          #   minor.owner = company.player
          #   @game.bank.spend(company.treasury, minor)
          #   minor.float!
          # end

          def may_choose?(company)
            company.type != 'Coal Railway'
          end

          def may_bid?(company)
            company.type == 'Coal Railway'
          end

          def committed_cash(_player, _show_hidden = false)
            0
          end
        end
      end
    end
  end
end
