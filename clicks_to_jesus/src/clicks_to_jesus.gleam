import argv
import embed
import gleam/dict
import gleam/float
import gleam/io
import gleam/list
import gleam/result

fn compare_words(
  a: String,
  b: String,
  embeddings: dict.Dict(String, Result(List(Float), c)),
) -> Result(Float, String) {
  case dict.get(embeddings, a), dict.get(embeddings, b) {
    Ok(Ok(a)), Ok(Ok(b)) -> {
      Ok(embed.cosine_similarity(a, b))
    }
    Ok(Error(_)), _ -> Error("Failed to embed " <> a)
    _, Ok(Error(_)) -> Error("Failed to embed " <> b)
    Error(_), _ -> Error("Could not find embedding for " <> a)
    _, Error(_) -> Error("Could not find embedding for " <> b)
  }
}

fn print_comparision(
  a: String,
  b: String,
  embeddings: dict.Dict(String, Result(List(Float), a)),
) {
  case compare_words(a, b, embeddings) {
    Ok(c) -> io.println(a <> " <> " <> b <> ": " <> float.to_string(c))

    Error(e) ->
      io.println("Failed to compare " <> a <> " and " <> b <> ": " <> e)
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
  let args = argv.load().arguments
  let #(words, combos) = case args {
    ["--with", one_word, ..words] -> {
      #([one_word, ..words], list.map(words, fn(word) { #(one_word, word) }))
    }
    words -> #(words, list.combination_pairs(words))
  }
  // is nlogn, what is converting to a dict
  let unique_words = list.unique(words)
  let lookup =
    result.map(embed.oai_embed(unique_words), fn(e) {
      list.zip(unique_words, e) |> dict.from_list
    })
  case lookup {
    Ok(embeddings) ->
      list.each(combos, fn(combo) {
        print_comparision(combo.0, combo.1, embeddings)
      })
    Error(e) -> {
      io.print("Failed to embed words: ")
      io.debug(e)
      io.println("")
    }
  }
}
