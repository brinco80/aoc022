defmodule Q13 do

  def read_and_parse(filename) do
    # read file
    {:ok, data_str} = File.read(filename)

    # convert string to integers
    data_str
    |> String.split("\n\n")
    |> Enum.flat_map(fn block ->
      block
      |> String.split("\n")
      |> Enum.map(
        fn el ->
          Code.eval_string(el) |> elem(0)
        end
      )
    end)
  end

  def compare([], []), do: 0
  def compare([], _), do: -1
  def compare(_, []), do: 1
  def compare([l|lrest], [r|rrest]) when is_integer(l) and is_integer(r) and l==r, do: compare(lrest, rrest)
  def compare([l|_lrest], [r|_rrest]) when is_integer(l) and is_integer(r), do: if(l<r, do: -1, else: 1)
  def compare([l|lrest], right) when is_integer(l), do: compare([[l] | lrest], right)
  def compare(left, [r|rrest]) when is_integer(r), do: compare(left, [[r] | rrest])
  def compare([l|lrest], [r|rrest]) do
    case compare(l,r) do
      0 -> compare(lrest, rrest)
      x -> x
    end
  end


  def part_i(file \\ "lib/Q13/test_data") do

    read_and_parse(file)
    |> Enum.chunk_every(2)
    #|> Enum.with_index(fn {l,r}, index -> require IEx; IEx.pry(); if(compare(l,r), do: index+1, else: 0) end)
    |> Enum.with_index(fn [l,r], index -> if(compare(l,r) == -1, do: index+1, else: 0) end)
    |> Enum.sum()
  end

  # [[],[8,[],5],[]]
  # [[9]]

  def part_ii(file \\ "lib/Q13/test_data") do
    packets = read_and_parse(file)

    (packets ++ [[[2]], [[6]]])
    |> IO.inspect()
    |> Enum.sort( fn x,y -> compare(x,y) <= 0 end  )
    |> IO.inspect()
    |> Enum.with_index(fn el, index -> if(el in [[[2]], [[6]]], do: index+1, else: 1) end)
    |> Enum.product()

  end
end
