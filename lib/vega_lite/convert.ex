defmodule VegaLite.Convert do
  @moduledoc """
  Various export methods for a `VegaLite` specification.

  All of the exports are performed via a Rustler NIF that wraps the
  [vl-convert-rs](https://github.com/vega/vl-convert) Rust library.
  """

  alias VegaLite.Convert.WxViewer
  alias VegaLite.Convert.Native

  @doc """
  Saves a `VegaLite` specification to file in one of
  the supported formats.

  Any additional options provided beyond `:format` are passed to
  the functions that export to the desired format.

  ## Options

    * `:format` - the format to export the graphic as,
      must be either of: `:json`, `:html`, `:png`, `:svg`, `:pdf`,
      `:jpeg`, `:jpg`. By default the format is inferred from the
      file extension.
  """
  @spec save!(VegaLite.t(), binary(), keyword()) :: :ok
  def save!(vl, path, opts \\ []) do
    {format, opts} =
      Keyword.pop_lazy(opts, :format, fn ->
        path
        |> Path.extname()
        |> String.trim_leading(".")
        |> String.to_existing_atom()
      end)

    content =
      case format do
        :json ->
          to_json(vl, opts)

        :html ->
          to_html(vl, opts)

        :png ->
          to_png(vl, opts)

        :svg ->
          to_svg(vl)

        :pdf ->
          to_pdf(vl)

        jpeg when jpeg in [:jpeg, :jpg] ->
          to_jpeg(vl, opts)

        _ ->
          raise ArgumentError,
                "unsupported export format, expected :json, :html, :png, :svg, :pdf, :jpeg or :jpg got: #{inspect(format)}"
      end

    File.write!(path, content)
  end

  @doc """
  Returns the underlying Vega-Lite specification as JSON.

  ## Options

    * `:target` - specifies whether JSON export is in the VegaLite
    format or Vega. Valid options are `:vega_lite` or `:vega`. Default
    is `:vega_lite`.
  """
  @spec to_json(vl :: VegaLite.t(), opts :: keyword()) :: String.t()
  def to_json(vl, opts \\ []) do
    vega_lite_json =
      vl
      |> VegaLite.to_spec()
      |> Jason.encode!()

    case Keyword.get(opts, :target, :vega_lite) do
      :vega_lite ->
        vega_lite_json

      :vega ->
        vega_lite_json
        |> Native.vegalite_to_vega()
        |> unwrap!()
    end
  end

  @doc """
  Builds an HTML page that renders the given graphic.

  The HTML page loads necessary JavaScript dependencies from a CDN
  and then renders the graphic in a root element.

  ## Options

    * `:bundle` - Configures whether the VegaLite client side JS library is
      embedded in the document or if it is pulled down from the CDN. Default
      is `true`.

    * `:renderer` - This configuration determines how the VegaLite
      chart is rendered in the HTML document. Possible values are: `:svg`,
      `:canvas`, or `:hybrid`. Default is `:svg`.
  """
  @spec to_html(VegaLite.t()) :: binary()
  def to_html(vl, opts \\ []) do
    bundle = Keyword.get(opts, :bundle, true)
    renderer = opts |> Keyword.get(:renderer, :svg) |> to_string()

    vl
    |> to_json()
    |> Native.vegalite_to_html(bundle, renderer)
    |> unwrap!()
  end

  @doc """
  Renders the given graphic as a PNG image and returns
  its binary content.

  ## Options

    * `:scale` - The image scale factor. Default is `1.0`.

    * `:ppi` - The pixels per inch. Default is `72.0`.
  """
  @spec to_png(VegaLite.t(), keyword()) :: binary()
  def to_png(vl, opts \\ []) do
    scale = Keyword.get(opts, :scale, 1.0)
    ppi = Keyword.get(opts, :ppi, 72.0)

    vl
    |> to_json()
    |> Native.vegalite_to_png(scale, ppi)
    |> unwrap!()
  end

  @doc """
  Renders the given graphic as an SVG image and returns
  its binary content.
  """
  @spec to_svg(VegaLite.t()) :: binary()
  def to_svg(vl) do
    vl
    |> to_json()
    |> Native.vegalite_to_svg()
    |> unwrap!()
  end

  @doc """
  Renders the given graphic as a PDF and returns
  its binary content.
  """
  @spec to_pdf(VegaLite.t()) :: binary()
  def to_pdf(vl) do
    vl
    |> to_json()
    |> Native.vegalite_to_pdf()
    |> unwrap!()
  end

  @doc """
  Renders the given graphic as a JPEG image and returns
  its binary content.

  ## Options

    * `:scale` - The image scale factor. Default is `1.0`.

    * `:quality` - The quality of the generated JPEG between 0
      (worst) and 100 (best). Default is `90`.
  """
  @spec to_jpeg(VegaLite.t(), keyword()) :: binary()
  def to_jpeg(vl, opts \\ []) do
    scale = Keyword.get(opts, :scale, 1.0)
    quality = Keyword.get(opts, :quality, 90)

    vl
    |> to_json()
    |> Native.vegalite_to_jpeg(scale, quality)
    |> unwrap!()
  end

  @doc """
  Renders a `VegaLite` specification in GUI window widget.

  Requires Erlang compilation to include the `:wx` module.
  """
  @spec show(VegaLite.t()) :: :ok | :error
  def show(vl) do
    with {:ok, _pid} <- start_wx_viewer(vl), do: :ok
  end

  @doc """
  Same as `show/1`, but blocks until the window widget is closed.
  """
  @spec show_and_wait(VegaLite.t()) :: :ok | :error
  def show_and_wait(vl) do
    with {:ok, pid} <- start_wx_viewer(vl) do
      ref = Process.monitor(pid)

      receive do
        {:DOWN, ^ref, :process, _object, _reason} -> :ok
      end
    end
  end

  defp start_wx_viewer(vl) do
    vl
    |> to_html()
    |> WxViewer.start()
  end

  defp unwrap!(:ok), do: :ok
  defp unwrap!({:ok, value}), do: value
  defp unwrap!({:error, error}), do: raise(error)
end
