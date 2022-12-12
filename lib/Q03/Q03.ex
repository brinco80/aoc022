defmodule Q03 do
  def read_and_parse(filename) do
    # read file
    {:ok, data_str} = File.read(filename)

    # convert string to lines
    data_str
    |> String.split("\n")
  end

  def get_priorities() do
    priorities1 =
      ?a..?z |> Enum.with_index(fn x, i -> {<<x :: utf8>>, i+1} end)

    priorities2 = ?A..?Z |> Enum.with_index(fn x, i -> {<<x :: utf8>>, i+27} end)

    (priorities1 ++ priorities2) |> Map.new()
  end

  def part_i(file \\ "lib/Q02/test_data") do
    priorities = get_priorities()

    read_and_parse(file)
    |> Enum.map(fn line -> # Preprocess line to generate compartments data as MapSet
      n = String.length(line)

      line
      |> String.split_at(div(n,2))
      |> Tuple.to_list()
      |> Enum.map(
        fn x ->
          x
          |> String.codepoints()
          |> MapSet.new()
      end)

    end)
    |> Enum.map(
      fn [comp_left, comp_right] ->
        MapSet.intersection(comp_left, comp_right)
        |> MapSet.to_list()
        |> Enum.map(
          fn x ->
            priorities[x]
          end
        )
        |> Enum.sum()
      end
    )
    |> Enum.sum()
  end

  def part_ii(file \\ "lib/Q03/test_data") do
    priorities = get_priorities()

    read_and_parse(file)
    |> Enum.chunk_every(3)
    |> Enum.map(fn chunk ->
      chunk
      |> Enum.map(
        fn backpack ->
          backpack |> String.codepoints() |> MapSet.new()
        end
      )
    end)
    |> Enum.map(
       fn [b1, b2, b3] ->
         MapSet.intersection(b1, b2)
         |> MapSet.intersection(b3)
         |> MapSet.to_list()
         |> Enum.map(
           fn x ->
             priorities[x]
           end
         )
         |> Enum.sum()
       end
    )
    |> Enum.sum()

  end

end
