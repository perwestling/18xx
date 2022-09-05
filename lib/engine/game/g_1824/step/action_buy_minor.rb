# frozen_string_literal: true

module Engine
  module Game
    module G1824
      module ActionBuyMinor
        def action_buy_minor(entity, connected_company, price)
          minor = @game.minor_by_id(connected_company.id)
          raise GameError, "Has no connected minor: #{connected_company.name}" unless minor

          return buy_pre_staatsbahn(minor, entity, price) if @game.pre_staatsbahn?(minor)

          buy_coal_railway(minor, entity, price)
        end

        def buy_pre_staatsbahn(pre_staatsbahn, buyer, price)
          treasury = price
          @game.log << "Pre-Staatsbahn #{pre_staatsbahn.full_name} floats and receives "\
                        "#{@game.format_currency(treasury)} in treasury"
          pre_staatsbahn.owner = buyer
          pre_staatsbahn.float!
          @game.bank.spend(treasury, pre_staatsbahn)
        end

        def buy_coal_railway(coal_railway, buyer, price)
          regional_railway = @game.associated_regional_railway(coal_railway)

          coal_railway.owner = buyer
          coal_railway.float!
          @game.bank.spend(price, coal_railway)
          g_train = @game.depot.upcoming.select { |t| @game.g_train?(t) }.shift
          treasury = price - g_train.price
          @game.log << "#{coal_railway.name} floats and buys a #{g_train.name} train from the depot "\
                        "for #{@game.format_currency(g_train.price)} and remaining #{@game.format_currency(treasury)} "\
                        'is put in treasury'
          @game.buy_train(coal_railway, g_train, g_train.price)

          share_price = @game.stock_market.par_prices.find { |s| s.price == price / 2 }
          regional_railway.ipoed = true
          @game.stock_market.set_par(regional_railway, share_price)
          @game.log << "#{buyer.name} pars #{regional_railway.name} at #{@game.format_currency(share_price.price)}"
        end
      end
    end
  end
end
