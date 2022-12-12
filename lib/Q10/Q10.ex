defmodule Q10 do

  def read_and_parse(filename) do
    # read file
    {:ok, data_str} = File.read(filename)

    data_str
    |> String.split("\n")
    |> Enum.map(
      fn
        line ->
          case String.split(line, " ") do
            [x] -> {x, nil}
            [cmd, n] -> {cmd, String.to_integer(n)}
          end
      end
    )
  end

  def process(commands) do
    commands
    |> Enum.scan({1, 1},
      fn
        {_, nil}, {t, x} -> {t+1, x}
        {_, n}, {t, x} -> {t+2, x + n}
      end
    )
    |> Map.new()
    |> Map.put(1,1)
  end

  def value_at_t(signals, t) do
    case signals do
      %{^t => v} -> v
      _ ->
        t1 = t-1
        case signals do
          %{^t1 => v} -> v
          _ -> nil
        end
    end
  end

  def sprite_intersection(x, t) do
    t in [x-1, x, x+1]
  end

  def part_i(file \\ "lib/Q10/test_data") do

    commands = read_and_parse(file)

    signals = process(commands)

    20..220//40
    |> Enum.map( fn t -> {t, value_at_t(signals, t)} end )
    |> IO.inspect()
    |> Enum.reduce(0, fn {t,s}, acc -> acc + t*s end)

  end

  def part_ii(file \\ "lib/Q10/test_data") do
    commands = read_and_parse(file)

    signals = process(commands)

    1..240
    |> Enum.map( fn t -> {t, value_at_t(signals, t)} end )
    |> IO.inspect()
    |> Enum.map(
      fn
        {t, x} when rem(t-1,40) in [x-1, x, x+1] -> "#"
        {t, _x} -> " "
      end
    )
    |> Enum.chunk_every(40)
    |> Enum.map(
      fn xs ->
        Enum.join(xs, "")
      end
    )
    |> Enum.join("\n")
    |> IO.puts()


  end

end
