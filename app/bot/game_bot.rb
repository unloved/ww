class GameBot
  attr_accessor :store

  POTIONS = [
    {key: :baffout, name: 'Баффаут', hp: 17, stack: 2},
    {key: :medx, name: 'Мед-Х', hp: 30, stack: 2},
    {key: :medpack, name: 'Медпак', hp: 60, stack: 3}
  ]

  FOOD = [
    '/use_101',
    '/use_114',
    '/use_107',
    '/use_111'
  ]

  def initialize
    self.store = OpenStruct.new(hp: nil, max_hp: nil, hunger: nil, path: nil, medpack: nil, medx: nil, baffout: nil, caps: nil, state: nil)
  end

  def response text, options
    return '🔜31 км' if options.to_a.include?('🔜31 км')
    self.store = GameBotUpdater.perform(store, text, options)
    action = GameBotMind.perform(store)
    puts "<<<<<  #{store.state} -> #{action} >>>>>>"
    GameBotActor.perform(store, action) if action
  end

  # DUNGEONS = {
  #   batman: '🦇Бэт-пещера'
  # }
  #

end