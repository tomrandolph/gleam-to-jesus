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

pub fn bfs(
  graph: Dict(a, List(a)),
  q: Queue(a),
  l: List(a),
  visited: Set(a),
) -> List(a) {
  case queue.pop_front(q) {
    Error(_) -> list.reverse(l)
    Ok(#(node, q)) -> {
      use <- bool.lazy_guard(set.contains(visited, node), fn() {
        bfs(graph, q, l, visited)
      })
      let visited = set.insert(visited, node)

      let l = [node, ..l]

      let q =
        result.map(dict.get(graph, node), fn(neighbors) {
          list.filter(neighbors, fn(n) { !set.contains(visited, n) })
          |> list.fold(q, queue.push_back)
        })
        |> result.unwrap(q)

      bfs(graph, q, l, visited)
    }
  }
}
