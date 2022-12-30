defmodule Q15 do

  def read_and_parse(filename) do
    # read file
    {:ok, data_str} = File.read(filename)

    rx = ~r/Sensor at x=(-?\d+), y=(-?\d+): closest beacon is at x=(-?\d+), y=(-?\d+)/

    # convert string to integers
    data_str
    |> String.split("\n")
    |> Enum.map(fn line ->
      #require IEx; IEx.pry()
      [xs, ys, xb, yb] = Regex.run(rx, line)
      |> tl()
      |> Enum.map(&String.to_integer/1)

      {{xs,ys}, %{beacon: {xb, yb}, distance: manhattan_distance({xs,ys}, {xb,yb})}}
    end)
    |> Map.new()
  end

  def visible_line(measurements, yt) do
    {visible_sensors, blocking_objects} = measurements
    |> Enum.reduce({[], []},
      fn {{xs, ys}, %{beacon: {xb, yb}, distance: d}}, {acc, acc_obj} ->
        y_range = abs(yt - ys)
        acc = if y_range > d do
          acc
        else
          x_range = (d - y_range)

          [{{xs, ys}, {(xs-x_range), (xs+x_range)}} | acc]
        end

        acc_obj = if(yb == yt, do: [{xb,xb}|acc_obj], else: acc_obj)
        acc_obj = if(ys == yt, do: [{xs,xs}|acc_obj], else: acc_obj)

        {acc, acc_obj}
      end
    )




    visible_points = visible_sensors
    |> Enum.map(fn {_k,v} -> v end)
    |> union()

    blocking_objects = blocking_objects |> union()

    {visible_points, blocking_objects}

  end

  def segment_overlap?({_x1, x2}, {y1, _y2}) when x2+1 == y1, do: true
  def segment_overlap?({x1, _x2}, {_y1, y2}) when y2+1 == x1, do: true
  def segment_overlap?({x1, _x2}, {_y1, y2}) when y2 < x1, do: false
  def segment_overlap?({_x1, x2}, {y1, _y2}) when x2 < y1, do: false
  def segment_overlap?(_, _), do: true

  def segment_intersection({x1, x2}, {y1, y2}) do
    if segment_overlap?({x1, x2}, {y1, y2}) do
      {max(x1, y1), min(x2, y2)}
    else
      {nil, nil}
    end
  end

  def segment_union({x1, x2}, {y1, y2}) do
    if segment_overlap?({x1, x2}, {y1, y2}) do
      [{min(x1,y1), max(x2,y2)}]
    else
      [{x1, x2}, {y1, y2}]
    end
  end

  def union([]), do: []
  def union([x]), do: [x]
  def union([{x1,x2} | rest]) do
    {result, final_state} = rest |>
    Enum.reduce({[], :no_union},
      fn {y1,y2}, {acc, state} ->
        if segment_overlap?({x1, x2}, {y1, y2}) do
          {[{min(x1,y1), max(x2,y2)} | acc], :union}
        else
          {[{y1,y2} |acc], state}
        end
      end
    )

    if final_state == :no_union do # no changes
      [{x1, x2} | union(rest)]
    else
      union(result)
    end
  end
#  def union([s | [t | rest]]) do

  #   if segment_overlap?(s,t) do
  #     r = segment_union(s,t)
  #     union(r ++ rest)
  #   else
  #   end
  # end



  def manhattan_distance({x1, y1}, {x2, y2}) do
    abs(x1 - x2) + abs(y1 - y2)
  end

  def segment_length({x,y}), do: y-x+1

  def part_i(file \\ "lib/Q15/test_data", n \\ 10) do

    measurements = read_and_parse(file)

    {visible_segments, objects} = visible_line(measurements, n)

    length_objects = objects
    |> Enum.filter(
      fn obj ->
        visible_segments
        |> Enum.map(&(segment_overlap?(&1,obj)))
        |> Enum.any?()
      end
    )
    |> Enum.map(&segment_length/1)
    |> Enum.sum()

    segments_length = visible_segments
    |> Enum.map(&segment_length/1)
    |> Enum.sum()

    segments_length - length_objects


  end



  def part_ii(file \\ "lib/Q15/test_data", limit \\ 20) do
    measurements = read_and_parse(file)

#    limit = 10#4_000_000

    x_range = {0, limit}

    0..limit
    |> Stream.map(
      fn n ->
        {scanned_segment, obj} = visible_line(measurements, n)

        scanned_segment = scanned_segment |> Enum.map(&(segment_intersection(&1, x_range)))
        {n, {scanned_segment, obj}}
      end
    )
    |> Stream.filter(
      fn {_, {scanned_segment, _obj}} -> length(scanned_segment)>1 end
    )
    |> Enum.to_list()

  end

end
