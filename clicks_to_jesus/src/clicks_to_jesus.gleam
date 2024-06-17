import argv
import embed
import gleam/erlang.{Eof, NoData}
import gleam/float
import gleam/hackney
import gleam/http/request
import gleam/http/response.{Response}
import gleam/int
import gleam/io
import gleam/list
import gleam/otp/task
import gleam/result
import gleam/string
import gleam/uri
import graphs
import html
import timing

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

fn fetch_html(link: uri.Uri) {
  use req <- result.try(request.from_uri(link))
  use <- timing.time("fetch_html")
  case hackney.send(req) {
    Error(_) -> {
      io.println_error("Failed to fetch link")
      Error(Nil)
    }
    Ok(Response(200, _, body)) -> Ok(body)
    Ok(Response(status, _, _)) -> {
      io.println_error("Bad status code " <> int.to_string(status))
      Error(Nil)
    }
  }
}

fn batch_embed(topics: List(String)) -> Result(List(Result(List(Float), _)), _) {
  let chunks = list.sized_chunk(topics, 100)
  let tasks =
    list.map(chunks, fn(chunk) {
      task.async(fn() { result.unwrap(embed.oai_embed(chunk), []) })
    })
  case list.try_map(tasks, task.try_await(_, 3000)) {
    Ok(embeddings) -> Ok(list.flatten(embeddings))
    Error(a) -> {
      io.print_error("embed failed")
      io.debug(a)
      Error(Nil)
    }
  }
}

fn refine_links(links: List(String)) -> List(String) {
  list.unique(links)
  |> list.filter(string.starts_with(_, "/wiki/"))
  |> list.filter(fn(l) { !string.contains(l, ":") })
  |> list.filter(fn(l) { !string.contains(l, "Main_Page") })
}

pub fn main() {
  let assert Ok(jesus_page) = uri.parse("https://en.wikipedia.org/wiki/Jesus")
  let assert Ok(jesus_christ_page) =
    uri.parse("https://en.wikipedia.org/wiki/Jesus_Christ")
  let assert Ok(base) = uri.parse("https://en.wikipedia.org")
  let assert Ok([Ok(jesus_embed)]) = embed.oai_embed(["Jesus"])
  case argv.load().arguments {
    ["bfs", link] -> {
      use start <- result.try(uri.parse(link))

      let get_neighbors = fn(link: uri.Uri) {
        case fetch_html(link) {
          Error(_) -> []
          Ok(body) -> {
            let links =
              html.find_internal_links(body)
              |> refine_links
              |> list.map(fn(l) {
                use path <- result.try(uri.parse(l))
                uri.merge(base, path)
              })
            result.values(links)
          }
        }
      }
      graphs.bfs(
        get_neighbors,
        fn(a) { a == jesus_page || a == jesus_christ_page },
        start,
      )
      |> list.map(fn(a) { a.path })
      |> io.debug
      |> list.length
      |> io.debug
      Ok(Nil)
    }
    ["dfs", link] -> {
      use start <- result.try(uri.parse(link))

      let get_neighbors = fn(link: uri.Uri) {
        case fetch_html(link) {
          Error(_) -> []
          Ok(body) -> {
            let links =
              html.find_internal_links(body)
              |> refine_links

            let topics = list.map(links, string.drop_left(_, 6))

            let embeddings = result.unwrap(batch_embed(topics), [])
            let similarities =
              list.map(embeddings, fn(e) {
                case e {
                  Ok(v) -> embed.cosine_similarity(jesus_embed, v)
                  Error(_) -> 0.0
                }
              })
            let sorted =
              list.sort(list.zip(links, similarities), fn(a, b) {
                float.compare(b.1, a.1)
              })

            let links =
              sorted
              |> list.map(fn(l) {
                use path <- result.try(uri.parse(l.0))
                uri.merge(base, path)
              })

            result.values(links)
          }
        }
      }
      graphs.dfs(
        get_neighbors,
        fn(a) { a == jesus_page || a == jesus_christ_page },
        start,
      )
      |> list.map(fn(a) { a.path })
      |> io.debug
      |> list.length
      |> io.debug
      Ok(Nil)
    }
    _ -> {
      io.println_error("Usage: gleam run (bfs|dfs) <link>")
      Error(Nil)
    }
  }
}
