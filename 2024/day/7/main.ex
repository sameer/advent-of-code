lines =
  File.read!("input")
  |> String.split("\n")
  |> Enum.filter(&(String.length(&1) > 0))
  |> Enum.map(&String.split(&1, ":"))
  |> Enum.map(fn [test_value, numbers] ->
    {String.to_integer(test_value),
     numbers |> String.trim() |> String.split(" ") |> Enum.map(&String.to_integer/1)}
  end)

has_valid_configuration = fn target, numbers, acc, self ->
  cond do
    acc === target and length(numbers) === 0 ->
      true

    acc > target ->
      false

    acc < target and length(numbers) === 0 ->
      false

    acc <= target ->
      self.(target, tl(numbers), acc + hd(numbers), self) or
        self.(target, tl(numbers), acc * hd(numbers), self)
  end
end

total_calibration_result =
  lines
  |> Enum.filter(fn {test_value, numbers} ->
    has_valid_configuration.(test_value, tl(numbers), hd(numbers), has_valid_configuration)
  end)
  |> Enum.map(fn {test_value, _} -> test_value end)
  |> Enum.sum()

IO.puts(total_calibration_result)

# Part 2

has_valid_configuration_with_concat = fn target, numbers, acc, self ->
  cond do
    acc === target and length(numbers) === 0 ->
      true

    acc > target ->
      false

    acc < target and length(numbers) === 0 ->
      false

    acc <= target ->
      self.(target, tl(numbers), acc + hd(numbers), self) or
        self.(target, tl(numbers), acc * hd(numbers), self) or
        self.(
          target,
          tl(numbers),
          String.to_integer(Integer.to_string(acc) <> Integer.to_string(hd(numbers))),
          self
        )
  end
end

total_calibration_result_with_concat =
  lines
  |> Enum.filter(fn {test_value, numbers} ->
    has_valid_configuration_with_concat.(
      test_value,
      tl(numbers),
      hd(numbers),
      has_valid_configuration_with_concat
    )
  end)
  |> Enum.map(fn {test_value, _} -> test_value end)
  |> Enum.sum()

IO.puts(total_calibration_result_with_concat)
