defmodule Q23 do
  def code2int(?#), do: 1
  def code2int(?.), do: 0

  def int2code(1, _), do: "#"
  def int2code(0, _), do: "."
  def int2code(nil, default), do: int2code(default, nil)

  def read_and_parse(filename) do

    # read file
    {:ok, data_str} = File.read(filename)

    # convert string to integers
    points =
      data_str
      |> String.split("\n")
      |> Enum.with_index(fn element, index -> {index, element} end)
      |> Enum.flat_map(fn {y, line} ->
        line
        |> String.to_charlist()
        |> Enum.with_index(fn element, index -> {index, code2int(element)} end)
        |> Enum.filter(fn {_x,z} -> z != 0 end)
        |> Enum.map(fn {x, _z} -> {x, y} end)
      end)
      |> MapSet.new()

    %{limits: get_edges(points), data: points, direction: :north}
  end


  def get_edges(input) do
    input
    |> MapSet.to_list()
    |> Enum.reduce(
      {:inf, :inf, -10000, -10000},
      fn {x, y}, {min_x, min_y, max_x, max_y} ->
        {
          min(min_x, x),
          min(min_y, y),
          max(max_x, x),
          max(max_y, y)
        }
      end
    )
  end

def is_direction_ok(dir, {x,y}, state) do
  case dir do
    :north -> for i <- -1..1, do: {x+i, y-1}
    :south -> for i <- -1..1, do: {x+i, y+1}
    :west -> for i <- -1..1, do: {x-1, y+i}
    :east -> for i <- -1..1, do: {x+1, y+i}
  end
  |> MapSet.new()
  |> MapSet.disjoint?(state.data)
end

def move({x,y}, :north), do: {x, y-1}
def move({x,y}, :south), do: {x, y+1}
def move({x,y}, :west), do: {x-1, y}
def move({x,y}, :east), do: {x+1, y}

def next_position(elf, %{direction: dir} = state) do
  directions = 0..2
  |> Enum.reduce([dir],
    fn _, [d | _ ] = acc ->
      [next_direction(d) | acc]
    end
  )
  |> Enum.reverse()

  directions
  |> Enum.reduce_while(elf,
    fn dir, acc ->
      if is_direction_ok(dir, elf, state) do
        {:halt, move(elf, dir)}
      else
        {:cont, acc}
      end
    end
  )
end


def has_neighbors({x, y}, state) do
  neigh_set = (for i <- (x-1)..(x+1), j <- (y-1)..(y+1), {i,j}!={x,y}, do: {i,j})
  |> MapSet.new()

  !MapSet.disjoint?(state.data, neigh_set)
end


 def next_direction(:north), do: :south
 def next_direction(:south), do: :west
 def next_direction(:west), do: :east
 def next_direction(:east), do: :north

 def round(%{limits: _limits, data: data, direction: direction} = state) do

  elves_with_neighbors = data
  |> MapSet.to_list()
  |> Enum.filter(
    fn elf ->
      elf
      |> has_neighbors(state)
    end
  )

  movements = elves_with_neighbors
  |> Enum.reduce([], # plan phase
    fn elf,acc ->
      [{elf, next_position(elf, state)} | acc]
    end
  )
  |> Enum.group_by( fn {_k,v} -> v end ) # conflict resolution
  |> Enum.filter(
    fn {_k,v} -> length(v) == 1 end
  )
  |> Enum.flat_map( fn {_k,v} -> v end)
  |> Map.new() # real movements

  positions = movements
  |> Enum.reduce(data,
    fn {from, to}, acc ->
      acc
      |> MapSet.delete(from)
      |> MapSet.put(to)
    end
  )

  %{state | data: positions, direction: next_direction(direction)}
 end


  def part_i(filename \\ "lib/Q23/test_data") do
    state0 = read_and_parse(filename)

    state = 0..9
    |> Enum.reduce(state0,
      fn _i, acc ->
        __MODULE__.round(acc)
      end
    )

    {xmin, ymin, xmax, ymax} = get_edges(state.data)
    (xmax - xmin + 1)*(ymax - ymin + 1) - MapSet.size(state.data)
  end

  def part_ii(filename \\ "lib/Q23/test_data") do
    state0 = read_and_parse(filename)

    {state, n_rounds} = Stream.cycle([0])
    |> Enum.reduce_while({state0, 0},
      fn _i, {acc, n} ->
        new_acc = __MODULE__.round(acc)

        if new_acc.data == acc.data do
          {:halt, {new_acc, n+1}}
        else
          {:cont, {new_acc, n+1}}
        end
      end
    )

    get_edges(state.data) |> IO.inspect(label: "edges")
    IO.inspect(n_rounds, label: "rounds")
  end

end
