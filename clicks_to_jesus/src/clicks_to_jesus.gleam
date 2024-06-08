import argv
import embed
import gleam/dynamic
import gleam/float
import gleam/io
import gleam/json
import gleam/list
import gleam/result

fn compare_words(a: String, b: String) -> Result(Float, String) {
  case embed.oai_embed([a, b]) {
    Ok([Ok(c), Ok(d)]) -> {
      Ok(embed.cosine_similarity(c, d))
    }
    Error(_) -> Error("Failed to decode json")
    Ok([Error(_), _]) -> Error("Failed to embed" <> a)
    Ok([_, Error(_)]) -> Error("Failed to embed" <> b)
    _ -> Error("Failed to embed?")
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

fn n_times(n: Int, func: fn() -> b) -> b {
  case n {
    0 -> func()
    _ -> {
      n_times(n - 1, func)
      func()
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
