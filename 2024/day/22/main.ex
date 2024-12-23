secrets =
  File.read!("input") |> String.trim() |> String.split("\n") |> Enum.map(&String.to_integer/1)

mix = &Bitwise.bxor(&1, &2)
prune = &rem(&1, 16_777_216)

simulate = fn secret, remaining, self ->
  case remaining do
    0 ->
      secret

    _ ->
      secret = prune.(mix.(secret, secret * 64))
      secret = prune.(mix.(secret, div(secret, 32)))
      secret = prune.(mix.(secret, secret * 2048))
      self.(secret, remaining - 1, self)
  end
end

secrets |> Enum.map(&simulate.(&1, 2000, simulate)) |> Enum.sum() |> IO.inspect()

# Part 2

simulate_list = fn secret, remaining, acc, self ->
  case remaining do
    0 ->
      [secret | acc] |> Enum.reverse()

    _ ->
      new_secret = secret
      new_secret = prune.(mix.(new_secret, new_secret * 64))
      new_secret = prune.(mix.(new_secret, div(new_secret, 32)))
      new_secret = prune.(mix.(new_secret, new_secret * 2048))
      self.(new_secret, remaining - 1, [secret | acc], self)
  end
end

price_list = fn secret, count ->
  secret_sequence = simulate_list.(secret, count, [], simulate_list)
  prices = secret_sequence |> Enum.map(&rem(&1, 10))

  prices
end

diff_list = fn prices ->
  prices |> Enum.zip(tl(prices)) |> Enum.map(fn {prev, cur} -> cur - prev end)
end

diffs_to_total_price =
  secrets
  |> Enum.reduce(Map.new(), fn secret, acc ->
    prices = price_list.(secret, 2000)
    diffs = diff_list.(prices)

    price_and_diff =
      Enum.zip([
        prices |> tl() |> tl() |> tl() |> tl(),
        diffs,
        diffs |> tl(),
        diffs |> tl() |> tl(),
        diffs |> tl() |> tl() |> tl()
      ])

    to_incorporate =
      price_and_diff
      |> Enum.reduce(Map.new(), fn {p, d1, d2, d3, d4}, acc ->
        Map.get_and_update(acc, {d1, d2, d3, d4}, fn current ->
          if current === nil do
            {current, p}
          else
            {current, current}
          end
        end)
        |> elem(1)
      end)

    Map.merge(acc, to_incorporate, fn _k, v1, v2 -> v1 + v2 end)
  end)

diffs_to_total_price
|> Map.to_list()
|> Enum.max_by(fn {_, p} -> p end)
|> elem(1)
|> IO.inspect()
