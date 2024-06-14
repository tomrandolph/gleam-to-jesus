import argv
import gleam/erlang.{Eof, NoData}
import gleam/hackney
import gleam/http/request
import gleam/http/response.{Response}
import gleam/io
import gleam/list
import gleam/result
import gleam/set.{type Set}
import gleam/string
import gleam/uri
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

fn fetch_html(link: String) {
  use req <- result.try(request.to(link))
  case hackney.send(req) {
    Error(_) -> {
      io.println_error("Failed to fetch link")
      Error(Nil)
    }
    Ok(Response(_, _, body)) -> Ok(body)
  }
}

pub fn main() {
  let assert Ok(base) = uri.parse("https://en.wikipedia.org")
  case argv.load().arguments {
    [link] -> {
      use text <- result.try(fetch_html(link))
      let links =
        list.map(html.find_internal_links(text), fn(l) {
          use path <- result.try(uri.parse(l))
          uri.merge(base, path)
        })
        |> result.values
      io.debug(list.map(links, uri.to_string))
      Ok(Nil)
    }
    _ -> {
      io.println_error("Usage: gleam run <link>")
      Error(Nil)
    }
  }
}
