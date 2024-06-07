import argv
import embed
import gleam/float
import gleam/io
import gleam/list
import gleam/result

fn compare_words(a: String, b: String) -> Result(Float, String) {
  case embed.oai_embed(a), embed.oai_embed(b) {
    Ok(a), Ok(b) -> {
      Ok(embed.cosine_similarity(a, b))
    }
    Error(_), _ -> Error("Failed to embed" <> a)
    _, Error(_) -> Error("Failed to embed" <> b)
  }
}

type ComparisonResult

fn print_comparision(a: String, b: String) {
  case compare_words(a, b) {
    Ok(c) -> {
      io.print(a)
      io.print(" <> ")
      io.print(b)
      io.print(": ")
      io.print(float.to_string(c))
      io.print("\n")
    }
    Error(e) -> {
      io.print("Failed to compare ")
      io.print(a)
      io.print(" and ")
      io.print(b)
      io.print(": ")
      io.print(e)
      io.print("\n")
    }
  }
}

pub fn main() {
  case argv.load().arguments {
    ["--with", one_word, ..words] -> {
      list.map(words, fn(w) { print_comparision(one_word, w) })
    }
    words -> {
      list.combination_pairs(words)
      |> list.map(fn(a) { print_comparision(a.0, a.1) })
    }
  }
}
