defmodule Q05 do
  def read_and_parse(filename) do
    # read file
    {:ok, data_str} = File.read(filename)

    # convert string to lines
    [inital_state, moves] = data_str
    |> String.split("\n\n")


    {cols, state_lines} = inital_state
    |> String.split("\n")
    |> List.pop_at(-1)

    n_cols = div(String.length(cols) + 1, 3+1)

    {:ok, regex} = ["(?:\\[(.)\\]|   )"]
    |> Stream.cycle()
    |> Enum.take(n_cols)
    |> Enum.join(" ")
    |> Regex.compile()


  #  IEx.pry()

    state =
      1..n_cols
      |> Enum.map(&({&1, []}))
      |> Map.new()

    state = state_lines
    |> Enum.map(
      fn line ->
        IO.inspect(line)

        Regex.run(regex, line)
      end
    )
    |> IO.inspect()
    |> Enum.reduce(state,
      fn matches, acc ->
        tl(matches)
        |> Enum.reduce({acc, 1},
          fn
            "", {new_acc, i} ->
              {new_acc, i+1}
            content, {new_acc, i} ->
              new_acc =
                new_acc
                |> Map.put(i, List.insert_at(new_acc[i], -1, content))
              {new_acc, i+1}
          end
        )
        |> elem(0)
      end
    )

    parsed_moves = moves
    |> String.split("\n")
    |> Enum.map(
      fn line ->
        [n,from,to] = Regex.run(~r"move (\d+) from (\d+) to (\d+)", line)
        |> tl()
        |> Enum.map(&String.to_integer/1)

        {n, from, to}
      end
    )

    {state, parsed_moves}
  end


  def apply_move({n, from, to}, state) do
    1..n
    |> Enum.reduce(state,
      fn _, acc ->
        {el, from_list} = List.pop_at(acc[from], 0)
        to_list = List.insert_at(acc[to], 0, el)

        acc
        |> Map.put(from, from_list)
        |> Map.put(to, to_list)
      end
    )
  end

  def apply_move_fifo({n, from, to}, state) do
    {pile, rem} = Enum.split(state[from], n)
    to_list = pile ++ state[to]

    state
    |> Map.put(from, rem)
    |> Map.put(to, to_list)
  end

  def part_i(file \\ "lib/Q05/test_data") do

    {state, moves} = read_and_parse(file)

    moves
    |> Enum.reduce(state,
      fn move, acc ->
        apply_move(move, acc)
      end
    )
    |> Map.values()
    |> Enum.map(
      fn els ->
        hd(els)
      end
    )
    |> Enum.join()
  end

  def part_ii(file \\ "lib/Q05/test_data") do

    {state, moves} = read_and_parse(file)

    moves
    |> Enum.reduce(state,
      fn move, acc ->
        apply_move_fifo(move, acc)
      end
    )
    |> Map.values()
    |> Enum.map(
      fn els ->
        hd(els)
      end
    )
    |> Enum.join()

  end

end
