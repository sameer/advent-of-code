input = File.read!("input")

muls = Regex.scan(~r"mul\((?<lhs>\d{1,3}),(?<rhs>\d{1,3})\)", input)

parsed_muls =
  Enum.map(muls, fn [_, lhs, rhs] -> {String.to_integer(lhs), String.to_integer(rhs)} end)

multiplied = Enum.map(parsed_muls, fn {lhs, rhs} -> lhs * rhs end)
sum = Enum.sum(multiplied)
IO.puts(sum)

# Part 2
instructions = Regex.scan(~r"(?:mul\((?<lhs>\d{1,3}),(?<rhs>\d{1,3})\)|do\(\)|don't\(\))", input)
{active_muls, _} =
  Enum.reduce(instructions, {[], true}, fn match, {acc, enabled} ->
    [op | _] = match
    enabled = op === "do()" or (enabled and op !== "don't()")

    if enabled and String.starts_with?(op, "mul") do
      {[match | acc], enabled}
    else
      {acc, enabled}
    end

  end)

active_parsed_muls =
  Enum.map(active_muls, fn [_, lhs, rhs] -> {String.to_integer(lhs), String.to_integer(rhs)} end)

active_multiplied = Enum.map(active_parsed_muls, fn {lhs, rhs} -> lhs * rhs end)
active_sum = Enum.sum(active_multiplied)
IO.puts(active_sum)
