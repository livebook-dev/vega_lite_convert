use vl_convert_rs::converter::VgOpts;
use vl_convert_rs::converter::VlOpts;
use vl_convert_rs::VlConverter;
use vl_convert_rs::VlVersion;

// +-------------------------------------+
// |            Vega Functions           |
// +-------------------------------------+

#[rustler::nif(schedule = "DirtyCpu")]
fn vega_to_svg(vega_spec: String) -> Result<String, String> {
    let vg_spec: serde_json::Value = match serde_json::from_str(vega_spec.as_str()) {
        Ok(spec) => spec,
        Err(_err) => return Err("Vega spec is not valid JSON".to_string()),
    };

    let mut converter = VlConverter::new();
    let svg_result = futures::executor::block_on(converter.vega_to_svg(vg_spec, vg_opts()));

    return match svg_result {
        Ok(svg) => Ok(svg),
        Err(err) => Err(err.to_string()),
    };
}

#[rustler::nif(schedule = "DirtyCpu")]
fn vega_to_html(vega_spec: String, bundle: bool, renderer: String) -> Result<String, String> {
    let vg_spec: serde_json::Value = match serde_json::from_str(vega_spec.as_str()) {
        Ok(spec) => spec,
        Err(_err) => return Err("Vega spec is not valid JSON".to_string()),
    };

    let renderer_enum = match renderer.parse() {
        Ok(renderer_enum) => renderer_enum,
        Err(_err) => return Err("Invalid renderer provided".to_string()),
    };

    let mut converter = VlConverter::new();
    let html_result = futures::executor::block_on(converter.vega_to_html(
        vg_spec,
        vg_opts(),
        bundle,
        renderer_enum,
    ));

    return match html_result {
        Ok(html) => Ok(html),
        Err(err) => Err(err.to_string()),
    };
}

#[rustler::nif(schedule = "DirtyCpu")]
fn vega_to_png(vega_spec: String, scale: f32, ppi: f32) -> Result<Vec<u8>, String> {
    let vg_spec: serde_json::Value = match serde_json::from_str(vega_spec.as_str()) {
        Ok(spec) => spec,
        Err(_err) => return Err("Vega spec is not valid JSON".to_string()),
    };

    let mut converter = VlConverter::new();
    let jpeg_result = futures::executor::block_on(converter.vega_to_png(
        vg_spec,
        vg_opts(),
        Some(scale),
        Some(ppi),
    ));

    return match jpeg_result {
        Ok(jpeg) => Ok(jpeg),
        Err(err) => Err(err.to_string()),
    };
}

#[rustler::nif(schedule = "DirtyCpu")]
fn vega_to_jpeg(vega_spec: String, scale: f32, quality: u8) -> Result<Vec<u8>, String> {
    let vg_spec: serde_json::Value = match serde_json::from_str(vega_spec.as_str()) {
        Ok(spec) => spec,
        Err(_err) => return Err("VegaLite spec is not valid JSON".to_string()),
    };

    let mut converter = VlConverter::new();
    let jpeg_result = futures::executor::block_on(converter.vega_to_jpeg(
        vg_spec,
        vg_opts(),
        Some(scale),
        Some(quality),
    ));

    return match jpeg_result {
        Ok(jpeg) => Ok(jpeg),
        Err(err) => Err(err.to_string()),
    };
}

#[rustler::nif(schedule = "DirtyCpu")]
fn vega_to_pdf(vega_spec: String) -> Result<Vec<u8>, String> {
    let vg_spec: serde_json::Value = match serde_json::from_str(vega_spec.as_str()) {
        Ok(spec) => spec,
        Err(_err) => return Err("Vega spec is not valid JSON".to_string()),
    };

    let mut converter = VlConverter::new();
    let pdf_result = futures::executor::block_on(converter.vega_to_pdf(vg_spec, vg_opts()));

    return match pdf_result {
        Ok(pdf) => Ok(pdf),
        Err(err) => Err(err.to_string()),
    };
}

// +-------------------------------------+
// |          VegaLite Functions         |
// +-------------------------------------+

#[rustler::nif(schedule = "DirtyCpu")]
fn vegalite_to_svg(vega_lite_spec: String) -> Result<String, String> {
    let vl_spec: serde_json::Value = match serde_json::from_str(vega_lite_spec.as_str()) {
        Ok(spec) => spec,
        Err(_err) => return Err("VegaLite spec is not valid JSON".to_string()),
    };

    let mut converter = VlConverter::new();
    let svg_result = futures::executor::block_on(converter.vegalite_to_svg(vl_spec, vl_opts()));

    return match svg_result {
        Ok(svg) => Ok(svg),
        Err(err) => Err(err.to_string()),
    };
}

