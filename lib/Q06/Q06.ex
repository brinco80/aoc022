defmodule Q06 do
  def read_and_parse(filename) do
    # read file
    {:ok, data_str} = File.read(filename)
    data_str
  end


  def logic(a,b,c,d) do
    cond do
      a != b && a != c && a != d && b != c && b != d && c != d ->
        :found
      b != c && b != d && c != d -> :diff3
      c != d -> :diff2
      true -> :diff1

    end
  end

  def parse_packet(<<a, b, c, d, rest::bitstring>>, {nil,nil,nil,n}) do
    case logic(a,b,c,d) do
      :found -> { List.to_string([a,b,c,d]), n+4}
      :diff3 -> parse_packet(rest, {b,c,d,n+4})
      :diff2 -> parse_packet(rest, {c,d,nil,n+4})
      :diff1 -> parse_packet(rest, {d,nil,nil,n+4})
    end
  end

  def parse_packet(<<b, c, d, rest::bitstring>>, {a,nil,nil,n}) do
    case logic(a,b,c,d) do
      :found -> { List.to_string([a,b,c,d]), n+3}
      :diff3 -> parse_packet(rest, {b,c,d,n+3})
      :diff2 -> parse_packet(rest, {c,d,nil,n+3})
      :diff1 -> parse_packet(rest, {d,nil,nil,n+3})
    end
  end

  def parse_packet(<<c, d, rest::bitstring>>, {a,b,nil,n}) do
    case logic(a,b,c,d) do
      :found -> { List.to_string([a,b,c,d]), n+2}
      :diff3 -> parse_packet(rest, {b,c,d,n+2})
      :diff2 -> parse_packet(rest, {c,d,nil,n+2})
      :diff1 -> parse_packet(rest, {d,nil,nil,n+2})
    end
  end

  def parse_packet(<<d, rest::bitstring>>, {a,b,c,n}) do
    case logic(a,b,c,d) do
      :found -> { List.to_string([a,b,c,d]), n+1}
      :diff3 -> parse_packet(rest, {b,c,d,n+1})
      :diff2 -> parse_packet(rest, {c,d,nil,n+1})
      :diff1 -> parse_packet(rest, {d,nil,nil,n+1})
    end
  end

  def different_string([]), do: true
  def different_string([a | rest]) do
    rest
    |> Enum.reduce_while(true, fn el, _acc -> if el==a, do: {:halt, false}, else: {:cont, true}  end )
    && different_string(rest)
  end


  def parse_packet_one([], _som, _n, _limit), do: {"", -1}
  def parse_packet_one([a | rest], som, n, limit) when length(som)<limit  do
    parse_packet_one(rest, som ++ [a], n+1, limit)
  end

  def parse_packet_one([a | rest], [_ | som_rest]= som, n, limit) do
    if different_string(som) do
      {List.to_string(som), n}
    else
      parse_packet_one(rest, som_rest ++ [a], n+1, limit)
    end
  end


  def part_i(file \\ "lib/Q06/test_data") do

    str = read_and_parse(file)

    parse_packet(str, {nil, nil, nil, 0})
  end

  def part_ii(file \\ "lib/Q06/test_data", n \\ 14) do

    str = read_and_parse(file)

    str
    |> String.codepoints()
    |> parse_packet_one([], 0, n)
  end

end
