import birl
import birl/duration
import gleam/int
import gleam/io
import gleam/list
import gleam/result

pub fn time(msg: String, do: fn() -> a) -> a {
  let now = birl.now()

  let res = do()
  let duration = birl.difference(birl.now(), now)
  io.print("[" <> msg <> "]" <> ": ")
  let time =
    result.unwrap(list.first(duration.decompose(duration)), #(
      0,
      duration.MilliSecond,
    ))
  io.print(int.to_string(time.0))
  io.print(" ")
  io.debug(time.1)

  res
}