#[rustler::nif(schedule = "DirtyCpu")]
fn vegalite_to_html(
    vega_lite_spec: String,
    bundle: bool,
    renderer: String,
) -> Result<String, String> {
    let vl_spec: serde_json::Value = match serde_json::from_str(vega_lite_spec.as_str()) {
        Ok(spec) => spec,
        Err(_err) => return Err("VegaLite spec is not valid JSON".to_string()),
    };

    let renderer_enum = match renderer.parse() {
        Ok(renderer_enum) => renderer_enum,
        Err(_err) => return Err("Invalid renderer provided".to_string()),
    };

    let mut converter = VlConverter::new();
    let html_result = futures::executor::block_on(converter.vegalite_to_html(
        vl_spec,
        vl_opts(),
        bundle,
        renderer_enum,
    ));

    return match html_result {
        Ok(html) => Ok(html),
        Err(err) => Err(err.to_string()),
    };
}

#[rustler::nif(schedule = "DirtyCpu")]
fn vegalite_to_png(vega_lite_spec: String, scale: f32, ppi: f32) -> Result<Vec<u8>, String> {
    let vl_spec: serde_json::Value = match serde_json::from_str(vega_lite_spec.as_str()) {
        Ok(spec) => spec,
        Err(_err) => return Err("VegaLite spec is not valid JSON".to_string()),
    };

    let mut converter = VlConverter::new();
    let png_result = futures::executor::block_on(converter.vegalite_to_png(
        vl_spec,
        vl_opts(),
        Some(scale),
        Some(ppi),
    ));

    return match png_result {
        Ok(png) => Ok(png),
        Err(err) => Err(err.to_string()),
    };
}

#[rustler::nif(schedule = "DirtyCpu")]
fn vegalite_to_jpeg(vega_lite_spec: String, scale: f32, quality: u8) -> Result<Vec<u8>, String> {
    let vl_spec: serde_json::Value = match serde_json::from_str(vega_lite_spec.as_str()) {
        Ok(spec) => spec,
        Err(_err) => return Err("VegaLite spec is not valid JSON".to_string()),
    };

    let mut converter = VlConverter::new();
    let jpeg_result = futures::executor::block_on(converter.vegalite_to_jpeg(
        vl_spec,
        vl_opts(),
        Some(scale),
        Some(quality),
    ));

    return match jpeg_result {
        Ok(jpeg) => Ok(jpeg),
        Err(err) => Err(err.to_string()),
    };
}

#[rustler::nif(schedule = "DirtyCpu")]
fn vegalite_to_pdf(vega_lite_spec: String) -> Result<Vec<u8>, String> {
    let vl_spec: serde_json::Value = match serde_json::from_str(vega_lite_spec.as_str()) {
        Ok(spec) => spec,
        Err(_err) => return Err("VegaLite spec is not valid JSON".to_string()),
    };

    let mut converter = VlConverter::new();
    let pdf_result = futures::executor::block_on(converter.vegalite_to_pdf(vl_spec, vl_opts()));

    return match pdf_result {
        Ok(pdf) => Ok(pdf),
        Err(err) => Err(err.to_string()),
    };
}

#[rustler::nif(schedule = "DirtyCpu")]
fn vegalite_to_vega(vega_lite_spec: String) -> Result<String, String> {
    let vl_spec: serde_json::Value = match serde_json::from_str(vega_lite_spec.as_str()) {
        Ok(spec) => spec,
        Err(_err) => return Err("VegaLite spec is not valid JSON".to_string()),
    };

    let mut converter = VlConverter::new();
    let result = futures::executor::block_on(converter.vegalite_to_vega(vl_spec, vl_opts()));

    return match result {
        Ok(result) => Ok(result.to_string()),
        Err(err) => Err(err.to_string()),
    };
}
// +-------------------------------------+
// |          Helper Functions           |
// +-------------------------------------+

fn vg_opts() -> VgOpts {
    return VgOpts {
        ..Default::default()
    };
}

fn vl_opts() -> VlOpts {
    return VlOpts {
        vl_version: VlVersion::v5_20,
        ..Default::default()
    };
}

rustler::init!("Elixir.VegaLite.Native");
