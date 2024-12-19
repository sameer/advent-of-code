[towels, patterns] = File.read!("input") |> String.trim() |> String.split("\n\n")
towels = towels |> String.split(", ")
patterns = patterns |> String.split("\n")

is_possible = fn pattern, self ->
  if String.length(pattern) === 0 do
    true
  else
    starts = towels |> Enum.filter(&String.starts_with?(pattern, &1))

    starts
    |> Enum.any?(fn prefix ->
      new_pattern = pattern |> String.split_at(String.length(prefix)) |> elem(1)
      self.(new_pattern, self)
    end)
  end
end

patterns |> Enum.count(&is_possible.(&1, is_possible)) |> IO.puts()

# Part 2

defmodule Towels do
  use Agent

  def start do
    Agent.start_link(fn -> %{0 => 0, 1 => 1} end, name: __MODULE__)
  end

  def num_possible("", towels), do: 1

  def num_possible(pattern, towels) do
    cached_num_possible = Agent.get(__MODULE__, &Map.get(&1, pattern))

    if cached_num_possible !== nil do
      cached_num_possible
    else
      starts = towels |> Enum.filter(&String.starts_with?(pattern, &1))

      actual_num_possible =
        starts
        |> Enum.reduce(0, fn prefix, acc ->
          new_pattern = pattern |> String.split_at(String.length(prefix)) |> elem(1)
          acc + num_possible(new_pattern, towels)
        end)

      Agent.update(__MODULE__, &Map.put(&1, pattern, actual_num_possible))

      actual_num_possible
    end
  end
end

Towels.start()
patterns |> Enum.map(&Towels.num_possible(&1, towels)) |> Enum.sum() |> IO.puts()
