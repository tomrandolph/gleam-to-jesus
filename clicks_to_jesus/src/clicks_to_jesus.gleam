import gleam/erlang.{Eof, NoData}
import gleam/io
import gleam/list
import gleam/set.{type Set}
import gleam/string
import html

fn read_input(strs: List(String)) -> String {
  let input = erlang.get_line("")
  case input {
    Error(Eof) -> {
      io.println_error("EOF")
      list.reverse(strs) |> string.join("")
    }
    Error(NoData) -> {
      io.println_error("No Data")
      list.reverse(strs) |> string.join("")
    }
    Ok(chars) -> {
      read_input([chars, ..strs])
    }
  }
}

// fn bfs(links: List(String), visited: Set(String)) -> List(String) {
//   case links {
//     [] -> visited
//     [link, ..rest] -> {
//       if list.member(visited, link) {
//         bfs(rest, visited)
//       } else {
//         let new_links = html.find_internal_links(link)
//         bfs(rest ++ new_links, [link, ..visited])
//       }
//     }
//   }
// }

pub fn main() {
  read_input([])
  |> html.find_internal_links
  |> list.filter(string.starts_with(_, "/wiki/"))
  |> list.unique
  |> list.each(io.println)
}
