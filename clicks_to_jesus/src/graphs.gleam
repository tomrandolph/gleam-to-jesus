import gleam/dict.{type Dict}
import gleam/io
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
      case set.contains(visited, node) {
        True -> bfs(graph, q, l, visited)
        False -> {
          let visited = set.insert(visited, node)
          let l = [node, ..l]
          io.debug(node)
          case dict.get(graph, node) {
            Ok(neighbors) -> {
              io.debug(neighbors)
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
      }
    }
    Error(_) -> list.reverse(l)
  }
}
