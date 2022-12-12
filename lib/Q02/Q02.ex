defmodule Q02 do
  def read_and_parse(filename) do
    # read file
    {:ok, data_str} = File.read(filename)

    # convert string to lines
    data_str
    |> String.split("\n")
    |> Enum.map(&(String.split(&1, " ") |> List.to_tuple))
  end

  def match_result({"A", "X"}), do: 3
  def match_result({"A", "Y"}), do: 6
  def match_result({"A", "Z"}), do: 0
  def match_result({"B", "X"}), do: 0
  def match_result({"B", "Y"}), do: 3
  def match_result({"B", "Z"}), do: 6
  def match_result({"C", "X"}), do: 6
  def match_result({"C", "Y"}), do: 0
  def match_result({"C", "Z"}), do: 3

  def infer_move({"A", "X"}), do: "Z"
  def infer_move({"A", "Y"}), do: "X"
  def infer_move({"A", "Z"}), do: "Y"
  def infer_move({"B", "X"}), do: "X"
  def infer_move({"B", "Y"}), do: "Y"
  def infer_move({"B", "Z"}), do: "Z"
  def infer_move({"C", "X"}), do: "Y"
  def infer_move({"C", "Y"}), do: "Z"
  def infer_move({"C", "Z"}), do: "X"

  def compute_scores(moves, shape_scores) do
    moves
   # |> IO.inspect()
    |> Enum.reduce(0,
      fn {p1, p2}, acc ->
        acc + match_result({p1, p2}) + shape_scores[p2]
      end
    )
  end

  def part_i(file \\ "lib/Q02/test_data") do
    moves = read_and_parse(file)

    # results: X lose, Y draw, Z win
    shape_score = %{"A" => 1, "B" => 2, "C" => 3, "X" => 1, "Y" => 2, "Z" => 3}

    compute_scores(moves, shape_score)


  end

  def part_ii(file \\ "lib/Q02/data") do
    moves = read_and_parse(file)

    # results: X lose, Y draw, Z win
    shape_score = %{"A" => 1, "B" => 2, "C" => 3, "X" => 1, "Y" => 2, "Z" => 3}

    moves
    |> Enum.map(fn {p1, p2} ->  {p1, infer_move({p1, p2}) } end) # translate moves to old format
    |> compute_scores(shape_score) # compute scores as always
  end

end
