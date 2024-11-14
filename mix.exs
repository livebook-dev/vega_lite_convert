defmodule VegaLite.Convert.MixProject do
  use Mix.Project

  @version "1.0.1-dev"
  @description "Elixir bindings to Rust vl-convert library"

  def project do
    [
      app: :vega_lite_convert,
      version: @version,
      description: @description,
      name: "VegaLite.Convert",
      elixir: "~> 1.13",
      deps: deps(),
      docs: docs(),
      package: package(),
      # Modules used by VegaLite.WxViewer if available
      xref: [exclude: [:wx, :wx_object, :wxFrame, :wxWebView]]
    ]
  end

  def application do
    []
  end

  defp deps do
    [
      {:jason, "~> 1.4"},
      {:vega_lite, ">= 0.0.0"},
      {:rustler_precompiled, "~> 0.4"},
      {:rustler, ">= 0.0.0", optional: true},
      {:ex_doc, "~> 0.24", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [
      main: "VegaLite.Convert",
      source_url: "https://github.com/livebook-dev/vega_lite_convert",
      source_ref: "v#{@version}"
    ]
  end

  def package do
    [
      files: [
        "lib",
        "native/ex_vl_convert/.cargo",
        "native/ex_vl_convert/src",
        "native/ex_vl_convert/Cargo*",
        "checksum-*.exs",
        "mix.exs"
      ],
      licenses: ["Apache-2.0"],
      links: %{
        "GitHub" => "https://github.com/livebook-dev/vega_lite_convert"
      }
    ]
  end
end
