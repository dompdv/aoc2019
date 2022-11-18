defmodule AdventOfCode.Day01 do
  alias JasonVendored.Encode
  import Enum

  def part1(args) do
    args
    |> String.split("\n", trim: true)
    |> map(&String.to_integer/1)
    |> map(fn x -> div(x, 3) - 2 end)
    |> sum()
  end

  def fuel(x) when x <= 0, do: 0

  def fuel(x) do
    f = div(x, 3) - 2
    if f > 0, do: f + fuel(f), else: 0
  end

  def part2(args) do
    args
    |> String.split("\n", trim: true)
    |> map(&String.to_integer/1)
    |> map(&fuel/1)
    |> sum()
  end
end
