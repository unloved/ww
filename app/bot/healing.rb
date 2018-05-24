require 'active_support/concern'

module Healing
  extend ActiveSupport::Concern

  included do
    def find_potion
      potion = GameBot::POTIONS.first(2).find do |potion|
        amount = store.send(potion[:key])
        new_hp = store.hp + potion[:hp]
        amount > 0 and ( new_hp <= store.max_hp )
      end

      unless potion
        potion = if store.hp < store.max_hp and store.medpack > 0
          GameBot::POTIONS.last
        end
      end

      potion
    end

    def potion_to_craft
      GameBot::POTIONS.find{|potion| store.send(potion[:key]) < potion[:stack]}
    end
  end
end
