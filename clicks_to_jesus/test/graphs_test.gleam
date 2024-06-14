import gleam/dict
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
  let l = graphs.bfs(g, 0)
  should.equal(l, [0, 1, 2, 3])
}
