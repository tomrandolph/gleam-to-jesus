import gleam/bool
import gleam/dict.{type Dict}
import gleam/list
import gleam/queue.{type Queue}
import gleam/result
import gleam/set.{type Set}

pub fn default(fallable: Result(a, e), fallback: b, mapper: fn(a) -> b) -> b {
  case fallable {
    Ok(a) -> mapper(a)
    Error(_) -> fallback
  }
}

fn do_bfs(
  graph: Dict(a, List(a)),
  q: Queue(a),
  l: List(a),
  visited: Set(a),
) -> List(a) {
  use #(node, q) <- default(queue.pop_front(q), list.reverse(l))
  use <- bool.lazy_guard(set.contains(visited, node), fn() {
    do_bfs(graph, q, l, visited)
  })

  let visited = set.insert(visited, node)

  let l = [node, ..l]

  let q =
    result.unwrap(dict.get(graph, node), [])
    |> list.filter(fn(n) { !set.contains(visited, n) })
    |> list.fold(q, queue.push_back)

  do_bfs(graph, q, l, visited)
}

pub fn bfs(graph: Dict(a, List(a)), start: a) -> List(a) {
  let q = queue.from_list([start])
  let l = []
  let visited = set.new()

  do_bfs(graph, q, l, visited)
}
