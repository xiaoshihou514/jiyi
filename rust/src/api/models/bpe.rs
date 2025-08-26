use ahash::AHashMap;
use flutter_rust_bridge::frb;
use std::collections::HashMap;
pub use tokenizers::models::bpe::{BpeBuilder, BPE};
use tokenizers::{Result, Token};

type Pair = (u32, u32);
pub type Vocab = AHashMap<String, u32>;
pub type MergeMap = AHashMap<Pair, (u32, u32)>;
pub type Merges = Vec<(String, String)>;

#[frb(external)]
impl BpeBuilder {
    #[frb(sync)]
    pub fn new() -> Self {}
    #[frb(sync)]
    pub fn files(self, _vocab: String, _merges: String) -> Self {}
    #[frb(sync)]
    pub fn vocab_and_merges(self, _vocab: AHashMap<String, u32>, _merges: Merges) -> Self {}
    #[frb(sync)]
    pub fn cache_capacity(self, _capacity: usize) -> Self {}
    #[frb(sync)]
    pub fn dropout(self, _dropout: f32) -> Self {}
    #[frb(sync)]
    pub fn unk_token(self, _unk_token: String) -> Self {}
    #[frb(sync)]
    pub fn continuing_subword_prefix(self, _prefix: String) -> Self {}
    #[frb(sync)]
    pub fn end_of_word_suffix(self, _prefix: String) -> Self {}
    #[frb(sync)]
    pub fn fuse_unk(self, _fuse_unk: bool) -> Self {}
    #[frb(sync)]
    pub fn byte_fallback(self, _byte_fallback: bool) -> Self {}
    #[frb(sync)]
    pub fn ignore_merges(self, _ignore_merges: bool) -> Self {}
    #[frb(sync)]
    pub fn build(self) -> Result<BPE> {}
}

#[frb(external)]
impl BPE {
    #[frb(sync)]
    pub fn builder() -> BpeBuilder {}
    #[frb(sync)]
    pub fn new(_vocab: Vocab, _merges: Merges) -> Self {}
    #[frb(sync)]
    pub fn from_file(_vocab: &str, _merges: &str) -> BpeBuilder {}
    #[frb(sync)]
    pub fn read_file(_vocab: &str, _merges: &str) -> Result<(Vocab, Merges)> {}
    #[frb(sync)]
    pub fn clear_cache(&self) {}
    #[frb(sync)]
    pub fn get_vocab(&self) -> HashMap<String, u32> {}
    #[frb(sync)]
    pub fn get_unk_token(&self) -> &Option<String> {}
    #[frb(sync)]
    pub fn get_continuing_subword_prefix(&self) -> &Option<String> {}

    #[frb(sync)]
    pub fn get_vocab_size(&self) -> usize {}
    #[frb(sync)]
    pub fn tokenize(&self, _sequence: &str) -> Result<Vec<Token>> {}
    #[frb(sync)]
    pub fn token_to_id(&self, _token: &str) -> Option<u32> {}
    #[frb(sync)]
    pub fn id_to_token(&self, _id: u32) -> Option<String> {}
}
