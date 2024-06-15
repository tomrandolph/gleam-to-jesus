import gleam/bool
import gleam/dict.{type Dict}
import gleam/io
import gleam/list
import gleam/queue.{type Queue}
import gleam/result
import gleam/set.{type Set}

/// Allows returning early with a default value (fallback)
/// Use with `use` expression to unwrap the Ok value of the result and use it
/// or return the fallback value if the result is an Error
///  ## Examples
/// ```gleam
/// use item <- default(dict.get(key), 0)
/// // item -> 10
/// item + 10
/// // returns 20 if  dict.get(key) is Ok(10) otherwise 0
/// ```
pub fn default(fallable: Result(a, e), fallback: b, mapper: fn(a) -> b) -> b {
  case fallable {
    Ok(a) -> mapper(a)
    Error(_) -> fallback
  }
}

pub fn in_case(
  fallable: Result(a, e),
  success: fn(a) -> b,
  otherwise: fn() -> b,
) -> b {
  case fallable {
    Ok(a) -> success(a)
    Error(_) -> otherwise()
  }
}

fn do_bfs(
  get_neighbors: fn(a) -> List(a),
  should_stop: fn(a) -> Bool,
  put_next: fn(Queue(a), a) -> Queue(a),
  q: Queue(a),
  l: List(a),
  visited: Set(a),
) -> List(a) {
  use #(node, q) <- default(queue.pop_front(q), list.reverse(l))
  io.debug(node)
  use <- bool.lazy_guard(set.contains(visited, node), fn() {
    do_bfs(get_neighbors, should_stop, put_next, q, l, visited)
  })

  let visited = set.insert(visited, node)

  let l = [node, ..l]
  let neighbors = get_neighbors(node)
  let stop_for = list.find(neighbors, should_stop)
  use <- in_case(stop_for, fn(a) { list.reverse([a, ..l]) })
  let q =
    list.filter(neighbors, fn(n) { !set.contains(visited, n) })
    |> list.fold(q, put_next)

  do_bfs(get_neighbors, should_stop, put_next, q, l, visited)
}

pub fn bfs(
  get_neighbors: fn(a) -> List(a),
  should_stop: fn(a) -> Bool,
  start: a,
) -> List(a) {
  let q = queue.from_list([start])
  let l = []
  let visited = set.new()

  do_bfs(get_neighbors, should_stop, queue.push_back, q, l, visited)
}

pub fn dfs(
  get_neighbors: fn(a) -> List(a),
  should_stop: fn(a) -> Bool,
  start: a,
) -> List(a) {
  let q = queue.from_list([start])
  let l = []
  let visited = set.new()

  do_bfs(get_neighbors, should_stop, queue.push_front, q, l, visited)
}
// fn do_dfs(
//   get_neighbors: fn(a) -> List(a),
//   should_stop: fn(a) -> Bool,
//   node: a,
//   l: List(a),
//   visited: Set(a),
// ) -> List(a) {
//   use <- bool.guard(set.contains(visited, node), l)
//   let visited = set.insert(visited, node)
//   let neighbors = get_neighbors(node)
//   let stop_for = list.find(neighbors, should_stop)
//   use <- in_case(stop_for, fn(a) { list.reverse([a, ..l]) })
//   let unvisited = list.filter(neighbors, fn(n) { !set.contains(visited, n) })
//   let l =
//     list.fold(unvisited, l, fn(n, l) {
//       do_dfs(get_neighbors, should_stop, n, l, visited)
//     })
//   l
// }
