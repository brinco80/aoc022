defmodule Q09 do

  def read_and_parse(filename) do
    # read file
    {:ok, data_str} = File.read(filename)

    data_str
    |> String.split("\n")
    |> Enum.map(
      fn
        line ->
          [direction, n_steps] =
            Regex.run(~r/(.) (\d+)/, line) |> tl()
          {direction, String.to_integer(n_steps)}
      end
    )
  end

  def manhattan_distance({x1, y1}, {x2, y2}) do
    abs(x1 - x2) + abs(y1 - y2)
  end

  def sign(x,y) when x>=y, do: 1
  def sign(x,y) when x<y, do: -1


  def tail_physics({x_h, y_h}, {x_t, y_t}) when abs(x_h-x_t)<2 and abs(y_h-y_t)<2, do: {x_t, y_t}
  def tail_physics({x_h, y_h}, {x_t, y_t}) do
    dx = x_h - x_t
    dy = y_h - y_t

    sign_x = sign(x_h, x_t)
    sign_y = sign(y_h, y_t)

    {x_t + min(abs(dx),1)*sign_x, y_t + min(abs(dy),1)*sign_y}
  end

  def direction2vec("D"), do: {0,-1}
  def direction2vec("L"), do: {-1,0}
  def direction2vec("R"), do: {1,0}
  def direction2vec("U"), do: {0,1}

  def add_vector({x1,y1}, {x2,y2}), do: {x1+x2, y1+y2}

  def apply_command({direction, n_steps}, [head, tail]) do
    vector = direction2vec(direction)

    1..n_steps
    |> Enum.reduce({[head, tail], []},
      fn _, {[current_head, current_tail], tail_history} ->
        new_head = add_vector(current_head, vector)
        new_tail = tail_physics(new_head, current_tail)

        {[new_head, new_tail], [new_tail | tail_history]}
      end
    )
  end

  def rope_physics([head | tail ], vector) do
    new_head = add_vector(head, vector)

    new_rope = tail
    |> Enum.reduce([new_head],
      fn current_knot, [previous_knot | _] = rope ->
        new_knot = tail_physics(previous_knot, current_knot)
        [new_knot | rope]
      end
    )
    |> Enum.reverse()

    new_rope
  end

  def apply_command_n({direction, n_steps}, rope) do
    vector = direction2vec(direction)

    #rope = Tuple.to_list(rope)

    1..n_steps
    |> Enum.reduce({rope, []},
      fn _, {rope, tail_history} ->
        new_rope = rope_physics(rope, vector)

        {new_rope, [List.last(rope) | tail_history]}
      end
    )

    #{List.to_tuple(new_rope_list), tail_history}
  end


  def part_i(file \\ "lib/Q09/test_data") do

    commands = read_and_parse(file)

    {final_state, tail_history} =
    commands
    |> Enum.reduce({[{0,0}, {0,0}], [{0,0}]},
      fn command, {state, history} ->
        {new_state, command_history} = apply_command(command, state)

        {new_state, command_history ++ history }
      end
    )

    tail_history = [List.last(final_state) | tail_history]
    |> Enum.reverse()
    |> Enum.uniq()

    IO.puts("Tail history")
    IO.inspect(tail_history)
    IO.puts("Final tail position")
    IO.inspect(final_state)
    IO.puts("Tail visited #{length(tail_history)} positions."  )

  end

  def part_ii(file \\ "lib/Q09/test_data") do
    commands = read_and_parse(file)

    rope = List.duplicate({0,0}, 10)

    {final_state, tail_history} =
    commands
    |> Enum.reduce({rope, [{0,0}]},
      fn command, {state, history} ->
        {new_state, command_history} = apply_command_n(command, state)

        {new_state, command_history ++ history}
      end
    )

    tail_history = [List.last(final_state) | tail_history] |> Enum.reverse() |> Enum.uniq()
    IO.puts("Tail history")
    IO.inspect(tail_history)

    IO.puts("Final rope position")
    IO.inspect(final_state)
    IO.puts("Tail visited #{length(tail_history)} positions."  )

  end

end
