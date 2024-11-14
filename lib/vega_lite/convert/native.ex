defmodule VegaLite.Convert.Native do
  @moduledoc false

  mix_config = Mix.Project.config()
  version = mix_config[:version]
  github_url = mix_config[:package][:links]["GitHub"]

  # The targets we support are limited by https://github.com/denoland/rusty_v8
  targets = ~w(
    aarch64-apple-darwin
    aarch64-unknown-linux-gnu
    x86_64-apple-darwin
    x86_64-pc-windows-msvc
    x86_64-unknown-linux-gnu
  )

  use RustlerPrecompiled,
    otp_app: :vega_lite_convert,
    crate: "ex_vl_convert",
    version: version,
    base_url: "#{github_url}/releases/download/v#{version}",
    targets: targets,
    # We don't use any features of newer NIF versions, so 2.15 is enough.
    nif_versions: ["2.15"],
    force_build: System.get_env("VEGA_LITE_CONVERT_BUILD") in ["1", "true"]

  # Vega related NIF functions
  def vega_to_html(_vg_json_spec, _bundle, _renderer), do: :erlang.nif_error(:nif_not_loaded)
  def vega_to_jpeg(_vg_json_spec, _scale, _quality), do: :erlang.nif_error(:nif_not_loaded)
  def vega_to_pdf(_vg_json_spec), do: :erlang.nif_error(:nif_not_loaded)
  def vega_to_png(_vg_json_spec, _scale, _ppi), do: :erlang.nif_error(:nif_not_loaded)
  def vega_to_svg(_vg_json_spec), do: :erlang.nif_error(:nif_not_loaded)

  # VegaLite related NIF functions
  def vegalite_to_html(_vg_json_spec, _bundle, _renderer), do: :erlang.nif_error(:nif_not_loaded)
  def vegalite_to_jpeg(_vl_json_spec, _scale, _quality), do: :erlang.nif_error(:nif_not_loaded)
  def vegalite_to_pdf(_vl_json_spec), do: :erlang.nif_error(:nif_not_loaded)
  def vegalite_to_png(_vl_json_spec, _scale, _ppi), do: :erlang.nif_error(:nif_not_loaded)
  def vegalite_to_svg(_vl_json_spec), do: :erlang.nif_error(:nif_not_loaded)
  def vegalite_to_vega(_vl_json_spec), do: :erlang.nif_error(:nif_not_loaded)
end
