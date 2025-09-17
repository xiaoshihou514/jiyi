use std::{path::PathBuf, str::FromStr};

use anyhow::Error as E;
use candle_transformers::models::qwen3::ModelForCausalLM as Model3;

use candle_core::utils::{cuda_is_available, metal_is_available};
use candle_core::{DType, Device, Tensor};
use candle_nn::VarBuilder;
use candle_transformers::generation::LogitsProcessor;
use flutter_rust_bridge::frb;
use tokenizers::Tokenizer;

/// /candle/candle-examples/src/token_output_stream.rs
/// This is a wrapper around a tokenizer to ensure that tokens can be returned to the user in a
/// streaming way rather than having to wait for the full decoding.
pub struct TokenOutputStream {
    tokenizer: tokenizers::Tokenizer,
    tokens: Vec<u32>,
    prev_index: usize,
    current_index: usize,
}

impl TokenOutputStream {
    pub fn new(tokenizer: tokenizers::Tokenizer) -> Self {
        Self {
            tokenizer,
            tokens: Vec::new(),
            prev_index: 0,
            current_index: 0,
        }
    }

    pub fn into_inner(self) -> tokenizers::Tokenizer {
        self.tokenizer
    }

    fn decode(&self, tokens: &[u32]) -> anyhow::Result<String> {
        match self.tokenizer.decode(tokens, true) {
            Ok(str) => Ok(str),
            Err(err) => anyhow::bail!("cannot decode: {err}"),
        }
    }

    // https://github.com/huggingface/text-generation-inference/blob/5ba53d44a18983a4de32d122f4cb46f4a17d9ef6/server/text_generation_server/models/model.py#L68
    pub fn next_token(&mut self, token: u32) -> anyhow::Result<Option<String>> {
        let prev_text = if self.tokens.is_empty() {
            String::new()
        } else {
            let tokens = &self.tokens[self.prev_index..self.current_index];
            self.decode(tokens)?
        };
        self.tokens.push(token);
        let text = self.decode(&self.tokens[self.prev_index..])?;
        if text.len() > prev_text.len() && text.chars().last().unwrap().is_alphanumeric() {
            let text = text.split_at(prev_text.len());
            self.prev_index = self.current_index;
            self.current_index = self.tokens.len();
            Ok(Some(text.1.to_string()))
        } else {
            Ok(None)
        }
    }

    pub fn decode_rest(&self) -> anyhow::Result<Option<String>> {
        let prev_text = if self.tokens.is_empty() {
            String::new()
        } else {
            let tokens = &self.tokens[self.prev_index..self.current_index];
            self.decode(tokens)?
        };
        let text = self.decode(&self.tokens[self.prev_index..])?;
        if text.len() > prev_text.len() {
            let text = text.split_at(prev_text.len());
            Ok(Some(text.1.to_string()))
        } else {
            Ok(None)
        }
    }

    pub fn decode_all(&self) -> anyhow::Result<String> {
        self.decode(&self.tokens)
    }

    pub fn get_token(&self, token_s: &str) -> Option<u32> {
        self.tokenizer.get_vocab(true).get(token_s).copied()
    }

    pub fn tokenizer(&self) -> &tokenizers::Tokenizer {
        &self.tokenizer
    }

    pub fn clear(&mut self) {
        self.tokens.clear();
        self.prev_index = 0;
        self.current_index = 0;
    }
}

struct TextGeneration {
    model: Model3,
    device: Device,
    tokenizer: TokenOutputStream,
    logits_processor: LogitsProcessor,
    repeat_penalty: f32,
    repeat_last_n: usize,
}

fn concat(p: &PathBuf, s: &str) -> PathBuf {
    let mut tmp = p.clone();
    tmp.push(s);
    tmp
}

impl TextGeneration {
    #[allow(clippy::too_many_arguments)]
    fn new(
        model: Model3,
        tokenizer: Tokenizer,
        seed: u64,
        temp: Option<f64>,
        top_p: Option<f64>,
        repeat_penalty: f32,
        repeat_last_n: usize,
        device: &Device,
    ) -> Self {
        let logits_processor = LogitsProcessor::new(seed, temp, top_p);
        Self {
            model,
            tokenizer: TokenOutputStream::new(tokenizer),
            logits_processor,
            repeat_penalty,
            repeat_last_n,
            device: device.clone(),
        }
    }

