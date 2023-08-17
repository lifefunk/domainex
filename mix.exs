defmodule Domainex.MixProject do
  use Mix.Project

  def project do
    [
      app: :domainex,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      description: description(),
      source_url: "https://github.com/lifefunk/domainex",
      docs: [
        main: "Domainex",
        extras: ["README.md"]
      ]
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
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:ex_doc, "~> 0.21", only: :dev, runtime: false}
    ]
  end

  defp description() do
    "A common type specs and helper function for domain builder"
  end

  defp package() do
    [
      name: "domainex",
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/lifefunk/domainex"}
    ]
  end
end
