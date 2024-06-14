import gleam/bool
import gleam/dict.{type Dict}
import gleam/list
import gleam/queue.{type Queue}
import gleam/set.{type Set}

pub fn bfs(
  graph: Dict(a, List(a)),
  q: Queue(a),
  l: List(a),
  visited: Set(a),
) -> List(a) {
  case queue.pop_front(q) {
    Ok(#(node, q)) -> {
      use <- bool.lazy_guard(set.contains(visited, node), fn() {
        bfs(graph, q, l, visited)
      })
      let visited = set.insert(visited, node)

      let l = [node, ..l]

      case dict.get(graph, node) {
        Ok(neighbors) -> {
          let q =
            list.filter(neighbors, fn(n) { !set.contains(visited, n) })
            |> list.fold(q, fn(q, i) { queue.push_back(q, i) })
          bfs(graph, q, l, visited)
        }
        Error(_) -> {
          bfs(graph, q, l, visited)
        }
      }
    }
    Error(_) -> list.reverse(l)
  }
}
