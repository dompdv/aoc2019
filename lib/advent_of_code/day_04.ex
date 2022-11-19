defmodule AdventOfCode.Day04 do
  import Enum

  def valid(n) do
    l = Integer.to_string(n) |> to_charlist()
    [_ | r] = l

    all?(for {a, b} <- zip(l, r), do: a <= b) and
      any?(for {a, b} <- zip(l, r), do: a == b)
  end

  def valid2(n) do
    l = Integer.to_string(n) |> to_charlist()
    [_ | r] = l
    increasing = all?(for {a, b} <- zip(l, r), do: a <= b)

    {a, acc} =
      reduce(l, {{nil, 0}, []}, fn
        e, {{nil, 0}, acc} ->
          {{e, 1}, acc}

        e, {{elt, occurences}, acc} ->
          if e == elt do
            {{elt, occurences + 1}, acc}
          else
            {{e, 1}, [{elt, occurences} | acc]}
          end
      end)

    dual = filter([a | acc], fn {_, occ} -> occ == 2 end) |> count()
    dual > 0 and increasing
  end

  def part1(args) do
    [l, h] = args |> String.trim() |> String.split("-") |> map(&String.to_integer/1)
    for(n <- l..h, do: valid(n)) |> filter(& &1) |> count()
  end

  def part2(args) do
    [l, h] = args |> String.trim() |> String.split("-") |> map(&String.to_integer/1)
    for(n <- l..h, do: valid2(n)) |> filter(& &1) |> count()
  end
end
