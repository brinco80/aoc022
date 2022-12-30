defmodule Q14 do

  def read_and_parse(filename) do
    # read file
    {:ok, data_str} = File.read(filename)

    # convert string to integers
    data_str
    |> String.split("\n")
    |> Enum.map(fn block ->
      block
      |> String.split(" -> ")
      |> Enum.map(
        fn tuple_str ->
          [a,b] = String.split(tuple_str, ",")
          {String.to_integer(a), String.to_integer(b)}
        end
      )
    end)
  end

  def x_range(walls) do
    walls
    |> Enum.reduce({:inf, -1},
      fn wall, {min, max} ->
        wall
        |> Enum.reduce( {min, max},
          fn {x, _}, {acc_min, acc_max} ->
            acc_min = if(x<acc_min, do: x, else: acc_min)
            acc_max = if(x>acc_max, do: x, else: acc_max)
            {acc_min, acc_max}
          end
        )
      end
    )
  end

  def build_profile(walls) do
    {x_min, x_max} = x_range(walls)

    y_max = max_height(walls)

    x_min..x_max
    |> Enum.reduce(%{},
      fn x, acc ->
        {last_y, segments} = 0..y_max |>
        Enum.reduce({nil, []},
          fn y, {min_y, segments} ->
            p = {x,y}
            case detect_collision(p, walls) do
              false ->
                case min_y do
                  nil ->  {nil, segments}
                  yy -> {nil, [yy..(y-1) | segments]}
                end
              _ ->
                case min_y do
                  nil -> {y, segments}
                  _yy  -> {min_y, segments}
                end
            end
          end
        )

        segments = case last_y do
          nil -> segments
          y -> [y..y_max | segments]
        end
        Map.put(acc, x, segments |> Enum.sort())
        # case new_acc do
        #   %{^x => _} -> new_acc
        #   _ -> Map.put(new_acc, x, default)
        # end
      end
    )
  end


  def max_height(walls) do
    walls
    |> Enum.reduce(-1,
      fn wall, max ->
        wall
        |> Enum.reduce( max,
          fn {_, y1}, acc ->
            if(y1>acc, do: y1, else: acc)
          end
        )
      end
    )
  end

  def is_touching?({x,y}, {{x, y1}, {x, y2}}), do: y1 <= y && y <= y2
  def is_touching?({x,y}, {{x1, y}, {x2, y}}), do: x1 <= x && x <= x2
  def is_touching?(_, _), do: false

  def is_collision_segment?(p, {{x1, y1}, {x2, y2}}) when x1 <= x2 and y1 <= y2, do: is_touching?(p, {{x1, y1}, {x2, y2}})
  def is_collision_segment?(p, {{x1, y1}, {x2, y2}}) when x1 <= x2 and y2 <= y1, do: is_touching?(p, {{x1, y2}, {x2, y1}})
  def is_collision_segment?(p, {{x1, y1}, {x2, y2}}) when x2 <= x1 and y1 <= y2, do: is_touching?(p, {{x2, y1}, {x1, y2}})
  def is_collision_segment?(p, {{x1, y1}, {x2, y2}}) when x2 <= x1 and y2 <= y1, do: is_touching?(p, {{x2, y2}, {x1, y1}})


  def detect_collision_profile({x,y}, profile) do
    case profile do
      %{^x => segments} ->
        segments
        |> Enum.reduce_while(false,
          fn seg, _ ->
            if(y in seg, do: {:halt, true}, else: {:cont, false})
          end
        )
      _ -> false
    end
  end

  def detect_collision(p, walls) do
    walls
    |> Enum.reduce_while(false,
      fn wall, _acc ->
        [start | rest] = wall

        intersection_segment = rest
        |> Enum.reduce_while(start,
          fn to, from ->
            case is_collision_segment?(p, {from, to}) do
              true ->  {:halt, {from, to}}
              false -> {:cont, to}
            end
          end
        )

        case intersection_segment do
          {from, to} when is_tuple(from) and is_tuple(to) -> {:halt, {from, to}}
          _ -> {:cont, false}
        end
      end
    )
  end



  def next_sand_step({x,y}, walls) do
    case detect_collision({x, y+1}, walls) do
      false -> {x, y+1}
      {_i,_j} ->
        case detect_collision({x-1, y+1}, walls) do
          false -> {x-1, y+1}
          {_il,_jl} ->
            case detect_collision({x+1, y+1}, walls) do
              false -> {x+1, y+1}
              _ -> {x,y}
            end
        end
    end
  end

  def next_sand_step2({x,y}, profile) do
    case detect_collision_profile({x, y+1}, profile) do
      false -> {x, y+1}
      _ ->
        case detect_collision_profile({x-1, y+1}, profile) do
          false -> {x-1, y+1}
          _ ->
            case detect_collision_profile({x+1, y+1}, profile) do
              false -> {x+1, y+1}
              _ -> {x,y}
            end
        end
    end
  end


  def sand_path(p, walls, max_p) do
    case next_sand_step(p, walls) do
      ^p -> p
      {x,y} ->
        if(y == max_p, do: {:infinite_loop, {x,y}}, else: sand_path({x,y}, walls, max_p))
    end
  end

  def sand_path2(p, profile, max_p) do
    case next_sand_step2(p, profile) do
      ^p -> p
      {x,y} ->
        if(y == max_p, do: {:infinite_loop, {x,y}}, else: sand_path2({x,y}, profile, max_p))
    end
  end

  def merge_ranges([r1, r2]) do
    if Range.disjoint?(r1, r2) do
      [r1, r2]
    else
      min = min(r1.first, r2.first)
      max = max(r1.last, r2.last)
      [min..max]
    end
  end

  def merge(r, []), do: [r]
  def merge(r, [s | rest] = _acc) do
    if r.last+1 == s.first do
      [r.first..s.last |rest]
    else
      [s | merge(r, rest)]
    end
  end

  def merge_all([]), do: []
  def merge_all([r | rest] = acc) do
    s = merge(r,rest) |> Enum.sort()
    if s == acc, do: [r | merge_all(rest)], else: s |> Enum.sort() |> merge_all()
  end

  def part_i(file \\ "lib/Q14/test_data") do

    walls = read_and_parse(file)
    start = {500,0}

    max_p = max_height(walls)

    1..5_000
    |> Enum.reduce_while({0, 0, start, walls},
      fn _, {n, m, p, w} ->
        case sand_path(start, w, max_p) do
          {:infinite_loop, {_x,_y}} -> {:halt, {n,m,p,w} }
          q ->
            #require IEx; IEx.pry()
            w = [[q,q] | w ]
            {:cont, {n+1, n, q, w}}
        end

      end
    )
  end

  def part_ib(file \\ "lib/Q14/test_data") do

    walls = read_and_parse(file)
    start = {500,0}

    max_p = max_height(walls)

    profile = build_profile(walls)

    1..5_000
    |> Enum.reduce_while({0, profile},
      fn _, {n, prof} ->
        case sand_path2(start, prof, max_p) do
          {:infinite_loop, {_x,_y}} -> {:halt, {n,prof} }
          {x,y} ->
            #require IEx; IEx.pry()
            #new_prof = Map.put(prof, x, y) |> IO.inspect()
            #IO.inspect({x,y})
            {_, new_prof} = get_and_update_in(prof, [x], &{&1, merge(y..y, &1) |> merge_all()} )# |> IO.inspect()
            {:cont, {n+1, new_prof}}
        end

      end
    )
  end


  def part_ii(file \\ "lib/Q13/test_data") do
    walls = read_and_parse(file)
    start = {500,0}

    max_p = max_height(walls)

    #walls = [[{-10_000, max_p+2}, {10_000, max_p+2}] | walls]
    max_p = max_p+2
    profile = build_profile(walls)
    IO.puts("Profile done")
    1..50_000
    |> Enum.reduce_while({0, profile},
      fn _, {n, prof} ->
        #IO.puts(n)
        case sand_path2(start, prof, max_p) do
          {:infinite_loop, {x,y}} ->
#            {_, new_prof} = get_and_update_in(prof, [x], &{&1, merge(y..y, &1) |> merge_all()} )# |> IO.inspect()

            {_, new_prof} = get_and_update_in(prof, [x], &{&1, if(is_nil(&1), do: [y-1..y-1], else: merge(y-1..y-1, &1) |> merge_all())}  )

            {:cont, {n+1,new_prof} }
          ^start -> {:halt, {n+1,prof}}
          {x,y} ->
            {_, new_prof} = get_and_update_in(prof, [x], &{&1, merge(y..y, &1) |> merge_all()} )
            {:cont, {n+1, new_prof}}
        end
      end
    )
  end

end
