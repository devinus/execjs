defmodule Execjs.Mixfile do
  use Mix.Project

  def project do
    [ app: :execjs,
      version: "0.0.1",
      elixir: "~> 0.10.3",
      deps: deps(Mix.env) ]
  end

  # Configuration for the OTP application
  def application do
    []
  end

  # Returns the list of dependencies in the format:
  # { :foobar, "~> 0.1", git: "https://github.com/elixir-lang/foobar.git" }
  defp deps(:dev) do
    deps(:prod) ++ [{ :benchmark, github: "meh/elixir-benchmark" }]
  end

  defp deps(_) do
    [ { :jazz, github: "meh/jazz", tag: "v0.0.1" } ]
  end
end
