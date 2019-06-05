defmodule Hrlfind do
  @moduledoc """
  Hrlfind should find the full path to an Erlang hrl file, starting from a line of source.
  A rebar build system is assumed.
  Example source line:
  -include( "include/diameter_3gpp_ts32_299.hrl" ).
  should return
  "/path/_build/default/lib/app/include/diameter_3gpp_ts32_299.hrl"
  """

  @doc """
  File Name starting from a line of source. Since shells find it difficult to handle ( in the argument list, most
  use cases will be with only the file name. So this one is over engineered.

  ## Examples

      iex> Hrlfind.file_name "asd.hrl"
      "asd.hrl"

  """
  def file_name(line) do
    line |> trim |> String.trim() |> String.trim("\"")
  end

  @doc """
  Include file name returns full path to the file if it exists in a directory on the same level as the current working directory. Otherwise "".

  ## Examples

      in_directory_src> Hrlfind.local "asd.hrl"
      "/full/path/include/asd.hrl"

  """
  def include(file) do
    p = Path.join([Path.dirname(File.cwd!()), "*", file])
    include_wildcard(Path.wildcard(p))
  end

  @doc """
  Lib file name returns full path to the file if it exists in an include directory of an app in a _build lib to the current working directory. Otherwise "".

  ## Examples

      in_directory_src> Hrlfind.lib "asd.hrl"
      "/full/path/_build/default/lib/anapp/include/asd.hrl"

  """
  def lib(file) do
    b = build_directory(File.cwd!())
    p = Path.join([b, "*", "lib", file])
    IO.inspect(p)
    lib_wildcard(Path.wildcard(p))
  end

  @doc """
  Local file name returns full path to the file if it exists in the current working directory. Otherwise "".

  ## Examples

      no_prompt> Hrlfind.local "asd.hrl"
      "/full/path/asd.hrl"

  """
  def local(file) do
    p = Path.join(File.cwd!(), file)
    local(File.regular?(p), p)
  end

  def main([]) do
    IO.puts(@moduledoc)
  end

  def main([line]) do
    result = Enum.reduce_while([&local/1, &include/1, &lib/1, &stdlib/1], file_name(line), &shim/2)
    IO.puts(result)
  end

  @doc """
  Stdlib file name returns full path to the file if it exists in an include directory of a stdlib app. Otherwise "".

  ## Examples

      in_directory_src> Hrlfind.stdlib "diameter/include/diameter.hrl"
      "/full/path/erlang/lib/diameter-2.0.3/include/diameter.hrl"

  """
  def stdlib(file) do
    e = erlang_directory()
    [app | rest] = Path.split( file )
    p = Path.join( e ++ [app <> "*" | rest] )
    IO.inspect(p)
    include_wildcard(Path.wildcard(p))
  end

  # Internal functions

  defp build_directory("/") do
    ""
  end

  defp build_directory(directory) do
    build_directory(File.ls!(directory), directory)
  end

  defp build_directory(true, directory) do
    Path.join(directory, "_build")
  end

  defp build_directory(false, directory) do
    build_directory(Path.dirname(directory))
  end

  defp build_directory(files, directory) do
    build_directory(Enum.member?(files, "_build"), directory)
  end

  defp erlang_directory() do
    {_, path} = :code.is_loaded(:kernel)
    Enum.take_while( Path.split( path ), fn (x) -> not String.starts_with?(x, "kernel") end )
  end

  # Crash if more than one is found.
  defp include_wildcard([]) do
    ""
  end

  defp include_wildcard([file]) do
    file
  end

  # Allow more than one since both _build/default and _build/test
  # are likely to have the same file.
  defp lib_wildcard([]) do
    ""
  end

  defp lib_wildcard([file | _]) do
    file
  end

  defp local(true, file) do
    file
  end

  defp local(false, _) do
    ""
  end

  # Do function on line to produce result, while no result is found ("").
  defp shim(function, line) do
    shim_halt(function.(line), line)
  end

  defp shim_halt("", line) do
    {:cont, line}
  end

  defp shim_halt(result, _) do
    {:halt, result}
  end

  defp trim(<<"-", line::binary>>) do
    line |> trim_leading |> trim_trailing
  end

  defp trim(line) do
    line
  end

  defp trim_leading(<<"include(", line::binary>>) do
    line
  end

  defp trim_leading(<<"include_lib(", line::binary>>) do
    line
  end

  defp trim_trailing(line) do
    String.trim_trailing(line, ").\n")
  end
end
