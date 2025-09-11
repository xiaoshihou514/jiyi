use flutter_rust_bridge::frb;
use std::path::Path;
pub use tokenizers::Tokenizer;

#[frb(sync)]
pub fn tokenizer_from_config(config_path: String) -> Result<Tokenizer, String> {
    Tokenizer::from_file(Path::new(config_path.as_str())).map_err(|e| e.to_string())
}

#[frb(sync)]
pub fn encode(tokenizer: Tokenizer, input: String) -> Result<Vec<i64>, String> {
    match tokenizer.encode(input, false) {
        Ok(t) => Ok(t.get_ids().iter().map(|x| *x as i64).collect()),
        Err(e) => Err(e.to_string()),
    }
}
