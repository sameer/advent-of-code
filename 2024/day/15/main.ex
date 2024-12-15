[grid, moves] = File.read!("input") |> String.split("\n\n")

grid = grid |> String.trim() |> String.split("\n") |> Enum.map(&String.codepoints/1)
wall = "#"
robot = "@"
box = "O"

walls =
  grid
  |> Enum.with_index()
  |> Enum.flat_map(fn {row, i} ->
    row |> Enum.with_index() |> Enum.filter(fn {c, _} -> c === wall end) |> Enum.map(fn {_, j} -> {i, j} end)
  end)
  |> Enum.map(&Tuple.to_list/1)
  |> MapSet.new()

boxes =
  grid
  |> Enum.with_index()
  |> Enum.flat_map(fn {row, i} ->
    row |> Enum.with_index() |> Enum.filter(fn {c, _} -> c === box end) |> Enum.map(fn {_, j} -> {i, j} end)
  end)
  |> Enum.map(&Tuple.to_list/1)
  |> MapSet.new()

[robot_position] =
  grid
  |> Enum.with_index()
  |> Enum.flat_map(fn {row, i} ->
    row
    |> Enum.with_index()
    |> Enum.filter(fn {c, _} -> c === robot end)
    |> Enum.map(fn {c, j} -> {i, j} end)
  end)
  |> Enum.map(&Tuple.to_list/1)

moves =
  moves
  |> String.trim()
  |> String.split("\n")
  |> Enum.map(&String.codepoints/1)
  |> Enum.concat()

find_empty_spot = fn pos, dir, boxes, self ->
  if MapSet.member?(walls, pos) do
    nil
  else
    if MapSet.member?(boxes, pos) do
      new_pos = Enum.zip(pos, dir) |> Enum.map(&Tuple.to_list/1) |> Enum.map(&Enum.sum/1)
      self.(new_pos, dir, boxes, self)
    else
      pos
    end
  end
end

{final_robot_position, final_boxes} =
  moves
  |> Enum.reduce({robot_position, boxes}, fn move, {pos, boxes} ->
    dir =
      case move do
        "^" -> [-1, 0]
        "v" -> [1, 0]
        "<" -> [0, -1]
        ">" -> [0, 1]
      end

    new_pos = Enum.zip(pos, dir) |> Enum.map(&Tuple.to_list/1) |> Enum.map(&Enum.sum/1)
    empty_spot = find_empty_spot.(new_pos, dir, boxes, find_empty_spot)

    cond do
      empty_spot === nil -> {pos, boxes}
      empty_spot === new_pos -> {new_pos, boxes}
      true -> {new_pos, boxes |> MapSet.delete(new_pos) |> MapSet.put(empty_spot)}
    end
  end)

gps_coordinates_sum = final_boxes |> Enum.map(fn [i, j] -> 100 * i + j end) |> Enum.sum()
IO.puts(gps_coordinates_sum)
