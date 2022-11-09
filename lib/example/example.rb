require_relative '../text-rpgem/text_rpgem'

path = "#{File.dirname(__FILE__ )}/source/"

example_scenario = Scenario.new(
  counters: {
    strength: Counter.new(7),
    coins: Counter.new(500),
    mana_potions: Counter.new(0),
    hp: Bar.new(10, 10),
  },
  events: {
    beginning: Event.new("#{path}beginning.txt"),
    not_enough_money: Event.new("#{path}not_enough_money.txt"),
    out: Event.new("#{path}out.txt"),
    shop: Event.new("#{path}shop.txt"),
    shop_without_sword: Event.new("#{path}shop_without_sword.txt"),
  },
) do |events, counters|
  events[:beginning].routes(
    shop: events[:shop].routes_by_lambda(
      lambda do |option|
        case option
        when :sword_bought
          return events[:not_enough_money] if counters[:coins].value < 300

          counters[:coins].value -= 300
          counters[:strength].value += 3
          return events[:shop_without_sword]
        when :potion_bought
          return events[:not_enough_money] if counters[:coins].value < 100

          counters[:coins].value -= 100
          counters[:mana_potions].value += 1
          return events[:shop]
        when :leave
          return events[:out]
        end
      end
    ),
  )

  events[:shop_without_sword].routes_by_lambda(
    lambda do |option|
      case option
      when :potion_bought
        return events[:not_enough_money] if counters[:coins].value < 100

        counters[:coins].value -= 100
        counters[:mana_potions].value += 1
        return events[:shop_without_sword]
      when :leave
        return events[:out]
      end
    end
  )

end

Window.new(example_scenario).run
