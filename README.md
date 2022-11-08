# TextRpgem
#### Warning
#### This is a student project. Viewer discretion is advised
TextRpgem is a text quest creation tool.
It helps you to connect your isolated text files in monolithic story tree.

Main idea is pretty intuitive, but there is also some space for experiments with
custom routing between pages using custom counters (health, mana, etc).

If you don't want to create your own GUI you can use built-in terminal interface.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add text-rpgem

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install text-rpgem

## Usage

### Text markup
You story consists of events. Markup your text files
like this

```
{

Description of event

}

[option_name1::option description]

[option_name2::option description]

[option_name3::option description]
```
In your application you will refer to your option 
by option name, player will only see option descriptions

We strongly recommend you to structure your files meaningfully,
but at the and of a day that is only your decision

### Your first quest
You have done all markup things. Now you are ready to
create your scenario

1) Call constructor and provide hash with all your
events and their aliases. That is done to parse all 
files and catch parsing exceptions before first run.

``` ruby
test_scenario = Scenario.new(
  events: {
    beginning: Event("story_beginning.txt"),
    river: Event("river.txt"),
    forest: Event("forest.txt"),
    tree: Event("tree.txt"),
    cave: Event("cave.txt"),
    monster: Event("battle.txt"),
  }
) 
```

2) Provide necessary bloc to create routes between
your events using routes method
``` ruby
my_scenario = Scenario.new(_) do |events|
  events[:beginning].routes(
    {
      left: events[:river],
      right: events[:forest],
    }
  )
end
```

3) Add more routes to create tree structure of
your story.
``` ruby
my_scenario = Scenario.new(events) do |events|
  events[:beginning].routes(
    {
      left: events[:river].routes(
        get_back: events[:beginning],
      ),
      right: events[:forest].routes(
        cave: events[:cave].routes(
          {
            deeper: events[:monster],
          }
        ),
        further_in_forest: events[:tree],
      ),
    }
  )
end
```
You can rearrange your tree if you feel bad about
depth
``` ruby
my_scenario = Scenario.new(events) do |events|
  events[:beginning].routes(
    {
      left: events[:river].routes(
        get_back: events[:beginning],
      ),
      right: events[:forest],
    }
  )

  events[:forest].routes(
    cave: events[:cave].routes(
      {
        deeper: events[:monster],
      }
    ),
    further_in_forest: events[:tree],
  )
end
```

### Advanced options
Use combination of counters and custom routes (routes_by_lambda
instead of routes method) to create complex scenario

``` ruby
test_scenario = Scenario.new(
  events: {
    choise: Event("choise.txt"),
    happy_end: Event("happy_end.txt"),
    you_died: Event("you_died.txt"),
  },
  counters: {
    karma: Counter(1),
  },
) do |events|
  events[choise].routes_by_lambda(
    lambda do |option|
      case option
      when :good
        counters[:karma].value += 1
      when :bad
        counters[:karma].value -= 1
      end

      return events[:you_died] unless counters[:karma].value.positive?

      return events[:happy_end]
    end
  )
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/text-rpgem. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/text-rpgem/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the TextRpgem project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/text-rpgem/blob/master/CODE_OF_CONDUCT.md).
