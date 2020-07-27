# frozen_string_literal: true

module Engine
  module Round
    class RouteBonus
      def self.bonus_for_all(entity, routes)
        candidates = entity.abilities(:route_bonus)
        return 0 if candidates.empty?

        triggered_bonus_infos = []
        candidates.first.bonuses.each do |bonus_info|
          routes.each do |route|
            hexes = route.hexes.map(&:name)
            bonus_hexes = bonus_info.hexes.select { |hex_name| hexes.include? hex_name }
            triggered_bonus_infos << bonus_info if bonus_hexes.length == bonus_info.hexes.length
          end
        end
        triggered_bonus_infos.uniq.sum(&:bonus)
      end
    end
  end
end
