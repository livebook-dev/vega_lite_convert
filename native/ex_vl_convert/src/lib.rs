use rustler::env::Env;
use rustler::types::binary::Binary;
use rustler::types::binary::OwnedBinary;

use lazy_static::lazy_static;
use std::sync::Mutex;
use vl_convert_rs::anyhow::Error;
use vl_convert_rs::converter::VgOpts;
use vl_convert_rs::converter::VlOpts;
use vl_convert_rs::VlConverter;
use vl_convert_rs::VlVersion;

// We use a single instance of VlConvert to avoid segmentation faults.
// Note that this limits us to a single concurrent conversion at a time.
// See https://github.com/vega/vl-convert/issues/206#issuecomment-2598336507
lazy_static! {
    static ref VL_CONVERTER: Mutex<VlConverter> = Mutex::new(VlConverter::new());
}

// +-------------------------------------+
// |            Vega Functions           |
// +-------------------------------------+

#[rustler::nif(schedule = "DirtyCpu")]
fn vega_to_svg(vega_spec: String) -> Result<String, String> {
    let vg_spec = parse_spec(vega_spec)?;

    let mut converter = VL_CONVERTER
        .lock()
        .expect("Failed to acquire lock on Vega-Lite converter");

    let svg_result = futures::executor::block_on(converter.vega_to_svg(vg_spec, vg_opts()));

    return encode_string_result(svg_result);
}

#[rustler::nif(schedule = "DirtyCpu")]
fn vega_to_html(vega_spec: String, bundle: bool, renderer: String) -> Result<String, String> {
    let vg_spec = parse_spec(vega_spec)?;

    let renderer_enum = match renderer.parse() {
        Ok(renderer_enum) => renderer_enum,
        Err(_err) => return Err("Invalid renderer provided".to_string()),
    };

    let mut converter = VL_CONVERTER
        .lock()
        .expect("Failed to acquire lock on Vega-Lite converter");

    let html_result = futures::executor::block_on(converter.vega_to_html(
        vg_spec,
        vg_opts(),
        bundle,
        renderer_enum,
    ));

    return encode_string_result(html_result);
}

#[rustler::nif(schedule = "DirtyCpu")]
fn vega_to_png(env: Env, vega_spec: String, scale: f32, ppi: f32) -> Result<Binary, String> {
    let vg_spec = parse_spec(vega_spec)?;

    let mut converter = VL_CONVERTER
        .lock()
        .expect("Failed to acquire lock on Vega-Lite converter");

    let png_result = futures::executor::block_on(converter.vega_to_png(
        vg_spec,
        vg_opts(),
        Some(scale),
        Some(ppi),
    ));

    return encode_vec_result(env, png_result);
}

#[rustler::nif(schedule = "DirtyCpu")]
fn vega_to_jpeg(env: Env, vega_spec: String, scale: f32, quality: u8) -> Result<Binary, String> {
    let vg_spec = parse_spec(vega_spec)?;

    let mut converter = VL_CONVERTER
        .lock()
        .expect("Failed to acquire lock on Vega-Lite converter");

    let jpeg_result = futures::executor::block_on(converter.vega_to_jpeg(
        vg_spec,
        vg_opts(),
        Some(scale),
        Some(quality),
    ));

    return encode_vec_result(env, jpeg_result);
}

#[rustler::nif(schedule = "DirtyCpu")]
fn vega_to_pdf(env: Env, vega_spec: String) -> Result<Binary, String> {
    let vg_spec = parse_spec(vega_spec)?;

    let mut converter = VL_CONVERTER
        .lock()
        .expect("Failed to acquire lock on Vega-Lite converter");

    let pdf_result = futures::executor::block_on(converter.vega_to_pdf(vg_spec, vg_opts()));

    return encode_vec_result(env, pdf_result);
}

// +-------------------------------------+
// |          VegaLite Functions         |
// +-------------------------------------+

#[rustler::nif(schedule = "DirtyCpu")]
fn vegalite_to_svg(vega_lite_spec: String) -> Result<String, String> {
    let vl_spec = parse_spec(vega_lite_spec)?;

    let mut converter = VL_CONVERTER
        .lock()
        .expect("Failed to acquire lock on Vega-Lite converter");

    let svg_result = futures::executor::block_on(converter.vegalite_to_svg(vl_spec, vl_opts()));

    return encode_string_result(svg_result);
}

