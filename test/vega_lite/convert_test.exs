defmodule VegaLite.ConvertTest do
  use ExUnit.Case

  alias VegaLite, as: Vl
  alias VegaLite.Convert

  describe "save!/3" do
    @tag :tmp_dir
    test "should write a file to filesystem for all of the supported types", %{tmp_dir: tmp_dir} do
      supported_file_types = [
        :json,
        :html,
        :png,
        :svg,
        :pdf,
        :jpeg,
        :jpg
      ]

      vl = vl_chart()

      Enum.each(supported_file_types, fn file_type ->
        path = Path.join(tmp_dir, "test_file.#{file_type}")
        Convert.save!(vl, path)
        assert File.exists?(path)
      end)
    end

    @tag :tmp_dir
    test "should raise an error when an invalid file name is provided", %{tmp_dir: tmp_dir} do
      vl = vl_chart()
      path = Path.join(tmp_dir, "test_file.invalid")

      assert_raise ArgumentError,
                   "unsupported export format, expected :json, :html, :png, :svg, :pdf, :jpeg or :jpg got: :invalid",
                   fn ->
                     Convert.save!(vl, path)
                   end
    end

    @tag :tmp_dir
    test "should generate a file with a nonstandard extension if explicitly provided", %{
      tmp_dir: tmp_dir
    } do
      vl = vl_chart()

      path = Path.join(tmp_dir, "test_file.pngv2")
      Convert.save!(vl, path, format: :png)
      assert File.exists?(path)
    end
  end

  describe "to_json/2" do
    test "should return the spec as VegaLite formatted JSON" do
      vl = vl_chart()

      assert Convert.to_json(vl) =~ "https://vega.github.io/schema/vega-lite/v5.json"
    end

    test "should return the spec as Vega formatted JSON" do
      vl = vl_chart()

      assert Convert.to_json(vl, target: :vega) =~ "https://vega.github.io/schema/vega/v5.json"
    end
  end

  describe "to_svg/1" do
    test "should return the spec as VegaLite formatted JSON" do
      vl = vl_chart()
      svg = Convert.to_svg(vl)

      assert svg =~ ~S|xmlns="http://www.w3.org/2000/svg"|
    end
  end

  describe "to_pdf/1" do
    test "should generate a PDF document given a VegaLite spec" do
      vl = vl_chart()
      pdf = Convert.to_pdf(vl)

      assert <<37, 80, 68, 70, 45, _rest::binary>> = pdf
    end
  end

  describe "to_jpeg/2" do
    test "should generate a JPEG image given a VegaLite spec" do
      vl = vl_chart()
      jpeg = Convert.to_jpeg(vl)

      assert <<0xFFD8::size(16), _rest::binary>> = jpeg
    end

    test "should generate a JPEG image given a VegaLite spec with adjusted scaling" do
      vl = vl_chart()
      jpeg = Convert.to_jpeg(vl, scale: 2.0)

      assert <<0xFFD8::size(16), _rest::binary>> = jpeg
    end
  end

  describe "to_png/2" do
    test "should generate a PNG image given a VegaLite spec" do
      vl = vl_chart()
      png = Convert.to_png(vl)

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

    test "should generate a PNG image given a VegaLite spec with adjusted scaling" do
      vl = vl_chart()
      png = Convert.to_png(vl, scale: 2.0)

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
      vl = vl_chart()
      html = Convert.to_html(vl)

      assert html =~ ~S|{"renderer":"svg"}|
      refute html =~ "https://cdn.jsdelivr.net/npm/vega-lite@5.20"
    end

    test "should return an HTML document with the visual as an SVG without the JS bundled" do
      vl = vl_chart()
      html = Convert.to_html(vl, bundle: false)

      assert html =~ ~S|{"renderer":"svg"}|
      assert html =~ "https://cdn.jsdelivr.net/npm/vega-lite@5.20"
    end

    test "should return an HTML document with the visual as a Canvas with the JS bundled" do
      vl = vl_chart()
      html = Convert.to_html(vl, renderer: :canvas, bundle: true)

      refute html =~ "https://cdn.jsdelivr.net/npm/vega-lite@5.20"
      assert html =~ ~S|{"renderer":"canvas"}|
    end

    test "should return an HTML document with the visual as a Canvas without the JS bundled" do
      vl = vl_chart()
      html = Convert.to_html(vl, renderer: :canvas, bundle: false)

      assert html =~ "https://cdn.jsdelivr.net/npm/vega-lite@5.20"
      assert html =~ ~S|{"renderer":"canvas"}|
    end
  end

  defp vl_chart() do
    data = [
      %{"height" => 170, "weight" => 80, "width" => 10, "unused" => "a"},
      %{"height" => 190, "weight" => 85, "width" => 20, "unused" => "b"}
    ]

    Vl.new()
    |> Vl.data_from_values(data, only: ["height"])
    |> Vl.mark(:bar)
    |> Vl.encode_field(:x, "height", type: :quantitative)
  end
end
