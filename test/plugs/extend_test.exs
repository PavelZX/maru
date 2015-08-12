defmodule Maru.Plugs.ExtendTest do
  use ExUnit.Case, async: true
  alias Plug.Conn

  defmodule Test1 do
    use Maru.Router
    version "v1"

    get :test1 do
      "test1 v1"
    end

    get :test2 do
      "test2 v1"
    end
  end

  defp conn(method, path, version) do
    Plug.Test.conn(method, path)
 |> Maru.Plugs.Prepare.call([])
 |> Conn.put_private(:maru_version, version)
  end

  test "version extend" do
    defmodule Test2 do
      use Maru.Router
      version "v2", extend: "v1", at: Test1
    end

    assert %Conn{resp_body: "test1 v1"} = conn(:get, "/test1", "v2") |> Test2.call([])
    assert %Conn{resp_body: "test2 v1"} = conn(:get, "/test2", "v2") |> Test2.call([])
  end

  test "version extend only" do
    defmodule Test3 do
      use Maru.Router
      version "v3", extend: "v1", at: Test1, only: [
        get: "/test1"
      ]
    end

    assert %Conn{resp_body: "test1 v1"} = conn(:get, "/test1", "v3") |> Test3.call([])
    assert %Conn{halted: false} = conn(:get, "/test2", "v3") |> Test3.call([])
  end

  test "version extend except" do
    defmodule Test4 do
      use Maru.Router
      version "v4", extend: "v1", at: Test1, except: [
        match: "/test1"
      ]
    end

    assert %Conn{halted: false} = conn(:get, "/test1", "v4") |> Test4.call([])
    assert %Conn{resp_body: "test2 v1"} = conn(:get, "/test2", "v4") |> Test4.call([])
  end
end