#[rustler::nif(schedule = "DirtyCpu")]
fn vegalite_to_html(
    vega_lite_spec: String,
    bundle: bool,
    renderer: String,
) -> Result<String, String> {
    let vl_spec = parse_spec(vega_lite_spec)?;

    let renderer_enum = match renderer.parse() {
        Ok(renderer_enum) => renderer_enum,
        Err(_err) => return Err("Invalid renderer provided".to_string()),
    };

    let mut converter = VL_CONVERTER
        .lock()
        .expect("Failed to acquire lock on Vega-Lite converter");

    let html_result = futures::executor::block_on(converter.vegalite_to_html(
        vl_spec,
        vl_opts(),
        bundle,
        renderer_enum,
    ));

    return encode_string_result(html_result);
}

#[rustler::nif(schedule = "DirtyCpu")]
fn vegalite_to_png(
    env: Env,
    vega_lite_spec: String,
    scale: f32,
    ppi: f32,
) -> Result<Binary, String> {
    let vl_spec = parse_spec(vega_lite_spec)?;

    let mut converter = VL_CONVERTER
        .lock()
        .expect("Failed to acquire lock on Vega-Lite converter");

    let png_result = futures::executor::block_on(converter.vegalite_to_png(
        vl_spec,
        vl_opts(),
        Some(scale),
        Some(ppi),
    ));

    return encode_vec_result(env, png_result);
}

#[rustler::nif(schedule = "DirtyCpu")]
fn vegalite_to_jpeg(
    env: Env,
    vega_lite_spec: String,
    scale: f32,
    quality: u8,
) -> Result<Binary, String> {
    let vl_spec = parse_spec(vega_lite_spec)?;

    let mut converter = VL_CONVERTER
        .lock()
        .expect("Failed to acquire lock on Vega-Lite converter");

    let jpeg_result = futures::executor::block_on(converter.vegalite_to_jpeg(
        vl_spec,
        vl_opts(),
        Some(scale),
        Some(quality),
    ));

    return encode_vec_result(env, jpeg_result);
}

#[rustler::nif(schedule = "DirtyCpu")]
fn vegalite_to_pdf(env: Env, vega_lite_spec: String) -> Result<Binary, String> {
    let vl_spec = parse_spec(vega_lite_spec)?;

    let mut converter = VL_CONVERTER
        .lock()
        .expect("Failed to acquire lock on Vega-Lite converter");

    let pdf_result = futures::executor::block_on(converter.vegalite_to_pdf(vl_spec, vl_opts()));

    return encode_vec_result(env, pdf_result);
}

#[rustler::nif(schedule = "DirtyCpu")]
fn vegalite_to_vega(vega_lite_spec: String) -> Result<String, String> {
    let vl_spec = parse_spec(vega_lite_spec)?;

    let mut converter = VL_CONVERTER
        .lock()
        .expect("Failed to acquire lock on Vega-Lite converter");

    let result = futures::executor::block_on(converter.vegalite_to_vega(vl_spec, vl_opts()));

    return match result {
        Ok(result) => Ok(result.to_string()),
        Err(err) => Err(err.to_string()),
    };
}
// +-------------------------------------+
// |          Helper Functions           |
// +-------------------------------------+

fn encode_vec_result(env: Env, result: Result<Vec<u8>, Error>) -> Result<Binary, String> {
    return match result {
        Ok(vec) => {
            let mut bin = OwnedBinary::new(vec.len()).expect("allocation failed");
            bin.as_mut_slice().copy_from_slice(vec.as_slice());
            Ok(Binary::from_owned(bin, env))
        }
        Err(err) => Err(err.to_string()),
    };
}

fn encode_string_result(result: Result<String, Error>) -> Result<String, String> {
    return match result {
        Ok(value) => Ok(value.to_string()),
        Err(err) => Err(err.to_string()),
    };
}

fn parse_spec(spec: String) -> Result<serde_json::Value, String> {
    return match serde_json::from_str(spec.as_str()) {
        Ok(spec) => Ok(spec),
        Err(_err) => Err("The given spec is not valid JSON".to_string()),
    };
}

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

rustler::init!("Elixir.VegaLite.Convert.Native");
