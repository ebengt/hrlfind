defmodule HrlfindTest do
  use ExUnit.Case
  doctest Hrlfind

  test "just the name" do
    assert Hrlfind.file_name("asd.hrl") == "asd.hrl"
  end

  test "name inside parenthesis" do
    assert Hrlfind.file_name(" \"asd.hrl\" ") == "asd.hrl"
  end

  test "whole line" do
    assert Hrlfind.file_name("-include( \"asd.hrl\" ).\n") == "asd.hrl"
  end

  test "lib line" do
    assert Hrlfind.file_name("-include_lib( \"asd.hrl\" ).\n") == "asd.hrl"
  end

  test "local file" do
    f = "local.hrl"
    File.write!(f, <<>>, [:write])

    result = Hrlfind.local(f)

    File.rm!(f)
    p = Path.join(File.cwd!(), f)
    assert result == p
    assert Hrlfind.local(f) == ""
  end

  test "include directory file" do
    f = "afile.hrl"
    d = "adir"
    include = Path.join(["..", d, f])
    File.mkdir_p!(Path.dirname(include))
    File.write!(include, <<>>, [:write])

    result = Hrlfind.include(f)

    File.rm!(include)
    p = Path.join([Path.dirname(File.cwd!()), d, f])
    assert result == p
    assert Hrlfind.include(f) == ""
  end

  test "lib directory file" do
    f = "anapp/include/afile.hrl"
    include = Path.join(["_build", "unlikely_to_exist", "lib", f])
    File.mkdir_p!(Path.dirname(include))
    File.write!(include, <<>>, [:write])

    result = Hrlfind.lib(f)

    File.rm!(include)
    p = Path.join(File.cwd!(), include)
    assert result == p
    assert Hrlfind.lib(f) == ""
    # Return even if there is no _build
    assert File.cd!("/etc", fn -> Hrlfind.lib(f) end) == ""
  end

  test "stdlib file" do
    f = "diameter/include/diameter.hrl"

    result = Hrlfind.stdlib(f)

    [hrl, include, diameter | _] = Enum.reverse( Path.split(result) )
    assert hrl === "diameter.hrl"
    assert include === "include"
    assert String.starts_with?( diameter,  "diameter" )
    assert String.length(diameter) > String.length("diameter")
  end
end
