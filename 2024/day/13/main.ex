machines = File.read!("input") |> String.split("\n\n") |> Enum.map(&String.trim/1)

parsed_machines =
  machines
  |> Enum.map(&String.split(&1, "\n"))
  |> Enum.map(fn [a, b, prize] ->
    [a_xy, b_xy] =
      [a, b]
      |> Enum.map(fn button ->
        [_, x_and_y] = button |> String.split(":")

        x_and_y
        |> String.split(",")
        |> Enum.map(&String.split(&1, "+"))
        |> Enum.map(&List.last/1)
        |> Enum.map(&String.to_integer/1)
      end)

    prize_xy =
      prize
      |> String.split(":")
      |> List.last()
      |> String.split(",")
      |> Enum.map(&String.split(&1, "="))
      |> Enum.map(&List.last/1)
      |> Enum.map(&String.to_integer/1)

    {prize_xy, a_xy, b_xy}
  end)

calc_fewest_tokens = fn {[px, py], [ax, ay], [bx, by]} ->
  det = ax * by - ay * bx

  det_a = px * by - py * bx
  det_b = py * ax - px * ay

  a = det_a / det
  rem_a = rem(det_a, det)
  b = det_b / det
  rem_b = rem(det_b, det)

  if a < 0 or b < 0 or rem_a !== 0 or rem_b !== 0 do
    0
  else
    3 * a + b
  end
end

tokens_spent = parsed_machines |> Enum.map(&calc_fewest_tokens.(&1)) |> Enum.sum()
IO.puts(tokens_spent)

# Part 2

part_two_parsed_machines =
  parsed_machines
  |> Enum.map(fn {p, a, b} -> {p |> Enum.map(&(&1 + 10_000_000_000_000)), a, b} end)

part_two_tokens_spent = part_two_parsed_machines |> Enum.map(&calc_fewest_tokens.(&1)) |> Enum.sum()
IO.puts(part_two_tokens_spent)
