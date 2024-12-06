input = File.read!("input")

search = ~r"XMAS"
reverse_search = ~r"SAMX"
lines = Enum.filter(String.split(input, "\n"), fn l -> String.length(l) > 0 end)
height = length(lines)
width = String.length(hd(lines))

vertical_lines =
  Enum.map(0..(width - 1), fn w ->
    Enum.join(Enum.map(0..(height - 1), fn h -> String.at(Enum.at(lines, h), w) end))
  end)

diag = max(width, height)

sum_diagonals =
  Enum.map(
    0..(height - 1 + width - 1),
    fn sum ->
      Enum.join(
        Enum.reduce(0..(height - 1), [], fn i, acc ->
          j = sum - i

          if j in 0..(width - 1) do
            [String.at(Enum.at(lines, i), j) | acc]
          else
            acc
          end
        end)
      )
    end
  )

diff_diagonals =
  Enum.map(
    -(diag - 1)..(diag - 1),
    fn diff ->
      Enum.join(
        Enum.reduce(0..(height - 1), [], fn i, acc ->
          j = i - diff

          if j in 0..(width - 1) do
            [String.at(Enum.at(lines, i), j) | acc]
          else
            acc
          end
        end)
      )
    end
  )

count_func = fn l -> length(Regex.scan(search, l)) + length(Regex.scan(reverse_search, l)) end
horizontal = Enum.sum(Enum.map(lines, &count_func.(&1)))
vertical = Enum.sum(Enum.map(vertical_lines, &count_func.(&1)))

diagonal =
  Enum.sum(Enum.map(sum_diagonals, &count_func.(&1))) +
    Enum.sum(Enum.map(diff_diagonals, &count_func.(&1)))

count = horizontal + vertical + diagonal
# Still learning syntax 🫣
count |> IO.puts()

# Part 2
char_at_pos = fn i, j -> String.at(Enum.at(lines, i), j) end

is_mas_at = fn i, j ->
  ((char_at_pos.(i - 1, j - 1) === "M" and char_at_pos.(i + 1, j + 1) === "S") or
     (char_at_pos.(i - 1, j - 1) === "S" and char_at_pos.(i + 1, j + 1) === "M")) and
    ((char_at_pos.(i - 1, j + 1) === "M" and char_at_pos.(i + 1, j - 1) === "S") or
       (char_at_pos.(i - 1, j + 1) === "S" and char_at_pos.(i + 1, j - 1) === "M"))
end

mas_count =
  Enum.sum(
    Enum.map(1..(height - 2), fn i ->
      Enum.count(
        Enum.filter(1..(width - 2), fn j -> char_at_pos.(i, j) === "A" and is_mas_at.(i, j) end)
      )
    end)
  )

IO.puts(mas_count)
