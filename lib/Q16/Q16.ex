defmodule Q16 do

  def read_and_parse(filename) do
    # read file
    {:ok, data_str} = File.read(filename)

    rx = ~r/Valve (.+) has flow rate=(\d+); tunnels? leads? to valves? (.+)/

    # convert string to integers
    data_str
    |> String.split("\n")
    |> Enum.map(fn line ->
      #require IEx; IEx.pry()
      [valve, flow, neighbors] = Regex.run(rx, line)
      |> tl()

      neighbors = neighbors |> String.split(", ")

      {valve, %{flow: String.to_integer(flow), neighbors: neighbors}}
    end)
    |> Map.new()
  end

  def get_neighbors(valve, map) do
    get_in(map, [valve, :neighbors])
    |> Enum.map(fn v -> {v, map[v]} end)
    |> Map.new()
  end

#  def reward(%{t: t}, final_time) when t == final_time, do: 10_000_000
  def reward(%{position: x, valves: vs, t: t} = _state, final_time) do
    vs[x]*(final_time - t)
  end



  def get_actions(%{t: 30} = _state, _map), do: []
  def get_actions(%{position: x, valves: vs, t: _t} = _state, map) do
    ns = map[x][:neighbors]

    case vs do
      %{^x => 0} -> [:open | ns]
      _ -> ns
    end
  end

  def get_neighbor_sa(x, map) do
    get_actions(x, map)
    |> Enum.map(&{&1, apply_action(x, &1, map)})
  end

  def apply_action(%{position: x, valves: vs, t: t} = state, :open, map) do
    %{state | valves: Map.put(vs, x, get_in(map, [x, :flow])), t: t+1 }
  end

  def apply_action(%{t: t} = state, y, _map), do: %{state | position: y, t: t+1 }

  def get_reduced_state(map) do
    map
    |> Enum.filter(fn {_,v} -> v[:flow] !=0 end)
    |> Enum.map( fn {k,_} -> k end)
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

  def astar_search(start, goal, environment, heuristic, get_nodes_fn, is_goal) do
    # set of opened points
    open_set = Prioqueue.new([{0, start}])
    # where a node came from
    came_from = %{}

    h = &(heuristic.(&1, goal))

    # effective cost from start to node n
    gScore = %{start => 0}
    # estimated cost from start to node n: gScore + fScore at node n
    fScore = %{start => h.(start)}

    {came_from, gScore} =
      Stream.cycle([1])
      |> Enum.reduce_while(
        %{open_set: open_set, gScore: gScore, fScore: fScore, came_from: came_from},
        fn _, %{open_set: open_set, gScore: gScore, fScore: fScore, came_from: came_from} ->
          case Prioqueue.extract_min(open_set) do
            # error
            {:error, :empty} ->
              IO.puts("ERROR!")
              {:halt, {[], gScore}}
            {:ok, {{_, current_node}, open_set}} ->
              if is_goal.(current_node, goal) do
                {:halt, {came_from, gScore}}
              else
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
        end
      )
    #IO.inspect(gScore)
    #build_path(came_from, goal)
  end


  def get_state0(map) do
    %{position: "DD", valves: Enum.map(map, fn {k,_v} -> {k,0} end ) |> Map.new(), t: 0}
  end


  def fast() do
    map = read_and_parse("lib/Q16/test_data")
    x0 = get_state0(map)
    {map, x0}
  end

  def simulation(x0, map, final_step) do
    1..final_step
    |> Enum.reduce_while({x0, 0, []},
      fn _, {x, acc_r, actions} ->
        #IO.inspect(x[:position])
        sas = get_neighbor_sa(x, map)

        n = length(sas)

        if n != 0 do
          i = :rand.uniform(n)-1
          # if i==0 do
          #   require IEx; IEx.pry()
          # end
          {a, x1} = Enum.at(sas, i)

          r = if(a == :open, do: reward(x1, final_step), else: 0)

          if Enum.all?(x1[:valves], fn {_k,v} -> v>0 end ) do
            {:halt, {x1, acc_r+r, [a | actions]}}
          else
            {:cont, {x1, acc_r+r, [a | actions]}}
          end
        else
          {:halt, {x, acc_r, actions}}
        end
      end
    )
  end

  def flow(_, _, path, 0), do: path
  def flow(state, map, path, t) do
    get_neighbor_sa(state, map)
    |> Enum.map(
      fn {a, next_state} ->
         flow(next_state, map, [{a, next_state[:position]} | path], t-1)
      end
    )
  end

  def part_i(file \\ "lib/Q16/test_data") do

    final_time = 30

    map = read_and_parse(file)
    important_valves = get_reduced_state(map)

    state0 = %{position: "AA", valves: Enum.map(important_valves, fn k -> {k,0} end ) |> Map.new(), t: 1}




    goal_valves = important_valves
    |> Enum.map(fn valve -> {valve, map[valve][:flow]} end)
    |> Map.new()

    # random search!!!

    0..1000000
    |> Enum.reduce({0, {state0, []}},
      fn _i, {best_r, {_xf, _as}} = acc ->
        {x1, r, actions} = simulation(state0, map, 30)

        if best_r < r do
          {r, {x1, actions}}
        else
          acc
        end
      end
    )
    #|> Enum.sort(:asc)
    #|> Enum.take(10)

  end



  def part_ii(file \\ "lib/Q15/test_data", limit \\ 20) do

  end

end
