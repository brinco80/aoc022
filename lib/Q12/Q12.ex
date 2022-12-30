defmodule Q12 do

  def read_and_parse(filename) do

    # read file
    {:ok, data_str} = File.read(filename)

    # convert string to integers
    points =
      data_str
      |> String.split("\n")
      |> Enum.with_index(fn element, index -> {index, element} end)
      |> Enum.flat_map(fn {x, line} ->
        line
        |> String.to_charlist()
        |> Enum.with_index(fn element, index -> {index, char2number(element)} end)
        |> Enum.map(fn {y, z} -> {{x, y}, z} end)
      end)
      |> Map.new()

    {x_max, y_max} =
      points
      |> Map.keys()
      |> Enum.reduce({-1, -1}, fn {x, y}, {x_max, y_max} -> {max(x_max, x), max(y_max, y)} end)


    start = find_val(-1, points)
    goal  = find_val(?z-97+1, points)

    points = Map.put(points, start, 0)
    points = Map.put(points, goal, ?z-97)

    %{x_max: x_max, y_max: y_max, points: points, start: start, goal: goal}
  end

  def char2number(?S), do: -1
  def char2number(?E), do: (?z-97)+1
  def char2number(el), do: el-97

  def find_val(val, map) do
    map
    |> Enum.reduce_while(nil,
      fn
        {k,^val}, _acc -> {:halt, k}
        _, acc -> {:cont, acc}
    end)
  end

  def find_vals(val, map) do
    map
    |> Enum.reduce([],
      fn
        {k,^val}, acc -> [k | acc]
        _, acc -> acc
    end)
  end

  @spec get_value(list, map) :: list
  def get_value(xys, points) do
    xys |> Enum.map(fn xy -> {xy, points[xy]} end)
  end

  @spec get_neighbors_diag({number, number}, %{
          :points => map,
          :x_max => any,
          :y_max => any,
          optional(any) => any
        }) :: list
  def get_neighbors_diag({x, y}, %{x_max: x_max, y_max: y_max, points: points}) do
    case {x, y} do
      {0, 0} ->
        [{0, 1}, {1, 1}, {1, 0}] |> get_value(points)

      {0, ^y_max} ->
        [{0, y_max - 1}, {1, y_max - 1}, {1, y_max}] |> get_value(points)

      {^x_max, 0} ->
        [{x_max - 1, 0}, {x_max - 1, 1}, {x_max, 1}] |> get_value(points)

      {^x_max, ^y_max} ->
        [{x_max - 1, y_max}, {x_max - 1, y_max - 1}, {x_max, y_max - 1}] |> get_value(points)

      {0, y} ->
        [{0, y - 1}, {0, y + 1}, {1, y}, {1, y - 1}, {1, y + 1}] |> get_value(points)

      {^x_max, y} ->
        [{x_max, y - 1}, {x_max, y + 1}, {x_max - 1, y}, {x_max - 1, y - 1}, {x_max - 1, y + 1}]
        |> get_value(points)

      {x, 0} ->
        [{x - 1, 0}, {x, 1}, {x + 1, 0}, {x - 1, 1}, {x + 1, 1}] |> get_value(points)

      {x, ^y_max} ->
        [{x - 1, y_max}, {x, y_max - 1}, {x + 1, y_max}, {x - 1, y_max - 1}, {x + 1, y_max - 1}]
        |> get_value(points)

      {x, y} ->
        [
          {x - 1, y - 1},
          {x - 1, y},
          {x - 1, y + 1},
          {x, y - 1},
          {x, y + 1},
          {x + 1, y - 1},
          {x + 1, y},
          {x + 1, y + 1}
        ]
        |> get_value(points)
    end
  end

  @spec get_neighbors({number, number}, %{
          :points => map,
          :x_max => any,
          :y_max => any,
          optional(any) => any
        }) :: list
  def get_neighbors({x, y}, %{x_max: x_max, y_max: y_max, points: points}) do
    z0 = points[{x,y}]

    case {x, y} do
      # corners
      {0, 0} -> [{0, 1}, {1, 0}] |> get_value(points)
      {0, ^y_max} -> [{0, y_max - 1}, {1, y_max}] |> get_value(points)
      {^x_max, 0} -> [{x_max - 1, 0}, {x_max, 1}] |> get_value(points)
      {^x_max, ^y_max} -> [{x_max - 1, y_max}, {x_max, y_max - 1}] |> get_value(points)
      # borders
      {0, y} -> [{0, y - 1}, {0, y + 1}, {1, y}] |> get_value(points)
      {^x_max, y} -> [{x_max, y - 1}, {x_max, y + 1}, {x_max - 1, y}] |> get_value(points)
      {x, 0} -> [{x - 1, 0}, {x, 1}, {x + 1, 0}] |> get_value(points)
      {x, ^y_max} -> [{x - 1, y_max}, {x, y_max - 1}, {x + 1, y_max}] |> get_value(points)
      # interior
      {x, y} -> [{x - 1, y}, {x, y - 1}, {x, y + 1}, {x + 1, y}] |> get_value(points)
    end
    |> Enum.filter(fn {_,z} -> z-z0<2 end) # can't climb more than 1 unit
    |> Enum.map(fn {k,_v} -> {k,1} end) # cost is always 1 to get shortest path
  end

  def manhattan_distance({x1, y1}, {x2, y2}) do
    abs(x1 - x2) + abs(y1 - y2)
  end

  def build_path([], _end_node), do: []
  def build_path(came_from, end_node) do
    path = [end_node]

    Stream.cycle([0])
    |> Enum.reduce_while(
      path,
      fn _i, [current | _] = path ->
        case came_from[current] do
          nil -> {:halt, path}
          n -> {:cont, [n | path]}
        end
      end
    )
  end

  def astar_search(start, goal, environment, heuristic, get_nodes_fn) do
    # set of opened points
    open_set = Prioqueue.new([{0, start}])
    # where a node came from
    came_from = %{}

    h = &(heuristic.(&1, goal))

    # effective cost from start to node n
    gScore = %{start => 0}
    # estimated cost from start to node n: gScore + fScore at node n
    fScore = %{start => h.(start)}

    came_from =
      Stream.cycle([1])
      |> Enum.reduce_while(
        %{open_set: open_set, gScore: gScore, fScore: fScore, came_from: came_from},
        fn _, %{open_set: open_set, gScore: gScore, fScore: fScore, came_from: came_from} ->
          case Prioqueue.extract_min(open_set) do
            # error
            {:error, :empty} ->
              {:halt, []}
            # i reach goal! end loop and return path
            {:ok, {{_, ^goal}, _}} ->
              {:halt, came_from}

            {:ok, {{_, current_node}, open_set}} ->
              new_acc =
                get_nodes_fn.(current_node, environment)
                |> Enum.reduce(
                  %{open_set: open_set, gScore: gScore, fScore: fScore, came_from: came_from},
                  fn {n, z},
                     %{open_set: open_set, gScore: gScore, fScore: fScore, came_from: came_from} =
                       acc ->
                    tentative_gScore = gScore[current_node] + z

                    if tentative_gScore < gScore[n] do
                      came_from = Map.put(came_from, n, current_node)
                      gScore = Map.put(gScore, n, tentative_gScore)

                      fScore = Map.put(fScore, n, tentative_gScore + h.(n))

                      open_set =
                        if !Prioqueue.member?(open_set, n) do
                          Prioqueue.insert(open_set, {tentative_gScore + h.(n), n})
                        else
                          open_set
                        end

                      %{open_set: open_set, gScore: gScore, fScore: fScore, came_from: came_from}
                    else
                      acc
                    end
                  end
                )
              #require IEx; IEx.pry()
              {:cont, new_acc}
          end
        end
      )
    build_path(came_from, goal)
  end

  def print_map(%{x_max: x_max, y_max: y_max, points: points}) do
    0..x_max
    |> Enum.reduce(
      [],
      fn x, acc ->
        new_line =
          0..y_max
          |> Enum.map(fn y ->
            points[{x, y}]
          end)
          |> Enum.join(" ")

        [new_line | acc]
      end
    )
    |> Enum.reverse()
    |> Enum.join("\n")
  end

  def part_i(file \\ "lib/Q12/test_data") do

    env = read_and_parse(file)
    %{start: start, goal: goal} = env

    optimal_path = astar_search(start, goal, env, &manhattan_distance/2, &get_neighbors/2)

    IO.puts("Best path has #{length(optimal_path)-1} steps")
  end

  def part_ii(file \\ "lib/Q12/test_data") do
    env = read_and_parse(file)
    %{goal: goal} = env

    starting_points = Q12.find_vals(0, env[:points])

    IO.puts("There are #{length(starting_points)} options")

    shortest_path = starting_points
    |> Enum.map(fn start_point ->
      case astar_search(start_point, goal, env, &manhattan_distance/2, &get_neighbors/2) do
        [] -> :inf
        x -> length(x)-1
      end
    end)
    # |> Enum.reduce(%{},
    #   fn path_length, acc ->
    #     {_, acc} = get_and_update_in(acc, [path_length], fn old -> {old, if(old, do: old+1, else: 1)} end)
    #     acc
    #   end
    # )
    |> Enum.min()

    IO.puts("The shortest path has #{shortest_path} steps")

  end

end
