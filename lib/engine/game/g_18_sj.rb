# frozen_string_literal: true

require_relative '../config/game/g_18_sj'
require_relative 'base'

module Engine
  module Game
    class G18SJ < Base
      register_colors(
        black: '#0a0a0a', # STJ
        brightGreen: '#7bb137', # UGJ
        brown: '#7b352a', # BJ
        green: '#237333', # SWB
        lavender: '#baa4cb', # SNJ
        olive: '#808000', # TGOJ (not right)
        orange: '#f48221', # MOJ
        red: '#d81e3e', # OSJ
        violet: '#4d2674', # OKJ
        white: '#ffffff', # KFJr
        yellow: '#FFF500' # MYJ
      )

      load_from_json(Config::Game::G18SJ::JSON)

      DEV_STAGE = :alpha

      GAME_LOCATION = nil
      GAME_RULES_URL = 'mailto:orjanwennman@gmail.com'
      GAME_DESIGNER = 'Örjan Wennman'
      GAME_PUBLISHER = :self

      # Stock market 350 triggers end of game in same OR, but bank full OR set
      GAME_END_CHECK = { bankrupt: :immediate, stock_market: :current_or, bank: :full_or }.freeze

      SELL_BUY_ORDER = :sell_buy_sell

      # At most a corporation/minor can do two tile lay / upgrades but two is
      # only allowed if one improves main line situation. This means a 2nd
      # tile lay/upgrade might not be allowed.
      TILE_LAYS = [{ lay: true, upgrade: true }, { lay: true, upgrade: true }].freeze

      EVENTS_TEXT = Base::EVENTS_TEXT.merge(
        'full_cap' => ['Full Capitalization', 'Unsold corporations becomes Full Capitalization and move shares to IPO'],
        'nationalization' => ['Nationalization check', 'The topmost corporation without trains are nationalized'],
      ).freeze

      STATUS_TEXT = {
        'incremental' => [
          'Incremental Cap',
          'New corporations will be capitalized for all 10 shares as they are sold',
        ],
        'fullcap' => [
          'Full Cap',
          'New corporations will be capitalized for 10 x par price when 60% of the IPO is sold',
        ],
      }.merge(Base::STATUS_TEXT).freeze

      OPTIONAL_PRIVATE_A = %w[NE AEvR].freeze
      OPTIONAL_PRIVATE_B = %w[NOJ FRY].freeze
      OPTIONAL_PRIVATE_C = %w[NOHAB MV].freeze
      OPTIONAL_PRIVATE_D = %w[GKB SB].freeze
      OPTIONAL_PUBLIC = %w[STJ TGOJ ÖSJ MYJ].freeze

      MAIN_LINE_ICON_NAMES = %w[M-S G-S L-S].freeze

      MAIN_LINE_ORIENTATION = {
        # Stockholm-Malmo main line
        'F9' => [2, 5],
        'E8' => [2, 5],
        'D7' => [2, 5],
        'C6' => [2, 5],
        'B5' => [2, 5],
        'A4' => [1, 5],
        # Stockholm-Goteborg main line
        'F11' => [0, 3],
        'E12' => [0, 3],
        'D13' => [0, 2],
        'C12' => [2, 5],
        'B11' => [2, 5],
        # Stockholm-Lulea main line
        'G12' => [1, 3],
        'F13' => [0, 3],
        'E14' => [0, 4],
        'E16' => [1, 4],
        'E18' => [1, 4],
        'E20' => [1, 4],
        'E22' => [1, 4],
        'E24' => [1, 5],
        'F25' => [2, 5],
      }.freeze

      BONUS_ICONS = %w[N S O V M m B b].freeze

      def init_corporations(stock_market)
        corporations = super
        prng = random
        removed_corporation = select(prng, OPTIONAL_PUBLIC)
        to_close = corporations.find { |corp| corp.name == removed_corporation }
        corporations.delete(to_close)
        @log << "Removed corporation: #{to_close.full_name} (#{to_close.name})"
        corporations
      end

      def init_companies(players)
        companies = super
        prng = random
        @removed_companies = []
        [OPTIONAL_PRIVATE_A, OPTIONAL_PRIVATE_B, OPTIONAL_PRIVATE_C, OPTIONAL_PRIVATE_D].each do |optionals|
          to_remove = find_company(companies, prng, optionals)
          companies.delete(to_remove)
          @removed_companies << to_remove
        end
        @log << "Removed companies: #{@removed_companies.map(&:name).join(', ')}"
        companies
      end

      def random
        seed = @id.to_s.scan(/\d+/).first.to_i
        Random.new(seed)
      end

      def select(rnd, collection)
        collection[rnd.rand(collection.length)]
      end

      def find_company(companies, rnd, collection)
        index = rnd.rand(collection.length)
        sym = collection[index]
        to_find = companies.find { |comp| comp.sym == sym }
        @log << "Could not find company with sym='#{sym}' in #{@companies}" if to_find.nil?
        to_find
      end

      def minor_khj
        @minor_khj ||= minor_by_id('KHJ')
      end

      def company_khj
        @company_khj ||= company_by_id('KHJ')
      end

      def nils_ericsson
        @nils_ericsson ||= company_by_id('NE')
      end

      def ipo_name(entity)
        entity&.capitalization == :incremental ? 'Treasury' : 'IPO'
      end

      def setup
        # Possibly remove from map icons belonging to closed companies
        @removed_companies.each { |c| close_cleanup(c) }

        @minors.each do |minor|
          train = @depot.upcoming[0]
          train.buyable = false
          minor.buy_train(train, :free)
          hex = hex_by_id(minor.coordinates)
          hex.tile.cities[0].place_token(minor, minor.next_token)
        end

        nils_ericsson&.add_ability(Ability::Close.new(
          type: :close,
          when: :train,
          corporation: nils_ericsson.abilities(:shares).shares.first.corporation.name,
        ))

        @main_line_hexes = @hexes.select { |h| main_line_hex?(h) }

        @tile_lays = []
        @fulfilled_main_line_hexes = []

        update_cert_limit!

        # Create virtual SJ corporation
        @sj = Corporation.new(
          sym: 'SJ',
          name: 'Statens Järnvägar',
          logo: '18_sj/SJ',
          tokens: [],
        )
        @sj.owner = @bank

        @pending_nationalization
      end

      def cert_limit
        @set_cert_limit
      end

      def new_auction_round
        Round::Auction.new(self, [
          Step::CompanyPendingPar,
          Step::G18SJ::WaterfallAuction,
        ])
      end

      def stock_round
        Round::Stock.new(self, [
          Step::DiscardTrain,
          Step::G18SJ::BuySellParShares,
        ])
      end

      def operating_round(round_num)
        Round::G18SJ::Operating.new(self, [
          Step::Bankrupt,
          Step::DiscardTrain,
          Step::SpecialTrack,
          Step::G18SJ::BuyCompany,
          Step::G18SJ::IssueShares,
          Step::HomeToken,
          Step::Track,
          Step::Token,
          Step::Route,
          Step::G18SJ::Dividend,
          Step::G18SJ::BuyTrain,
          [Step::BuyCompany, blocks: true],
        ], round_num: round_num)
      end

      def action_processed(action)
        is_tile_lay = action.is_a?(Action::LayTile)
        check_main_line_lay(action) if is_tile_lay
        @tile_lays << action if is_tile_lay

        super
      end

      def redeemable_shares(entity)
        return [] unless entity.corporation?
        return [] unless round.steps.find { |step| step.class == Step::G18SJ::IssueShares }.active?

        share_price = stock_market.find_share_price(entity, :right).price

        bundles_for_corporation(share_pool, entity)
          .each { |bundle| bundle.share_price = share_price }
          .reject { |bundle| bundle.shares.size > 1 }
          .reject { |bundle| entity.cash < bundle.price }
      end

      def revenue_for(route, stops)
        revenue = super

        icons = visited_icons(stops)

        [lapplandspilen_bonus(icons),
         stockholm_goteborg_bonus(icons, stops),
         stockholm_malmo_bonus(icons, stops),
         bergslagen_bonus(icons),
         orefields_bonus(icons)].map { |b| b[:revenue] }.each { |r| revenue += r }

        revenue
      end

      def revenue_str(route)
        stops = route.stops
        stop_hexes = stops.map(&:hex)
        str = route.hexes.map do |h|
          stop_hexes.include?(h) ? h&.name : "(#{h&.name})"
        end.join('-')

        icons = visited_icons(stops)

        [lapplandspilen_bonus(icons),
         stockholm_goteborg_bonus(icons, stops),
         stockholm_malmo_bonus(icons, stops),
         bergslagen_bonus(icons),
         orefields_bonus(icons)].map { |b| b[:description] }.compact.each { |d| str += " + #{d}" }

        str
      end

      def clean_up_after_entity
        # Remove fulfilled main line hexes
        @tile_lays.each { |action| remove_main_line_bonus(action) }
        @tile_lays = []

        return unless @round.current_entity

        # Make SJ passable if current corporation has E train
        # This is a workaround that is not perfect in case a
        # corporation has E train + other train, but very unlikely
        type = @round.current_entity.trains.any? { |t| t.name == 'E' } ? :neutral : :blocking
        @sj.tokens.each { |t| t.type = type }
      end

      def event_close_companies!
        @companies.each { |c| close_cleanup(c) }
        super

        return if minor_khj.closed?

        @log << "Minor #{minor_khj.name} closes and the home token is removed"
        minor_khj.tokens.first.remove!
        minor_khj.close!
      end

      def event_full_cap!
        @corporations
          .select { |c| c.percent_of(c) == 100 }
          .reject(&:closed?)
          .each do |c|
            @log << "#{c.name} becomes full capitalization as not pared"
            c.capitalization = :full
            # IPO price should be used
            c.always_market_price = false
          end
      end

      def event_nationalization!
        @pending_nationalization = true
      end

      def pending_nationalization?
        @pending_nationalization
      end

      def perform_nationalization
        @pending_nationalization = false
        candidates = @corporations.select { |c| !c.closed? && c.operated? && c.trains.empty? }
        if candidates.empty?
          @log << 'Nationalization skipped as no trainless floated corporations'
          return
        end

        # Merge the corporation with highest share price, and use the first operated as tie break
        merged = candidates.max_by { |c| [c.share_price.price, -@round.entities.find_index(c)] }

        nationalize_major(merged)
      end

      # If there are 2 station markers on the same city the
      # merged corporation must remove one and return it to its charter.
      def remove_duplicate_tokens(target, merged)
        merged_tokens = merged.tokens.map(&:city).compact
        target.tokens.each do |token|
          city = token.city
          token.remove! if merged_tokens.include?(city)
        end
      end

      def remove_reservation(merged)
        hex = hex_by_id(merged.coordinates)
        tile = hex.tile
        cities = tile.cities
        city = cities.find { |c| c.reserved_by?(merged) } || cities.first
        city.remove_reservation!(merged)
      end

      def transfer_home_token(target, merged)
        merged_home_token = merged.tokens.first
        return unless merged_home_token.city

        transfer_token(merged_home_token, merged, target)
      end

      def transfer_non_home_tokens(target, merged)
        merged_tokens = merged.tokens.select(&:city)
        return unless merged_tokens.any?

        merged_tokens.each { |token| transfer_token(token, merged, target) }
      end

      def check_connected(route, token)
        return if route.train.name == 'E'

        super
      end

      private

      def check_main_line_lay(action)
        last_tile_lay = @tile_lays.first
        corporation = last_tile_lay&.entity
        return if main_line_lay?(last_tile_lay)
        return unless action.entity == corporation

        unless main_line_lay?(action)
          game_error('Second tile lay or upgrade only allowed if first or second improves the main line!')
        end

        @log << "#{corporation.name} gets extra tile lay/upgrade as main line improvement."
      end

      def main_line_lay?(action)
        return false unless action
        return false unless @main_line_hexes.include?(action.hex)
        return false if @fulfilled_main_line_hexes.include?(action.hex)

        main_line_hex?(action.hex) && connects_main_line?(action.hex)
      end

      def main_line_hex?(hex)
        (MAIN_LINE_ICON_NAMES & hex.tile.icons.map(&:name)).any?
      end

      def connects_main_line?(hex)
        orientation = MAIN_LINE_ORIENTATION[hex.name]
        return unless orientation

        edge1 = "#{hex.name}_#{orientation[0]}_0"
        edge2 = "#{hex.name}_#{orientation[1]}_0"
        edges = hex.tile.paths.flat_map(&:edges).map(&:id)
        edges.include?(edge1) && edges.include?(edge2)
      end

      def remove_main_line_bonus(action)
        @fulfilled_main_line_hexes << action.hex if main_line_lay?(action)
      end

      def update_cert_limit!
        certs_per_player =
          case @corporations.reject(&:closed?).size
          when 10
            { 2 => 39, 3 => 26, 4 => 20, 5 => 16, 6 => 13 }
          when 9
            { 2 => 35, 3 => 23, 4 => 18, 5 => 14, 6 => 12 }
          when 8
            { 2 => 30, 3 => 20, 4 => 15, 5 => 12, 6 => 10 }
          when 7
            { 2 => 26, 3 => 17, 4 => 13, 5 => 11, 6 => 9 }
          else
            game_error("No cert limit defined for #{@corporations.length} corporations")
          end.freeze
        @set_cert_limit = certs_per_player[@players.size]
        game_error("No cert limit defined for #{@players.size} player") unless @cert_limit
      end

      def nationalize_major(major)
        @log << "#{major.name} is nationalized"

        remove_reservation(major)
        transfer_home_token(@sj, major)
        transfer_non_home_tokens(@sj, major)

        major.trains.each do |train|
          minor.remove_train(train)
          trains.delete(train)
        end

        major.companies.each(&:close!)

        # Decrease share price two step and then give compensation with this price
        prev = major.share_price.price
        @stock_market.move_left(major)
        @stock_market.move_left(major)
        log_share_price(major, prev)
        refund = major.share_price.price
        @players.each do |p|
          refund_amount = 0
          p.shares_of(major).dup.each do |s|
            next unless s

            refund_amount += (s.percent / 10) * refund
            s.transfer(major)
          end
          next unless refund_amount.positive?

          @log << "#{p.name} receives #{format_currency(refund_amount)} in share compensation"
          @bank.spend(refund_amount, p)
        end

        # Transfer bank pool shares to IPO
        @share_pool.shares_of(major).dup.each do |s|
          s.transfer(major)
        end

        major.spend(major.cash, @bank)
        major.close!
        @log << "#{major.name} closes and its tokens becomes #{@sj.name} tokens"

        # Cert limit changes as the number of corporations decrease
        update_cert_limit!
        @log << "Certificate limit is now #{cert_limit}"
      end

      def transfer_token(token, merged, target)
        replacement_token = Engine::Token.new(target)

        city = token.city
        @log << "#{merged.name}'s token in #{city.hex.name} is replaced with an #{target.name} token"
        token.remove!
        city.place_token(target, replacement_token, check_tokenable: false)
      end

      def visited_icons(stops)
        icons = []
        stops.each do |s|
          icons.concat(s.hex.tile.icons.map(&:name).select { |n| BONUS_ICONS.include?(n) })
        end
        icons.sort!
      end

      def lapplandspilen_bonus(icons)
        bonus = { revenue: 0 }

        if icons.include?('N') && icons.include?('S')
          bonus[:revenue] += 100
          bonus[:description] = 'N/S'
        end

        bonus
      end

      def stockholm_goteborg_bonus(icons, stops)
        bonus = { revenue: 0 }
        hexes = stops.map { |s| s.hex.id }

        if icons.include?('O') && icons.include?('V') && hexes.include?('G10') && hexes.include?('A10')
          bonus[:revenue] += 120
          bonus[:description] = 'Ö/V[S/G]'
        end

        bonus
      end

      def stockholm_malmo_bonus(icons, stops)
        bonus = { revenue: 0 }
        hexes = stops.map { |s| s.hex.id }

        if icons.include?('O') && icons.include?('V') && hexes.include?('G10') && hexes.include?('A2')
          bonus[:revenue] += 100
          bonus[:description] = 'Ö/V[S/M]'
        end

        bonus
      end

      def bergslagen_bonus(icons)
        bonus = { revenue: 0 }

        if icons.include?('B') && icons.count('b') == 1
          bonus[:revenue] += 50
          bonus[:description] = 'b/B'
        end
        if icons.include?('B') && icons.count('b') > 1
          bonus[:revenue] += 80
          bonus[:description] = 'b/B/b'
        end

        bonus
      end

      def orefields_bonus(icons)
        bonus = { revenue: 0 }

        if icons.include?('M') && icons.count('m') == 1
          bonus[:revenue] += 50
          bonus[:description] = 'm/M'
        end
        if icons.include?('M') && icons.count('m') > 1
          bonus[:revenue] += 100
          bonus[:description] = 'm/M/m'
        end

        bonus
      end

      def close_cleanup(company)
        cleanup_gkb(company) if company.sym == 'GKB'
        cleanup_sb(company) if company.sym == 'SB'
      end

      def cleanup_gkb(company)
        @log << "Removes icons for #{company.name}"
        remove_icons(%w[C8 C16 E8], 'GKB')
      end

      def cleanup_sb(company)
        @log << "Removes icons for #{company.name}"
        remove_icons(%w[A6 C2 D5 F19 F23 G26], 'port')
      end

      def remove_icons(to_be_cleaned, icon_name)
        @hexes
          .select { |hex| to_be_cleaned.include?(hex.name) }
          .each do |hex|
            icons = hex.tile.icons
            icons.reject! { |i| i.name == icon_name }
            hex.tile.icons = icons
          end
      end
    end
  end
end
