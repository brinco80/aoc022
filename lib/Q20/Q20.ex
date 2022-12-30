defmodule Q20 do

  def read_and_parse(filename) do
    # read file
    {:ok, data_str} = File.read(filename)

    # convert string to integers
    data  = data_str
    |> String.split("\n")
    |> Enum.map(&String.to_integer/1)

    id_map = data
    |> Enum.with_index(fn e, i -> {i,e} end)
    |> Map.new()


    {Enum.map(0..length(data)-1, &(&1)), id_map}
  end

  def compute_list(position_map, id_map) do
    position_map
    |> Enum.map(
      fn id ->
        id_map[id]
      end
    )
  end

  def compute_list_ids(position_map) do
    position_map
    |> Enum.sort()
    |> Enum.map(
      fn {_index, id} ->
        id
      end
    )
  end

  def new_position(current_position, displacement, n) when current_position+displacement<0, do: n-1 + rem(current_position+displacement,n-1)
  def new_position(current_position, displacement, n), do: rem(current_position+displacement,n-1)

  def move(pos, new_pos, pos_list) do
    {val, new_list} = List.pop_at(pos_list, pos)

    popped_list = new_list
    |> List.insert_at(new_pos, val)

    popped_list

  end

  def mix(positions, ids) do
    n = length(positions)

    0..n-1
    |> Enum.reduce(positions,
      fn i, acc ->
        displacement = ids[i]

        current_position = acc
        |> Enum.find_index(&(&1 == i))

        new_pos = new_position(current_position, displacement, n)

        move(current_position, new_pos, acc)
      end
    )
  end

  def get_coordinates(positions) do
    first_zero = Enum.find_index(positions, &(&1==0)) |> IO.inspect(label: "zero position")
    n = length(positions)

    indices = Enum.map(1..3,  &(rem(1000*&1 + first_zero,n) ))

    coordinates = indices
      |> Enum.map(&(Enum.at(positions, &1)))
    {indices, coordinates}
  end


  def part_i(file \\ "lib/Q20/test_data") do
    #{position_map, ids_map} = read_and_parse(file)

    {position_list, ids_map} = read_and_parse(file)
    #IO.inspect(ids_map, label: "ids_map")


    permutation = mix(position_list, ids_map)
    |> compute_list(ids_map)
    |> IO.inspect(label: "list")

    {indices, coordinates} = get_coordinates(permutation)

    IO.inspect(indices, label: "indices")
    IO.inspect(coordinates, label: "Grove coordinates")
    IO.puts("Sum Grove Coordinates: #{ Enum.sum(coordinates)}")
    permutation
  end



  def part_ii(file \\ "lib/Q20/test_data") do
    {position_list, ids_map} = read_and_parse(file)
    ids_map = ids_map
    |> Enum.map(fn {k,v} -> {k, v*811589153}  end)
    |> Map.new()

    permutation = 0..9 |>
    Enum.reduce(position_list,
      fn _i, acc ->
        xs = mix(acc, ids_map)
        xs |> compute_list(ids_map)
        xs
      end
    )
    |> compute_list(ids_map)
    |> IO.inspect(label: "list")

    {indices, coordinates} = get_coordinates(permutation)

    IO.inspect(indices, label: "indices")
    IO.inspect(coordinates, label: "Grove coordinates")
    IO.puts("Sum Grove Coordinates: #{ Enum.sum(coordinates)}")
    permutation
  end

end
