defmodule AdventOfCode.Day08 do
  import Enum

  def part1(args) do
    %{?1 => n1, ?2 => n2} =
      args
      |> to_charlist()
      |> chunk_every(25 * 6)
      |> map(&frequencies/1)
      |> min_by(fn e -> e[?0] end)

    n1 * n2
  end

  def keep(s) do
    drop_while(s, fn e -> e == ?2 end) |> hd()
  end

  def part2(args) do
    w = 25
    h = 6

    layers = args |> to_charlist() |> chunk_every(w * h)

    image =
      for x <- 0..(w - 1), y <- 0..(h - 1), into: %{} do
        {{x, y}, keep(for(l <- layers, do: Enum.at(l, x + y * w)))}
      end

    for y <- 0..(h - 1) do
      for x <- 0..(w - 1), do: if(image[{x, y}] == ?0, do: " ", else: "X")
    end
    |> join("\n")
    |> IO.puts()
  end
end
