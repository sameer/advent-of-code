input = File.read!("input")
by_line = Enum.filter(String.split(input, "\n"), fn x -> String.contains?(x, "   ") end)

by_line_and_pair =
  Enum.map(by_line, fn line ->
    List.to_tuple(Enum.map(String.split(line), &String.to_integer/1))
  end)

{left, right} = Enum.unzip(by_line_and_pair)
[sorted_left, sorted_right] = Enum.map([left, right], &Enum.sort/1)
pairs = Enum.zip([sorted_left, sorted_right])
pairwise_distance = Enum.map(pairs, fn {l, r} -> abs(r - l) end)
distance = Enum.sum(pairwise_distance)
IO.puts(distance)

# Part 2
right_freq = Enum.frequencies(right)
similarity_score = Enum.sum(Enum.map(left, fn l -> l * Map.get(right_freq, l, 0)  end))
IO.puts(similarity_score)
