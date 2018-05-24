class GameBot
  attr_accessor :store

  LIB_PATH = '/Users/unloved/www/td/build'

  SOFT_LIMIT_HP = 160
  SOFT_LIMIT_PATH = 50
  HARD_LIMIT_PATH = 60
  LEARN_SUBJECT = :learn_hp

  FOOD = [
    '/use_101',
    '/use_102',
    '/use_103',
    '/use_106'
  ]

  DUNGEONS = [
    # 'Старая шахта',
    # '🚽Сточная труба',
    # '⚙️Открытое убежище',
    '🦇Бэт-пещера',
    '🦆Перевал Уткина'
  ]

  POTIONS = [
    {key: :baffout, name: 'Баффаут', hp: 17, stack: 2},
    {key: :medx, name: 'Мед-Х', hp: 30, stack: 2},
    {key: :medpack, name: 'Медпак', hp: 60, stack: 3}
  ]


  def initialize
    self.store = OpenStruct.new(hp: nil, max_hp: nil, hunger: nil, path: nil, medpack: nil, medx: nil, baffout: nil, caps: nil, state: nil)
  end

  def response text, options
    DUNGEONS.each do |d|
      return d if options.to_a.include?(d)
    end
    # return '🔜31 км' if options.to_a.include?('🔜31 км')
    self.store = GameBotUpdater.perform(store, text, options)
    action = GameBotMind.perform(store)
    puts "<<<<<  #{store.state} -> #{action} >>>>>>"
    GameBotActor.perform(store, action) if action
  end

end