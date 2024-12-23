edges =
  File.read!("input") |> String.trim() |> String.split("\n") |> Enum.map(&String.split(&1, "-"))

computers = edges |> Enum.flat_map(& &1) |> MapSet.new()

computer_to_connected =
  edges
  |> Enum.reduce(Map.new(), fn [lhs, rhs], acc ->
    Map.get_and_update(acc, lhs, fn cur ->
      if cur === nil do
        {cur, MapSet.new([rhs])}
      else
        {cur, MapSet.put(cur, rhs)}
      end
    end)
    |> elem(1)
    |> Map.get_and_update(rhs, fn cur ->
      if cur === nil do
        {cur, MapSet.new([lhs])}
      else
        {cur, MapSet.put(cur, lhs)}
      end
    end)
    |> elem(1)
  end)

# options = computers |> Enum.filter(&String.starts_with?(&1, "t"))

# options_list = options |> MapSet.to_list()
computers_list = computers |> MapSet.to_list()

defmodule RC do
  def comb(0, _), do: [[]]
  def comb(_, []), do: []

  def comb(m, [h | t]) do
    for(l <- comb(m - 1, t), do: [h | l]) ++ comb(m, t)
  end
end

combos =
  RC.comb(3, computers |> MapSet.to_list())
  |> Enum.filter(fn list ->
    list |> Enum.any?(&String.starts_with?(&1, "t"))
  end)

combos
|> Enum.filter(fn list ->
  [first, second, third] = list
  necessary = [[second, third], [first, third], [first, second]]

  Enum.zip(list, necessary)
  |> Enum.all?(fn {vertex, required} ->
    edges = Map.get(computer_to_connected, vertex)
    required |> Enum.all?(fn r -> MapSet.member?(edges, r) end)
  end)
end)
|> Enum.count()
|> IO.inspect()

# Part 2
