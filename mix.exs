defmodule VegaLiteConvert.MixProject do
  use Mix.Project

  @version "0.1.0"
  @description "Elixir bindings to Rust vl-convert library"

  def project do
    [
      app: :vega_lite_convert,
      version: @version,
      description: @description,
      name: "VegaLiteConvert",
      elixir: "~> 1.17",
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
      {:rustler_precompiled, "~> 0.4"},
      {:rustler, ">= 0.0.0", optional: true},
      {:jason, "~> 1.4"},
      {:ex_doc, "~> 0.24", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [
      main: "VegaLiteConvert",
      source_url: "https://github.com/livebook-dev/vega_lite_convert",
      source_ref: "v#{@version}"
    ]
  end

  def package do
    [
      licenses: ["Apache-2.0"],
      links: %{
        "GitHub" => "https://github.com/livebook-dev/vega_lite_convert"
      }
    ]
  end
end
