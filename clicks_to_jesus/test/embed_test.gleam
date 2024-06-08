import embed.{NoEmbeddingsInList}

// import gleam/json.{DecodeError}
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn dot_product_test() {
  embed.dot_product([1.0, 2.0, 3.0], [4.0, 5.0, 6.0])
  |> should.equal(32.0)
  embed.dot_product([1.0, 2.0, 3.0], [1.0, 2.0, 3.0])
  |> should.equal(14.0)
}

pub fn norm_test() {
  embed.norm([1.0, 2.0, 3.0])
  |> should.equal(3.7416573867739413)
  embed.norm([1.0, 2.0, 3.0, 4.0])
  |> should.equal(5.477225575051661)
}

pub fn cosine_similarity() {
  embed.cosine_similarity([1.0, 2.0, 3.0], [4.0, 5.0, 6.0])
  |> should.equal(0.9746318461970762)
  embed.cosine_similarity([1.0, 2.0, 3.0], [1.0, 2.0, 3.0])
  |> should.equal(1.0)
}

pub fn extract_embeddings_test() {
  let json_str =
    "{
        \"object\": \"list\",
        \"data\": [
            {
            \"object\": \"embedding\",
            \"embedding\": [1.0, 2.0, 3.0]
            }
        ]
    }"

  embed.extract_embeddings(json_str)
  |> should.equal(Ok([1.0, 2.0, 3.0]))

  let json_str =
    "{
        \"object\": \"list\",
        \"data\": []
    }"

  embed.extract_embeddings(json_str)
  |> should.equal(Error(NoEmbeddingsInList))
  let json_str =
    "{
        \"object\": \"list\"
    }"

  embed.extract_embeddings(json_str)
  |> should.be_error
  // Decode Error TODO how to precisely test?
}

pub fn b64_to_floats_test() {
  embed.b64_to_floats("AQID")
  |> should.equal(Error(embed.InvlalidBase64Floats(embed.InvalidBitArray)))
  embed.b64_to_floats("AAAAQgAAKEI=")
  |> should.equal(Ok([32.0, 42.0]))
}

pub fn bittarray_to_floats_test() {
  embed.bitarray_to_floats(<<42.0:float-little-size(32)>>, [])
  |> should.equal(Ok([42.0]))

  embed.bitarray_to_floats(
    <<42.0:float-little-size(32), 69.0:float-little-size(32)>>,
    [],
  )
  |> should.equal(Ok([42.0, 69.0]))

  embed.bitarray_to_floats(<<42.0:float-little-size(16)>>, [])
  |> should.equal(Error(embed.InvalidBitArray))

  embed.bitarray_to_floats(
    <<
      42.0:float-little-size(16), 42.0:float-little-size(32),
      69.0:float-little-size(32),
    >>,
    [],
  )
  |> should.equal(Error(embed.InvalidBitArray))
}
