defmodule Q01 do
  def read_and_parse(filename) do
    # read file
    {:ok, data_str} = File.read(filename)

    # convert string to lines
    data_str
    |> String.split("\n")
#    |> Enum.filter(fn x -> x != "" end)
  end

  def part_i(file \\ "lib/Q01/data") do
    lines = read_and_parse(file)

    lines
    |> Enum.reduce({%{}, 0},
      fn line, {data, elf} ->
        case line do
          "" ->
            {data, elf+1}
          s ->
            calories = String.to_integer(s)
            {_, data} = data
            |> Map.get_and_update(elf,
              fn
                nil -> {nil, calories}
                v -> {v, v+calories}
              end
            )

            {data, elf}
        end
      end
    )
    |> elem(0)
    |> Map.values()
    |> Enum.max()

  end

  def part_ii(file \\ "lib/Q01/data") do
    lines = read_and_parse(file)

    lines
    |> Enum.reduce({%{}, 0},
      fn line, {data, elf} ->
        case line do
          "" ->
            {data, elf+1}
          s ->
            calories = String.to_integer(s)
            {_, data} = data
            |> Map.get_and_update(elf,
              fn
                nil -> {nil, calories}
                v -> {v, v+calories}
              end
            )

            {data, elf}
        end
      end
    )
    |> elem(0)
    |> Map.values()
    |> Enum.sort(&(&1 >= &2))
    |> Enum.take(3)
    |> Enum.sum()


  end

end
