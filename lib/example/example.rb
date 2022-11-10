require_relative '../text-rpgem/text_rpgem'

path = "#{File.dirname(__FILE__)}/source/"

example_scenario = Scenario.new(
  counters: {
    strength: Counter.new(7),
    coins: Counter.new(500),
    health_potions: Counter.new(0),
    hp: Bar.new(10, 10),
  },
  hidden_counters: {
    swords: Counter.new(1),
  },
  events: {
    beginning: Event.new("#{path}beginning.txt"),
    not_enough_money: Event.new("#{path}not_enough_money.txt"),
    out: Event.new("#{path}out.txt"),
    shop: Event.new("#{path}shop.txt"),
    shop_without_sword: Event.new("#{path}shop_without_sword.txt"),
    crossroad: Event.new("#{path}crossroad.txt"),
    question: Event.new("#{path}question.txt"),
    retreat: Event.new("#{path}crossroad.txt"),
    dragon: Event.new("#{path}dragon.txt"),
    fight: Event.new("#{path}fight.txt"),
    death: Event.new("#{path}death.txt"),
    victory: Event.new("#{path}victory.txt"),
  },
) do |events, counters, hidden_counters|
  # Shop section
  events[:beginning].routes(
    shop: events[:shop].routes_by_lambda(
      lambda do |option|
        case option
        when :sword_bought
          return events[:not_enough_money] if counters[:coins].value < 300

          counters[:coins].value -= 300
          hidden_counters[:swords].value -= 1
          counters[:strength].value += 3
          return hidden_counters[:swords].value.zero? ? events[:shop_without_sword] : events[:shop]
        when :potion_bought
          return events[:not_enough_money] if counters[:coins].value < 100

          counters[:coins].value -= 100
          counters[:health_potions].value += 1
          return events[:shop]
        when :leave
          return events[:out]
        end
      end
    ),
    start: events[:out],
  )

  events[:shop_without_sword].routes_by_lambda(
    lambda do |option|
      case option
      when :potion_bought
        return events[:not_enough_money] if counters[:coins].value < 100

        counters[:coins].value -= 100
        counters[:health_potions].value += 1
        return events[:shop_without_sword]
      when :leave
        return events[:out]
      end
    end
  )

  events[:not_enough_money].routes_by_lambda(
    lambda do |option|
      case option
      when :continue
        return hidden_counters[:swords].value.zero? ? events[:shop_without_sword] : events[:shop]
      end
    end
  )

  # fight section
  events[:out].routes(
    {
      start: Events()
    }
  )
end

Window.new(example_scenario).run
