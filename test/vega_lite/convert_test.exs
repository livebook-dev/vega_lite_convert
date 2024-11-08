defmodule VegaLiteConvertTest do
  use ExUnit.Case

  alias VegaLite, as: Vl
  alias VegaLite.Convert

  @data [
    %{"height" => 170, "weight" => 80, "width" => 10, "unused" => "a"},
    %{"height" => 190, "weight" => 85, "width" => 20, "unused" => "b"}
  ]

  describe "to_json/2" do
    test "should return the spec as VegaLite formatted JSON" do
      vl = generate_vl()

      assert Convert.to_json(vl) =~ "https://vega.github.io/schema/vega-lite/v5.json"
    end

    test "should return the spec as Vega formatted JSON" do
      vl = generate_vl()

      assert Convert.to_json(vl, target: :vega) =~ "https://vega.github.io/schema/vega/v5.json"
    end
  end

  describe "to_png/2" do
    test "should a PNG image given a VegaLite spec" do
      vl = generate_vl()

      png =
        vl
        |> Convert.to_png()
        |> :binary.list_to_bin()

      assert <<
               0x89,
               0x50,
               0x4E,
               0x47,
               0x0D,
               0x0A,
               0x1A,
               0x0A,
               _length::size(32),
               "IHDR",
               width::size(32),
               height::size(32),
               _rest::binary
             >> = png

      assert width == 212
      assert height == 62
    end

    test "should a PNG image given a VegaLite spec with adjusted scaling" do
      vl = generate_vl()

      png =
        vl
        |> Convert.to_png(scale: 2.0)
        |> :binary.list_to_bin()

      assert <<
               0x89,
               0x50,
               0x4E,
               0x47,
               0x0D,
               0x0A,
               0x1A,
               0x0A,
               _length::size(32),
               "IHDR",
               width::size(32),
               height::size(32),
               _rest::binary
             >> = png

      assert width == 424
      assert height == 124
    end
  end

  describe "to_html/2" do
    test "should return an HTML document with the visual as an SVG with the JS bundled by default" do
      vl = generate_vl()
      html = Convert.to_html(vl)

      assert html =~ "{\"renderer\":\"svg\"}"
      refute html =~ "https://cdn.jsdelivr.net/npm/vega-lite@5.20"
    end

    test "should return an HTML document with the visual as an SVG without the JS bundled" do
      vl = generate_vl()
      html = Convert.to_html(vl, bundle: false)

      assert html =~ "{\"renderer\":\"svg\"}"
      assert html =~ "https://cdn.jsdelivr.net/npm/vega-lite@5.20"
    end

    test "should return an HTML document with the visual as a Canvas with the JS bundled" do
      vl = generate_vl()
      html = Convert.to_html(vl, renderer: :canvas, bundle: true)

      refute html =~ "https://cdn.jsdelivr.net/npm/vega-lite@5.20"
      assert html =~ "{\"renderer\":\"canvas\"}"
    end

    test "should return an HTML document with the visual as a Canvas without the JS bundled" do
      vl = generate_vl()
      html = Convert.to_html(vl, renderer: :canvas, bundle: false)

      assert html =~ "https://cdn.jsdelivr.net/npm/vega-lite@5.20"
      assert html =~ "{\"renderer\":\"canvas\"}"
    end
  end

  defp generate_vl do
    Vl.new()
    |> Vl.data_from_values(@data, only: ["height"])
    |> Vl.mark(:bar)
    |> Vl.encode_field(:x, "height", type: :quantitative)
  end
end
