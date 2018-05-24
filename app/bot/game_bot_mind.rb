class GameBotMind

  include Healing

  attr_accessor :store

  def self.perform store
    self.new(store).perform
  end

  def initialize store
    self.store = store
  end

  def perform
    return :update_pipboy if need_update_pipboy?
    return :update_stock if need_update_stock?
    return :update_environment if need_update_environment?
    return :eat_food if hungry?
    return :heal if need_to_heal?
    return :move_deep_to_dungeon if waiting_in_dungeon?
    return :move_to_dungeon if waiting_to_dungeon?
    return :return_home if need_to_return_home?
    return :craft_supersteam if need_to_craft_supersteam?
    return :move_to_newreno if need_to_move_to_newreno?
    return :craft_potions if need_to_craft_potions?
    return :learn if need_to_learn?
    return :move_to_wastelands if need_to_move_to_wastelands?
    return :move if able_to_move?
    return :flee if need_to_flee?
    return :fight if able_to_fight?
  end

  private

  def need_update_pipboy?
    store.hp == nil
  end

  def need_update_stock?
    store.medpack == nil
  end

  def need_update_environment?
    store.state == :initial_stock
  end

  def hungry?
    store.hunger > 50
  end

  def need_to_heal?
    (store.hp < store.max_hp) and find_potion
  end

  def need_to_return_home?
    if store.state == :waiting_to_move
      ((store.path > GameBot::SOFT_LIMIT_PATH) and (store.hp <= GameBot::SOFT_LIMIT_HP)) or (store.path >= GameBot::HARD_LIMIT_PATH)
    end
  end

  def need_to_craft_supersteam?
    (store.state == :waiting_at_home) and (store.hp <= store.max_hp)
  end

  def able_to_move?
    store.state == :waiting_to_move
  end

  def able_to_fight?
    store.state == :waiting_to_fight
  end

  def need_to_move_to_newreno?
    (store.state == :waiting_at_home) and potion_to_craft.present?
  end

  def need_to_craft_potions?
    (store.state == :waiting_at_newreno) and potion_to_craft.present?
  end

  def need_to_learn?
    (store.state == :waiting_at_newreno) and !potion_to_craft.present?
  end

  def need_to_move_to_wastelands?
    [:waiting_at_home, :waiting_at_newreno, :spent_all_caps].include?(store.state)
  end

  def need_to_flee?
    store.state == :flee
  end

  def waiting_in_dungeon?
    store.state == :waiting_in_dungeon
  end

  def waiting_to_dungeon?
    store.state == :waiting_to_dungeon
  end
end