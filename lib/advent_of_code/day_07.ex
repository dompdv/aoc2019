defmodule AdventOfCode.Day07 do
  import Enum

  def parse(args) do
    args
    |> String.trim()
    |> String.split(",", trim: true)
    |> map(&String.to_integer/1)
    |> with_index(fn a, b -> {b, a} end)
    |> Map.new()
  end

  def execute_instruction(99, _modes, pc, program, input, output),
    do: {:stop, {pc, program, input, output}}

  def execute_instruction(1, [ma, mb, _mc], pc, program, input, output) do
    a = Map.get(program, pc + 1, 0)
    b = Map.get(program, pc + 2, 0)
    c = Map.get(program, pc + 3, 0)
    va = if ma == 0, do: Map.get(program, a, 0), else: a
    vb = if mb == 0, do: Map.get(program, b, 0), else: b
    {:run, {pc + 4, Map.put(program, c, va + vb), input, output}}
  end

  def execute_instruction(2, [ma, mb, _mc], pc, program, input, output) do
    a = Map.get(program, pc + 1, 0)
    b = Map.get(program, pc + 2, 0)
    c = Map.get(program, pc + 3, 0)
    va = if ma == 0, do: Map.get(program, a, 0), else: a
    vb = if mb == 0, do: Map.get(program, b, 0), else: b
    {:run, {pc + 4, Map.put(program, c, va * vb), input, output}}
  end

  def execute_instruction(3, _modes, pc, program, [i | r_input], output) do
    {:run, {pc + 2, Map.put(program, Map.get(program, pc + 1), i), r_input, output}}
  end

  def execute_instruction(4, _modes, pc, program, input, output) do
    {:output,
     {pc + 2, program, input, output ++ [Map.get(program, Map.get(program, pc + 1), nil)]}}
  end

  def execute_instruction(5, [ma, mb, _mc], pc, program, input, output) do
    a = Map.get(program, pc + 1, 0)
    b = Map.get(program, pc + 2, 0)
    va = if ma == 0, do: Map.get(program, a, 0), else: a
    vb = if mb == 0, do: Map.get(program, b, 0), else: b

    if va != 0,
      do: {:run, {vb, program, input, output}},
      else: {:run, {pc + 3, program, input, output}}
  end

  def execute_instruction(6, [ma, mb, _mc], pc, program, input, output) do
    a = Map.get(program, pc + 1, 0)
    b = Map.get(program, pc + 2, 0)
    va = if ma == 0, do: Map.get(program, a, 0), else: a
    vb = if mb == 0, do: Map.get(program, b, 0), else: b

    if va == 0,
      do: {:run, {vb, program, input, output}},
      else: {:run, {pc + 3, program, input, output}}
  end

  def execute_instruction(7, [ma, mb, _mc], pc, program, input, output) do
    a = Map.get(program, pc + 1, 0)
    b = Map.get(program, pc + 2, 0)
    c = Map.get(program, pc + 3, 0)
    va = if ma == 0, do: Map.get(program, a, 0), else: a
    vb = if mb == 0, do: Map.get(program, b, 0), else: b
    {:run, {pc + 4, Map.put(program, c, if(va < vb, do: 1, else: 0)), input, output}}
  end

  def execute_instruction(8, [ma, mb, _mc], pc, program, input, output) do
    a = Map.get(program, pc + 1, 0)
    b = Map.get(program, pc + 2, 0)
    c = Map.get(program, pc + 3, 0)
    va = if ma == 0, do: Map.get(program, a, 0), else: a
    vb = if mb == 0, do: Map.get(program, b, 0), else: b
    {:run, {pc + 4, Map.put(program, c, if(va == vb, do: 1, else: 0)), input, output}}
  end

  def decode_instruction(ins) do
    ins = to_charlist(Integer.to_string(ins))
    [a, b, c, d, e] = List.duplicate(?0, 5 - length(ins)) ++ ins
    {(d - ?0) * 10 + (e - ?0), [c - ?0, b - ?0, a - ?0]}
  end

  def execute_step(pc, program, input, output) do
    {opcode, modes} = decode_instruction(program[pc])
    execute_instruction(opcode, modes, pc, program, input, output)
  end

  def execute(pc, program, input, output) do
    #    IO.inspect(binding())
    {stop, {pc, program, input, output}} = execute_step(pc, program, input, output)

    if stop == :stop do
      {pc, program, input, output}
    else
      execute(pc, program, input, output)
    end
  end

  def execute_with_pause(pc, program, input, output) do
    #    IO.inspect(binding())
    step = execute_step(pc, program, input, output)
    {stop, {pc, program, input, output}} = step

    cond do
      stop == :stop -> step
      stop == :output -> step
      true -> execute_with_pause(pc, program, input, output)
    end
  end

  def execute(program, input), do: execute(0, program, input, []) |> elem(3) |> List.last()

  def amplify(program, phase_setting) do
    reduce(phase_setting, 0, fn phase, input ->
      execute(program, [phase, input])
    end)
  end

  def permutations([]), do: []
  def permutations([a]), do: [[a]]
  def permutations([a, b]), do: [[a, b], [b, a]]

  def permutations(l) do
    Enum.reduce(l, [], fn e, acc ->
      sub_list = for c <- l, e != c, do: c
      sub_permutations = permutations(sub_list) |> Enum.map(fn r -> [e | r] end)
      acc ++ sub_permutations
    end)
  end

  def part1(args) do
    program = parse(args)

    reduce(permutations([0, 1, 2, 3, 4]), {-1, nil}, fn sequence, {max_so_far, _} = keep ->
      thrust = amplify(program, sequence)
      if thrust > max_so_far, do: {thrust, sequence}, else: keep
    end)
  end

  def compute_thrust(program, sequence) do
    sequence = for {e, i} <- with_index(sequence), into: %{}, do: {i, e}
    initial_execution_status = for {i, _e} <- sequence, into: %{}, do: {i, {0, program}}

    Enum.reduce_while(
      Stream.iterate(0, &(&1 + 1)),
      {0, initial_execution_status},
      fn amp, {last_output, execution_status} ->
        input = if amp < 5, do: [sequence[amp], last_output], else: [last_output]
        amp = rem(amp, 5)
        {pc, to_execute} = execution_status[amp]

        {stop, {pc_after, program_after, _input, output}} =
          execute_with_pause(pc, to_execute, input, [])

        if stop == :stop do
          {:halt, last_output}
        else
          {:cont, {hd(output), Map.put(execution_status, amp, {pc_after, program_after})}}
        end
      end
    )
  end

  def part2(args) do
    program = parse(args)

    reduce(permutations([5, 6, 7, 8, 9]), {-1, nil}, fn sequence, {max_so_far, _} = keep ->
      thrust = compute_thrust(program, sequence)
      if thrust > max_so_far, do: {thrust, sequence}, else: keep
    end)
  end
end
