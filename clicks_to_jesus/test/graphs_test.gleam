import gleam/dict
import gleam/queue
import gleam/set
import gleeunit
import gleeunit/should
import graphs

pub fn main() {
  gleeunit.main()
}

pub fn bfs_test() {
  let g =
    dict.new()
    |> dict.insert(0, [1, 2])
    |> dict.insert(1, [2])
    |> dict.insert(2, [3])
    |> dict.insert(3, [1])
  let q = queue.new() |> queue.push_front(0)
  let l = []
  let v = set.new()
  let l = graphs.bfs(g, q, l, v)
  should.equal(l, [0, 1, 2, 3])
}
