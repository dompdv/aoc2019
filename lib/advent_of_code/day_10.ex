defmodule AdventOfCode.Day10 do
  import Enum

  def parse(args) do
    args
    |> String.split("\n", trim: true)
    |> map(&to_charlist/1)
    |> with_index()
    |> map(fn {l, y} ->
      with_index(l) |> filter(fn {c, _} -> c == ?# end) |> map(fn {_c, x} -> {x, y} end)
    end)
    |> List.flatten()
  end

  def in_between({x, y}, {x1, y1}, {x2, y2}) do
    colinear = (y - y1) * (x2 - x1) == (x - x1) * (y2 - y1)

    cond do
      colinear and x1 != x2 ->
        k = (x - x1) / (x2 - x1)
        k >= 0 and k <= 1

      colinear ->
        k = (y - y1) / (y2 - y1)
        k >= 0 and k <= 1

      true ->
        false
    end
  end

  def is_visible(as1, as2, asteroids) do
    all?(for a <- asteroids, a != as1, a != as2, do: not in_between(a, as1, as2))
  end

  def count_visible(asteroid, asteroids) do
    Enum.count(asteroids, fn as -> as != asteroid and is_visible(asteroid, as, asteroids) end)
  end

  def part1(args) do
    asteroids = parse(args)

    for(asteroid <- asteroids, do: {asteroid, count_visible(asteroid, asteroids)})
    |> map(&elem(&1, 1))
    |> max()
  end

  def compute_radial({xs, ys}, {x, y} = asteroid) do
    dx = x - xs
    dy = y - ys
    dist2 = dx * dx + dy * dy
    dist = :math.sqrt(dist2)
    from_cos = :math.acos(-dy / dist) * 180.0 / :math.pi()
    angle = if dx < 0, do: 360 - from_cos, else: from_cos
    {asteroid, dist, angle}
  end

  def compute_radials(station, asteroids), do: map(asteroids, &compute_radial(station, &1))

  def vaporize([], [], o), do: reverse(o)
  def vaporize([], s, o), do: vaporize(Enum.reverse(s), [], o)

  def vaporize([{d, [asteroid_in_angle]} | rest_of_asteroids], acc, o),
    do: vaporize(rest_of_asteroids, acc, [{d, asteroid_in_angle} | o])

  def vaporize([{d, [asteroid_in_angle | rest_in_angle]} | rest_of_asteroids], acc, o),
    do: vaporize(rest_of_asteroids, [{d, rest_in_angle} | acc], [{d, asteroid_in_angle} | o])

  def part2(args) do
    args = """
    .#..##.###...#######
    ##.############..##.
    .#.######.########.#
    .###.#######.####.#.
    #####.##.#.##.###.##
    ..#####..#.#########
    ####################
    #.####....###.#.#.##
    ##.#################
    #####.##.###..####..
    ..######..##.#######
    ####.##.####...##..#
    .#####..#.######.###
    ##...#.##########...
    #.##########.#######
    .####.#.###.###.#.##
    ....##.##.###..#####
    .#.#.###########.###
    #.#.#.#####.####.###
    ###.##.####.##.#..##
    """

    asteroids = parse(args)
    ranges = for(asteroid <- asteroids, do: {asteroid, count_visible(asteroid, asteroids)})
    max_targets = ranges |> map(&elem(&1, 1)) |> max()
    [{station, _}] = filter(ranges, fn {_, m} -> m == max_targets end)
    asteroids = ranges |> map(&elem(&1, 0)) |> filter(fn s -> s != station end)
    radials = compute_radials(station, asteroids) |> IO.inspect(label: "Radials:")

    sorted_and_regrouped =
      for {angle, asteroid_list} <- group_by(radials, &elem(&1, 2), fn {a, d, _} -> {d, a} end) do
        {angle, sort(asteroid_list, fn {a, _}, {b, _} -> a <= b end) |> map(&elem(&1, 1))}
      end
      |> sort()
      |> IO.inspect()

    vaporize(sorted_and_regrouped, [], [])
    |> with_index()
    |> map(fn {a, n} -> {n + 1, a} end)
    |> filter(fn {i, _} -> i in [1, 2, 3, 10, 20, 50, 100, 199, 200, 201, 202, 299] end)
  end
end
