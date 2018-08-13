defmodule Execjs.Mixfile do
  use Mix.Project

  @version_path Path.join([__DIR__, "VERSION"])
  @external_resource @version_path

  @version @version_path |> File.read!() |> String.trim()

  def project do
    [
      app: :execjs,
      version: @version,
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      description: "Run JavaScript code from Elixir",
      deps: deps(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:poison, "~> 4.0"},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false},
      {:dialyxir, "~> 0.5", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      files: ~w(lib priv mix.exs README.md LICENSE VERSION),
      maintainers: ["Devin Alexander Torres"],
      licenses: ["CC0-1.0"],
      links: %{"GitHub" => "https://github.com/devinus/execjs"}
    ]
  end
end
