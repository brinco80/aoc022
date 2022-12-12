defmodule Q04 do
  def read_and_parse(filename) do
    # read file
    {:ok, data_str} = File.read(filename)

    # convert string to lines
    data_str
    |> String.split("\n")
    |> Enum.map(
      fn line ->
        [a,b,c,d] = Regex.run(~r"(\d+)-(\d+),(\d+)-(\d+)", line)
        |> tl()
        |> Enum.map(&String.to_integer/1)
        {[a,b], [c,d]}
      end
    )
  end

  def segment_intersection([x1, _x2], [_y1, y2]) when y2 < x1, do: [nil, nil]
  def segment_intersection([_x1, x2], [y1, _y2]) when x2 < y1, do: [nil, nil]

  def segment_intersection([x1, x2], [y1, y2]) do
    [max(x1, y1), min(x2, y2)]
  end

  def is_empty([p, q]) do
    !(Enum.all?(p) or Enum.all?(q))
  end


  def part_i(file \\ "lib/Q04/test_data") do

    read_and_parse(file)
    |> Enum.map(
      fn {l, r} ->
        i = segment_intersection(l,r)
        if(i == l or i == r, do: 1, else: 0)
      end
    )
    |> Enum.sum()

  end

  def part_ii(file \\ "lib/Q04/test_data") do

    read_and_parse(file)
    |> Enum.map(
      fn {l, r} ->
        i = segment_intersection(l,r)
        if(Enum.all?(i), do: 1, else: 0)
      end
    )
    |> Enum.sum()

  end

end