    fn run(&mut self, prompt: &str, sample_len: usize) -> anyhow::Result<String> {
        use std::io::Write;
        self.tokenizer.clear();
        let mut tokens = self
            .tokenizer
            .tokenizer()
            .encode(prompt, true)
            .map_err(E::msg)?
            .get_ids()
            .to_vec();
        for &t in tokens.iter() {
            if let Some(t) = self.tokenizer.next_token(t)? {
                print!("{t}")
            }
        }
        std::io::stdout().flush()?;
        println!("\n输出：");

        let mut output = String::new();
        let eos_token = match self.tokenizer.get_token("<|endoftext|>") {
            Some(token) => token,
            None => anyhow::bail!("cannot find the <|endoftext|> token"),
        };
        let eos_token2 = match self.tokenizer.get_token("<|im_end|>") {
            Some(token) => token,
            None => anyhow::bail!("cannot find the <|im_end|> token"),
        };
        for index in 0..sample_len {
            let context_size = if index > 0 { 1 } else { tokens.len() };
            let start_pos = tokens.len().saturating_sub(context_size);
            let ctxt = &tokens[start_pos..];
            let input = Tensor::new(ctxt, &self.device)?.unsqueeze(0)?;
            let logits = self.model.forward(&input, start_pos)?;
            let logits = logits.squeeze(0)?.squeeze(0)?.to_dtype(DType::F32)?;
            let logits = if self.repeat_penalty == 1. {
                logits
            } else {
                let start_at = tokens.len().saturating_sub(self.repeat_last_n);
                candle_transformers::utils::apply_repeat_penalty(
                    &logits,
                    self.repeat_penalty,
                    &tokens[start_at..],
                )?
            };

            let next_token = self.logits_processor.sample(&logits)?;
            tokens.push(next_token);
            if next_token == eos_token || next_token == eos_token2 {
                break;
            }
            if let Some(t) = self.tokenizer.next_token(next_token)? {
                output.push_str(t.as_str());
                print!("{}", t);
                std::io::stdout().flush()?;
            }
        }
        if let Some(rest) = self.tokenizer.decode_rest().map_err(E::msg)? {
            print!("{}", rest);
            std::io::stdout().flush()?;
            output.push_str(rest.as_str());
        }
        std::io::stdout().flush()?;
        Ok(output)
    }
}

fn prompt_internal(root: String, system: String, prompt: String) -> Result<String, E> {
    println!(
        "temp: {:.2} repeat-penalty: {:.2} repeat-last-n: {}",
        0., 1.1, 64,
    );
    println!("root: {root}");

    let start = std::time::Instant::now();
    let root = PathBuf::from_str(root.as_str())?;
    let tokenizer_filename = concat(&root, "tokenizer.json");
    let filenames = {
        let json_file = concat(&root, "model.safetensors.index.json");
        let json: serde_json::Value = serde_json::from_reader(&std::fs::File::open(json_file)?)
            .map_err(candle_core::Error::wrap)?;
        let weight_map = match json.get("weight_map") {
            Some(serde_json::Value::Object(map)) => map,
            _ => anyhow::bail!("bad model.safetensors.index.json"),
        };
        let mut safetensors_files = std::collections::HashSet::new();
        for value in weight_map.values() {
            if let Some(file) = value.as_str() {
                safetensors_files.insert(file.to_string());
            }
        }
        let safetensors_files = safetensors_files
            .iter()
            .map(|v| concat(&root, v))
            .collect::<Vec<_>>();
        safetensors_files
    };
    let tokenizer = Tokenizer::from_file(tokenizer_filename).map_err(E::msg)?;

    let config_file = concat(&root, "config.json");
    let device = if cuda_is_available() {
        Device::new_cuda(0).unwrap_or(Device::Cpu)
    } else if metal_is_available() {
        Device::new_metal(0).unwrap_or(Device::Cpu)
    } else {
        Device::Cpu
    };
    let dtype = DType::F32;
    let vb = unsafe { VarBuilder::from_mmaped_safetensors(&filenames, dtype, &device)? };
    let model = Model3::new(&serde_json::from_slice(&std::fs::read(config_file)?)?, vb)?;

    println!("loaded the model in {:?}", start.elapsed());

    let start_gen = std::time::Instant::now();
    let mut pipeline = TextGeneration::new(
        model,
        tokenizer,
        1145141919810,
        Some(0.),
        None,
        1.1,
        64,
        &device,
    );
    let result = pipeline.run(
        format!("<|im_start|>system\n{system}\n<|im_start|>user\n{prompt}\n<|im_end|>",).as_str(),
        10000,
    );
    println!("\ndone generation in {:?}", start_gen.elapsed());
    result
}

#[frb(sync)]
pub fn prompt(root: String, system: String, prompt: String) -> String {
    prompt_internal(root, system, prompt).unwrap()
}
