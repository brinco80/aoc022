defmodule Q17 do

  def read_and_parse(filename) do
    # read file
    {:ok, data_str} = File.read(filename)

    # convert string to integers
    jets = data_str
    |> String.codepoints()
    |> Enum.map(
      fn
        ">" -> 1
        "<" -> -1
      end
    )

    state = %{
      settled: Map.new(0..6, fn x -> {x, 0} end),
      current_shape: nil,
      position: []
    }

    {jets, state}
  end


  def get_next_shape(nil), do: get_next_shape("o")
  def get_next_shape("-"), do: %{next: "+", position:  [{3,5}, {2,4}, {3,4}, {4,4}, {3,3}], left: 2, right: 4, bottom: 3}
  def get_next_shape("+"), do: %{next: "_|", position: [{4,5},{4,4},{2,3},{3,3},{4,3}], left: 2, right: 4, bottom: 3 }
  def get_next_shape("_|"), do: %{next: "|", position: [{2,6},{2,5},{2,4},{2,3} ], left: 2, right: 2, bottom: 3}
  def get_next_shape("|"), do: %{next: "o", position:  [{2,4},{3,4},{2,3},{3,3} ], left: 2, right: 3, bottom: 3}
  def get_next_shape("o"), do: %{next: "-", position:  [{2,3},{3,3},{4,3},{5,3} ], left: 2, right: 5, bottom: 3}


  def is_settled(xs, settled) do
    floor = settled |> Enum.map(fn {k,v} -> {k,v} end)

    xs
    |> Enum.reduce_while(false,
      fn x, _acc ->
        if x in floor do
          {:halt, true}
        else
          {:cont, false}
        end
      end
    )

    #xs |> MapSet.new() |> MapSet.disjoint?(settled)
  end

  def constraint(x) when x==7, do: x-1
  def constraint(x) when x==-1, do: 0
  def constraint(x), do: x

  def apply_jet(xs, jet, settled) do
    {{xmin, _}, {xmax, _}} = xs
    |> Enum.min_max()

    new_xs = cond  do
      xmin==0 && jet == -1 -> xs
      xmax==6 && jet == 1 -> xs
      true ->
        Enum.map(xs, fn {x,y} -> {x+jet, y} end)
    end

    settled_set = settled
    |> Enum.map(fn {x,y} -> {x,y-1} end)
    |> MapSet.new()

    # check collisions
    no_collision = MapSet.new(new_xs)
    |> MapSet.disjoint?( settled_set )

    if(no_collision, do: new_xs, else: xs)
  end

  def dynamics({[], state}, full_jet) do
    dynamics({full_jet, state}, full_jet)
  end

  def dynamics({[jet | rest], %{position: xs, settled: settled}= state}, full_jet) do
    require IEx; IEx.pry()
    # apply jet
    p1 = xs |> apply_jet(jet, settled)
    #require IEx; IEx.pry()
    if !is_settled(p1, settled) do
      # down one
      p2 = p1 |> Enum.map(fn {x,y} -> {x,y-1} end)

      # go on with the recursion
      dynamics({rest, %{state | position: p2}}, full_jet)
    else
      # solidify block
      new_settled = solidify(p1, settled) #|> IO.inspect()
      {rest, %{state | position: p1, settled: new_settled}}
    end
  end

  def solidify(xs, settled) do
    max_xs = xs
    |> Enum.reduce(%{},
      fn {x,y}, acc ->
        case acc do
          %{^x => yy } -> Map.put(acc, x, max(y,yy))
          _ -> Map.put(acc, x, y)
        end
      end
    )
    |> Map.new(fn {x,y} -> {x,y+1} end)


    max_xs |> Enum.reduce(settled,
      fn {x,y}, acc -> Map.get_and_update(acc, x, &{&1, max(y,&1)}) |> elem(1) end
    )
    |> Map.new()

  end

  def drop_block(%{current_shape: shape, settled: ss} =  state) do
    %{next: new_shape, position: ps} = get_next_shape(shape)

    stack_top = ss
    |> Enum.reduce(0, fn {_x,y},acc -> max(acc, y) end)

    ps = ps
    |> Enum.map(fn {x,y} -> {x,y+stack_top} end)


    %{state | current_shape: new_shape, position: ps}
  end

  def part_i(file \\ "lib/Q17/test_data", n) do
    {jets, x0} = read_and_parse(file)

    # x1 = drop_block(x0) |> IO.inspect()
    # {j_rest, x2} = dynamics({jets, x1}) |> IO.inspect()

    # x3 = drop_block(x2) |> IO.inspect()
    # {j_rest, x4} = dynamics({j_rest, x3}) |> IO.inspect()

    1..n |> Enum.reduce({jets, x0},
      fn _i, {j, x} ->
        x1 = drop_block(x)
        {j_rest, x2} = dynamics({j,x1}, jets)

      end
    )


  end



  def part_ii(file \\ "lib/Q17/test_data"

  ) do

  end

end
