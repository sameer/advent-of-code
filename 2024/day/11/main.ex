stones = File.read!("input") |> String.trim() |> String.split(" ")

find_num_stones = fn stones, blinks_remaining, self ->
  if blinks_remaining === 0 do
    stones |> length()
  else
    stones
    |> Enum.map(fn stone ->
      stone_length = String.length(stone)

      cond do
        stone === "0" ->
          self.(["1"], blinks_remaining - 1, self)

        stone_length |> rem(2) === 0 ->
          {left, right} = stone |> String.split_at(div(stone_length, 2))
          right = right |> String.trim_leading("0")

          right =
            if right === "" do
              "0"
            else
              right
            end

          self.([left, right], blinks_remaining - 1, self)

        true ->
          self.(
            [((stone |> String.to_integer()) * 2024) |> Integer.to_string()],
            blinks_remaining - 1,
            self
          )
      end
    end)
    |> Enum.sum()
  end
end

find_num_stones.(stones, 25, find_num_stones) |> IO.puts()

# Part 2

# Memoize using an Agent, weird stuff
defmodule Stones do
  use Agent

  def start do
    Agent.start_link(fn -> %{0 => 0, 1 => 1} end, name: __MODULE__)
  end

  def find(stones, 0), do: length(stones)

  def find(stones, blinks_remaining) do
    cached_value = Agent.get(__MODULE__, &Map.get(&1, {stones, blinks_remaining}))

    if cached_value do
      cached_value
    else
      num =
        stones
        |> Enum.map(fn stone ->
          stone_length = String.length(stone)

          cond do
            stone === "0" ->
              find(["1"], blinks_remaining - 1)

            stone_length |> rem(2) === 0 ->
              {left, right} = stone |> String.split_at(div(stone_length, 2))
              right = right |> String.trim_leading("0")

              right =
                if right === "" do
                  "0"
                else
                  right
                end

              find([left, right], blinks_remaining - 1)

            true ->
              find(
                [((stone |> String.to_integer()) * 2024) |> Integer.to_string()],
                blinks_remaining - 1
              )
          end
        end)
        |> Enum.sum()

      Agent.update(__MODULE__, &Map.put(&1, {stones, blinks_remaining}, num))
      num
    end
  end
end

Stones.start()
Stones.find(stones, 75) |> IO.puts()
