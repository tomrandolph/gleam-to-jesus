import gleam/dict
import gleam/result
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
  let get_neighbors = fn(a) { result.unwrap(dict.get(g, a), []) }
  let l = graphs.bfs(get_neighbors, 0)
  should.equal(l, [0, 1, 2, 3])
}
