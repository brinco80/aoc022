defmodule Q08 do

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
        |> String.split("", trim: true)
        |> Enum.with_index(fn element, index -> {index, String.to_integer(element)} end)
        |> Enum.map(fn {y, z} ->
          {{x, y}, z}
        end)
      end)
      |> Map.new()

    {x_max, y_max} =
      points
      |> Map.keys()
      |> Enum.reduce({-1, -1}, fn {x, y}, {x_max, y_max} -> {max(x_max, x), max(y_max, y)} end)

    %{x_max: x_max, y_max: y_max, points: points}
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
  end


  def is_left_visible?({i,j}, %{x_max: _x_max, y_max: _y_max, points: points}) do
    p0 = points[{i,j}]

    # check left trees
    0..i-1
    |> Enum.reduce_while(true,
      fn x, acc ->
        p = points[{x,j}]
        if p<p0, do: {:cont, acc}, else: {:halt, false}
      end
    )
  end

  def is_right_visible?({i,j}, %{x_max: x_max, y_max: _y_max, points: points}) do
    p0 = points[{i,j}]

    # check right trees
    i+1..x_max
    |> Enum.reduce_while(true,
      fn x, acc ->
        p = points[{x,j}]
        if p<p0, do: {:cont, acc}, else: {:halt, false}
      end
    )
  end

  def is_top_visible?({i,j}, %{x_max: _x_max, y_max: _y_max, points: points}) do
    p0 = points[{i,j}]

    # check top trees
    0..j-1
    |> Enum.reduce_while(true,
      fn y, acc ->
        p = points[{i,y}]
        if p<p0, do: {:cont, acc}, else: {:halt, false}
      end
    )
  end

  def is_bottom_visible?({i,j}, %{x_max: _x_max, y_max: y_max, points: points}) do
    p0 = points[{i,j}]

    # check bottom trees
    j+1..y_max
    |> Enum.reduce_while(true,
      fn y, acc ->
        p = points[{i,y}]
        if p<p0, do: {:cont, acc}, else: {:halt, false}
      end
    )
  end

  def is_visible?(xy, forest) do
    is_left_visible?(xy, forest) ||
    is_right_visible?(xy, forest) ||
    is_top_visible?(xy, forest) ||
    is_bottom_visible?(xy, forest)
  end



  def left_visibility({i,j}, %{x_max: _x_max, y_max: _y_max, points: points}) do
    p0 = points[{i,j}]

    # check left trees
    i-1..0
    |> Enum.reduce_while(0,
      fn x, acc ->
        p = points[{x,j}]
        if p<p0, do: {:cont, acc+1}, else: {:halt, acc+1}
      end
    )
  end

  def right_visibility({i,j}, %{x_max: x_max, y_max: _y_max, points: points}) do
    p0 = points[{i,j}]

    # check right trees
    i+1..x_max
    |> Enum.reduce_while(0,
      fn x, acc ->
        p = points[{x,j}]
        if p<p0, do: {:cont, acc+1}, else: {:halt, acc+1}
      end
    )
  end

  def top_visibility({i,j}, %{x_max: _x_max, y_max: _y_max, points: points}) do
    p0 = points[{i,j}]

    # check top trees
    j-1..0
    |> Enum.reduce_while(0,
      fn y, acc ->
        p = points[{i,y}]
        if p<p0, do: {:cont, acc+1}, else: {:halt, acc+1}
      end
    )
  end

  def bottom_visibility({i,j}, %{x_max: _x_max, y_max: y_max, points: points}) do
    p0 = points[{i,j}]

    # check bottom trees
    j+1..y_max
    |> Enum.reduce_while(0,
      fn y, acc ->
        p = points[{i,y}]
        if p<p0, do: {:cont, acc+1}, else: {:halt, acc+1}
      end
    )
  end

  def visibility(xy, forest) do
    top_visibility(xy,forest) * left_visibility(xy,forest) * bottom_visibility(xy,forest) * right_visibility(xy,forest)
  end

  def part_i(file \\ "lib/Q08/test_data") do

    forest = read_and_parse(file)
    %{x_max: x_max, y_max: y_max} = forest

    interior_visible_trees = 1..x_max-1
    |> Enum.reduce([],
      fn i, acc ->
        1..y_max-1
        |> Enum.reduce(acc,
          fn j, acc2 ->
            if is_visible?({i,j}, forest), do: [{i,j} | acc2], else: acc2
          end
        )
      end
    )
    |> IO.inspect()

    IO.puts("There are #{2*(x_max + y_max) } visible trees on the edge")
    IO.puts("There are #{length(interior_visible_trees)} visible trees in the interior")
    IO.puts("There are #{2*(x_max + y_max) + length(interior_visible_trees)} visible trees in total")
  end

  def part_ii(file \\ "lib/Q08/test_data") do
    forest = read_and_parse(file)

    %{x_max: x_max, y_max: y_max} = forest


    for x <- 1..x_max-1, y <- 1..y_max-1, into: [] do
      {{x,y}, visibility({x,y}, forest)}
    end
    |> Map.new()
    |> Map.values()
    |> Enum.max()




  end

end
