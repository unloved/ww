class GameBotActor
  include Healing

  ACTIONS = {
    update_pipboy: '📟Пип-бой',
    update_stock: '🎒Рюкзак',
    update_environment: '🔎Действие',
    use_medpack: '/medpack',
    use_medx: '/medx1',
    use_baffout: '/buffout',
    move: '👣Идти дальше',
    fight: '⚔️Дать отпор',
    # batman: '🦇Бэт-пещера',
    return_home: '⛺️Вернуться',
    craft_supersteam: '💉++ Суперстим',
    move_to_newreno: '🏘В Нью-Рино',
    check_home: '⛺️Лагерь',
    check_home_engineer: '🛠Верстак',
    check_newreno: '🏘Нью-Рино',
    craft_medpack: '💌 Медпак',
    craft_medx: '💉 Мед-Х',
    craft_baffout: '💊 Баффаут',
    move_to_wastelands: '👣Пустошь',
    flee: '🏃Дать деру',
    learn_hp: '❤️Живучесть',
    learn_agility: '🤸🏽‍♂️Ловкость',
    learn_strength: '💪Сила',
    teleport: '🔜31 км',
    waiting: nil
  }

  attr_accessor :store, :action

  def self.perform store, action
    self.new(store, action).perform
  end

  def initialize store, action
    self.store = store
    self.action = action
  end

  def perform
    if ACTIONS.key?(action)
      ACTIONS[action]
    else
      self.send(action)
    end
  end

  private

  def eat_food
    GameBot::FOOD.sample
  end

  def heal
    potion = find_potion
    ACTIONS["use_#{potion[:key]}".to_sym]
  end

  def craft_potions
    ACTIONS["craft_#{potion_to_craft[:key]}".to_sym]
  end

  def learn
    ACTIONS[GameBot::LEARN_SUBJECT]
  end

  def move_deep_to_dungeon
    :move_deep_to_dungeon
  end
end