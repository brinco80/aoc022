defmodule Q11 do

  def read_and_parse(filename) do
    # read file
    {:ok, data_str} = File.read(filename)
    template = ~r/Monkey (\d+):
  Starting items: ([\d, ]+)
  Operation: (.*)
  Test: divisible by (\d+)+
    If true: throw to monkey (\d+)
    If false: throw to monkey (\d+)/m

    data_str
    |> String.split("\n\n")
    |> Enum.map(
      fn
        monkey_info ->
          [monkey, items, operation, divisor_test, true_test, false_test] = Regex.run(template, monkey_info)
          |> tl()

          [monkey, divisor_test, true_test, false_test] = [monkey, divisor_test, true_test, false_test]
          |> Enum.map(&String.to_integer/1)

          op_fn = fn x ->
            Code.eval_string(operation, [old: x]) |> elem(0)
          end

          test_fn = fn x ->
            if(rem(x, divisor_test) == 0, do: true_test, else: false_test)
          end

          items = String.split(items, ", ") |> Enum.map(&String.to_integer/1)

          {monkey, %{items: items, operation: op_fn, test: test_fn, divisor: divisor_test }}
      end
    )
    |> Enum.reduce([[], []],
      fn {monkey, %{items: items, operation: op_fn, test: test_fn, divisor: divisor_test }}, [m_items, m_ops] ->
        [[{monkey, items}| m_items], [{monkey, operation: op_fn, test: test_fn, divisor: divisor_test} | m_ops]]
      end
    )
    |> Enum.map(&Map.new/1)
    # |> Map.new()
  end

  def monkey_turn(state, monkey, monkey_rules, relief_fn ) do
    case state[monkey] do
      [item | monkey_items] ->
        new_state = Map.put(state, monkey, monkey_items)

        item = item
        |> monkey_rules[:operation].()
        |> relief_fn.()

        to_monkey = monkey_rules[:test].(item)

         {_, new_state} = new_state
         |> get_and_update_in([to_monkey], &{&1, List.insert_at(&1, -1, item)})

        monkey_turn(new_state, monkey, monkey_rules, relief_fn)
      _ -> state
    end
  end

  def process({state, inspections}, rules, relief_fn) do
    n = map_size(state)

    0..n-1
    |> Enum.reduce({state, inspections},
      fn monkey, {acc, insp} ->
        monkey_rules = rules[monkey]

        {_, insp} = insp
        |> get_and_update_in([monkey], &{&1, &1 + length(acc[monkey])})

        new_acc = monkey_turn(acc, monkey, monkey_rules, relief_fn)

        {new_acc, insp}
      end
    )
  end

  def part_i(file \\ "lib/Q11/test_data") do

    [state, rules] = read_and_parse(file)

    n = map_size(state)
    state |> IO.inspect(charlists: :as_lists)

    inspections = 0..n-1 |> Enum.map(&({&1, 0})) |> Map.new()

    {final_state, inspections} = 1..20
    |> Enum.reduce({state, inspections}, fn _i, acc -> process(acc, rules, &(div(&1,3))) end)

    IO.puts("Final state")
    IO.inspect(final_state, charlists: :as_lists)

    IO.puts("Inspections")
    IO.inspect(inspections, charlists: :as_lists)

    monkey_business = Map.values(inspections)
    |> Enum.sort(:desc)
    |> Enum.take(2)
    |> Enum.product()
    IO.puts("Level of monkey business #{monkey_business}")


  end

  def part_ii(file \\ "lib/Q10/test_data") do
    [state, rules] = read_and_parse(file)

    relief_divisor = Enum.reduce(rules, 1, fn {_, v}, acc -> acc*v[:divisor]   end)

    n = map_size(state)
    state |> IO.inspect(charlists: :as_lists)

    inspections = 0..n-1 |> Enum.map(&({&1, 0})) |> Map.new()

    {final_state, inspections} = 1..10_000
    |> Enum.reduce({state, inspections}, fn _i, acc -> process(acc, rules, &(rem(&1,relief_divisor))) end)

    IO.puts("Final state")
    IO.inspect(final_state, charlists: :as_lists)

    IO.puts("Inspections")
    IO.inspect(inspections, charlists: :as_lists)

    monkey_business = Map.values(inspections)
    |> Enum.sort(:desc)
    |> Enum.take(2)
    |> Enum.product()

    IO.puts("Level of monkey business #{monkey_business}")
  end

end
