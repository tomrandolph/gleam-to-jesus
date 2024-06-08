import gleam/bit_array
import gleam/dynamic
import gleam/erlang/os
import gleam/float
import gleam/hackney
import gleam/http
import gleam/http/request
import gleam/http/response.{Response}
import gleam/io
import gleam/json.{type DecodeError}
import gleam/list
import gleam/result

pub fn oai_embed(text: String) -> Result(List(Float), ExtractError) {
  // Prepare a HTTP request record

  let assert Ok(req) = request.to("https://api.openai.com/v1/embeddings")
  let assert Ok(key) = os.get_env("OPENAI_API_KEY")
  let body =
    json.object([
      #("input", json.string(text)),
      #("model", json.string("text-embedding-3-small")),
    ])
    |> json.to_string

  let req =
    request.prepend_header(req, "Content-Type", "application/json")
    |> request.prepend_header("Authorization", "Bearer " <> key)
    |> request.set_body(body)
    |> request.set_method(http.Post)

  let res = hackney.send(req)
  case res {
    Ok(response) -> {
      let Response(_, _, body: body) = response
      extract_embeddings(body)
    }
    Error(err) -> {
      io.debug(err)
      Ok([])
    }
  }
}

type EmbeddingObject {
  EmbeddingObject(embedding: List(Float))
}

type EmbeddingResponse {
  EmbeddingResponse(List(EmbeddingObject))
}

pub type ExtractError {
  NoEmbeddingsInList
  ExtractError(DecodeError)
}

pub fn extract_embeddings(json_str: String) -> Result(List(Float), ExtractError) {
  let decoded =
    json.decode(
      json_str,
      dynamic.decode1(
        EmbeddingResponse,
        dynamic.field(
          "data",
          dynamic.list(dynamic.decode1(
            EmbeddingObject,
            dynamic.field("embedding", dynamic.list(dynamic.float)),
          )),
        ),
      ),
    )
  case decoded {
    Ok(EmbeddingResponse(data)) -> {
      case list.first(data) {
        Ok(EmbeddingObject(embedding)) -> Ok(embedding)
        Error(_) -> {
          Error(NoEmbeddingsInList)
        }
      }
    }
    Error(e) -> {
      io.println("Decoding error")
      io.debug(e)
      Error(ExtractError(e))
    }
  }
}

/// Calculate the dot product of two vectors
pub fn dot_product(a: List(Float), b: List(Float)) -> Float {
  list.zip(a, b)
  |> list.map(fn(pair) { pair.0 *. pair.1 })
  |> float.sum
}

/// Calculate the l2 norm of a vector
pub fn norm(a: List(Float)) -> Float {
  let n =
    list.map(a, fn(a) { a *. a })
    |> float.sum
    |> float.square_root
  result.unwrap(n, 0.0)
}

/// Calculate the cosine similarity of two vectors
pub fn cosine_similarity(a: List(Float), b: List(Float)) -> Float {
  dot_product(a, b) /. norm(a) *. norm(b)
}

pub type InvalidBitArray {
  InvalidBitArray
}

pub fn bitarray_to_floats(
  bits: BitArray,
  floats: List(Float),
) -> Result(List(Float), InvalidBitArray) {
  case bits {
    <<>> -> {
      Ok(list.reverse(floats))
    }
    <<num:float-little-size(32), rest:bytes>> -> {
      // TODO optization: match number from back?
      bitarray_to_floats(rest, [num, ..floats])
    }
    _ -> {
      Error(InvalidBitArray)
    }
  }
}

pub type InvlalidBase64Floats {
  InvlalidBase64
  InvlalidBase64Floats(InvalidBitArray)
}

pub fn b64_to_floats(b64: String) -> Result(List(Float), InvlalidBase64Floats) {
  case bit_array.base64_decode(b64) {
    Ok(bits) ->
      result.map_error(bitarray_to_floats(bits, []), InvlalidBase64Floats)
    Error(Nil) -> Error(InvlalidBase64)
  }
}
