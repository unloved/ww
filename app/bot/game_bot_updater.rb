class GameBotUpdater
  attr_accessor :store, :text, :options

  def self.perform store, text, options
    self.new(store, text, options).perform
  end

  def initialize store, text, options
    self.store = store
    self.text = text
    self.options = options
  end

  def perform
    parse_state
    parse_options
    parse_pipboy
    parse_stock
    parse_new_location
    parse_used_potion
    parse_used_food
    parse_received
    parse_final
    store
  end

  def parse_options
    # if DUNGEONS.find{|key, val| options.include?(val)}
    #   self.state = key
    if options.include?(GameBotActor::ACTIONS[:check_home])
      store.state = :waiting_at_home
    elsif options.include?(GameBotActor::ACTIONS[:check_home_engineer])
      store.state = :waiting_at_home
    elsif options.include?(GameBotActor::ACTIONS[:check_newreno])
      store.state = :waiting_at_newreno
    elsif options.include?(GameBotActor::ACTIONS[:move])
      store.state = :waiting_to_move
    elsif options.include?(GameBotActor::ACTIONS[:fight])
      store.state = :waiting_to_fight
    end
  end

  def parse_pipboy
    if text.include?('Фракция')
      store.hp, store.max_hp = text.lines.find{|l| l.include?('Здоровье')}.split(": ").last.split('/').map(&:to_i)
      store.hunger = text.lines.find{|l| l.include?('Голод')}.split(": ").last.split('/').last.to_i
      store.path = text.lines.find{|l| l.include?('Расстояние')}.split(": ").last.split('/').last.to_i
      store.caps = text.lines.find{|l| l.include?('Крышки')}.split(": ").last.to_i

      if store.state.nil?
        store.state = :initial_pipboy
      end
    end
  end

  def parse_stock
    if text.lines[1].to_s.include?('СОДЕРЖИМОЕ РЮКЗАКА')
      GameBot::POTIONS.each do |potion|
        count = 0
        if text.include?(potion[:name])
          line = text.lines.find{|l| l.include?(potion[:name])}
          count = line[0..-3].gsub(/[^\d]/, '').to_i
          count = 1 if count == 0
        else
          count = 0
        end
        store.send("#{potion[:key]}=", count)
      end
      if store.state == :initial_pipboy
        store.state = :initial_stock
      end
    end
  end

  def parse_state
    if text.include?('Ты сейчас находишься в Пустоши.')
      store.state = :waiting
    end

    if text.include?('Ты отправился дальше') or text.include?('Ты отправился искать припасы в Пустоши.')
      store.state = :walking
    end

    if text.include?('Ты решил вступить в схватку с противником')
      store.state = :fighting
    end

    if text.include?('Ты отправился в лагерь')
      store.state = :walking_to_home
    end

    if text.include?('Ты покинул свой лагерь и направился в ближайшее крупное поселение.')
      store.state = :walking_to_newreno
    end

    if text.include?('Некогда здесь был довольно большой')
      store.state = :waiting_at_newreno
    end

    if text.include?('Мало крышек!')
      store.state = :spent_all_caps
    end

    if text.include?('Ты слишком устал и не можешь идти дальше.')
      sleep(60)
    end
  end

  def parse_new_location
    unless text.include?('Здоровье восстановлено')
      [0,1,2].each do |i|
        if text.lines[i].to_s.start_with?('❤')
          items = text.lines[i].split(' ')
          store.hp, store.max_hp = items[0][1..-1].split('/').map{|a| a.gsub(/[^\d]/, '')}.map(&:to_i)
          store.hunger = items[1][1..-1].to_i
        end

        if text.lines[i+1].to_s.start_with?('👣')
          store.path = text.lines[i+1][1..-1].to_i
        end
      end
    end
  end

  def parse_used_potion
    if line = text.lines.find{|l| l.include?('Использовано:')}
      GameBot::POTIONS.each do |potion|
        if line.include?(potion[:name])
          val = store.send(potion[:key])
          val -= 1
          store.send("#{potion[:key]}=", val)
          store.hp, store.max_hp = text.lines.last.split('(').first.split('/').map{|a| a.gsub(/[^\d]/, '')}.map(&:to_i)
        end
      end
    end
  end

  def parse_used_food
    if line = text.lines.find{|l| l.include?('Уровень голода: ')}
      store.hunger = line.gsub(/[^\d]/, '').to_i
    end
  end

  def parse_received
    if line = text.lines.find{|l| l.include?('Получено')}
      GameBot::POTIONS.each do |potion|
        if line.include?(potion[:name])
          val = store.send(potion[:key])
          val += 1
          store.send("#{potion[:key]}=", val)
        end
      end
    end
  end

  def parse_final
    if store.state == :waiting_to_fight
      if text.include?('Анклав') or text.include?('Поднимает связи криминального прошлого')
        store.state = :flee
      end
    end
  end
end