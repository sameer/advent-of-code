robots =
  File.read!("input")
  |> String.trim()
  |> String.split("\n")
  |> Enum.map(fn line ->
    line
    |> String.split(" ")
    |> Enum.map(&String.split(&1, "="))
    |> Enum.map(&List.last/1)
    |> Enum.map(&String.split(&1, ","))
    |> Enum.map(fn vals -> vals |> Enum.map(&String.to_integer/1) end)
  end)

width = 101
height = 103

time = 100

calc_positions_at_time = fn time ->
  robots
  |> Enum.map(fn [pos, velocity] ->
    Enum.zip(pos, velocity)
    |> Enum.map(fn {p_n, v_n} -> p_n + time * v_n end)
    |> Enum.zip([width, height])
    |> Enum.map(fn {final_p_n, n} ->
      (rem(final_p_n, n) + n) |> rem(n)
    end)
  end)
end

final_robot_positions = calc_positions_at_time.(time)

quadrants = [
  {[0, div(width, 2) - 1], [0, div(height, 2) - 1]},
  {[div(width, 2) + 1, width - 1], [div(height, 2) + 1, height - 1]},
  {[div(width, 2) + 1, width - 1], [0, div(height, 2) - 1]},
  {[0, div(width, 2) - 1], [div(height, 2) + 1, height - 1]}
]

safety_factor =
  quadrants
  |> Enum.map(fn {[qmin_x, qmax_x], [qmin_y, qmax_y]} ->
    final_robot_positions
    |> Enum.filter(fn [final_x, final_y] ->
      final_x in qmin_x..qmax_x and final_y in qmin_y..qmax_y
    end)
    |> Enum.count()
  end)
  |> Enum.product()

IO.puts(safety_factor)

# Part 2: visually inspect at times, I guess?
Enum.each(0..100_000, fn time ->
  robot_positions = calc_positions_at_time.(time) |> MapSet.new()

  grid =
    Enum.map(0..(height - 1), fn h ->
      Enum.map(0..(width - 1), fn w ->
        if robot_positions |> MapSet.member?([w, h]), do: "#", else: " "
      end)
      |> Enum.join()
    end)

  # Assuming there has to be some to at least form a picture
  candidate = grid |> Enum.any?(&String.contains?(&1, "######"))

  if candidate do
    IO.puts("Time: #{time}")
    IO.puts(grid |> Enum.join("\n"))
    IO.puts("\n\n")
  end
end)
