defmodule Q07 do

  def read_and_parse(filename) do
    # read file
    {:ok, data_str} = File.read(filename)
    data_str
    |> String.split("\n")
    |> Enum.reduce({%{ "/" => %{files: %{}}}, []},
      &__MODULE__.parser/2
    )
  end


  def parser("$ cd ..", {tree, [_ | pointer_rest]}), do: {tree, pointer_rest}
  def parser("$ cd " <> dir, {tree, pointer}), do: {tree, [dir | pointer]}
  def parser("$ ls", state), do: state

  def parser("dir " <> dir, {tree, pointer}) do
    path = Enum.reverse(pointer)
    {_, tree} = get_and_update_in(tree, path,
      fn node ->
        {node, Map.put(node, dir, %{files: %{}})}
      end
    )
    {tree, pointer}
  end


  def parser(file_line, {tree, pointer}) do
    [size, filename] = Regex.run(~r"(\d+) (.+)", file_line) |> tl()
    path = Enum.reverse([:files | pointer])
    {_, tree} = get_and_update_in(tree, path,
      fn node ->
        #require IEx; IEx.pry()
        {node, Map.put_new(node, filename, String.to_integer(size))}
      end
    )
    {tree, pointer}
  end


  def dir_size(tree, {summary, pointer}) do
    {files, new_tree} = Map.pop(tree, :files)

    file_size =
      files
      |> Map.values()
      |> Enum.sum()

    # Add new value with dir size
    path = Enum.reverse(pointer)
    {_, summary} = get_and_update_in(summary, path,
      fn node ->
        #require IEx; IEx.pry()
        {node, %{size: 0}}
      end
    )

    {summary, _, dsize} = new_tree
    |> Enum.reduce({summary, pointer, 0},
      fn {k,v}, {acc, ptr, dsize} ->

        {acc2, _pointer} = dir_size(v, {acc, [k | ptr], })
        {acc2, ptr, dsize + get_in(acc2, Enum.reverse([:size | [k | ptr]]))}

      end
    )


    {_, summary} = get_and_update_in(summary, path,
      fn node ->
        #require IEx; IEx.pry()
        {node, Map.put(node, :size, file_size + dsize)}
      end
    )

  #  require IEx; IEx.pry()
    {summary, pointer}
  end

  def tree2map(tree, key, map) do
    Enum.reduce(tree, map,
      fn
        {:size, v}, acc ->  Map.put(acc, key, v)
        {k,v}, acc -> tree2map(v, key <> "/" <> k, acc)
      end
     )
  end


  def part_i(file \\ "lib/Q07/test_data") do

    {tree, _} = read_and_parse(file)
    IO.inspect(tree)
    {sizes, _} = dir_size(tree["/"], {%{}, ["/"]})
    IO.inspect(sizes)
    tree2map(sizes["/"], "", %{})
    |> IO.inspect()
    |> Enum.filter(fn {_k,v} -> v <= 100000 end)
    |> Map.new()
    |> IO.inspect()
    |> Map.values()
    |> IO.inspect()
    |> Enum.sum()
  end

  def part_ii(file \\ "lib/Q07/test_data") do

    {tree, _} = read_and_parse(file)

    {sizes, _} = dir_size(tree["/"], {%{}, ["/"]})

    sizes_map = tree2map(sizes["/"], "", %{})

    min_space = 30_000_000 - (70_000_000 - sizes_map[""])

    sizes_map
    |> Enum.sort(fn {_k1,v1}, {_k2,v2} -> v1>v2 end)
    |> Enum.reduce_while(nil,
      fn {k,v}, acc ->
         if v > min_space, do: {:cont, {k,v} }, else: {:halt, acc}
      end
    )
  end

end
