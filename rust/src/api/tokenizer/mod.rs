use flutter_rust_bridge::frb;
pub use tokenizers::tokenizer::Tokenizer;
use tokenizers::Token;

#[frb(external)]
impl Tokenizer {
    #[frb(sync)]
    pub fn new(_model: tokenizers::models::bpe::BPE) -> Self {}
}

#[frb(external)]
impl Token {}

#[frb(sync)]
pub fn id(t: Token) -> u32 {
    return t.id;
}
