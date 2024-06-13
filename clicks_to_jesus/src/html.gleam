import gleam/list
import gleam/option.{type Option, Some}
import gleam/regex
import gleam/result
import gleam/string

pub type Link {
  Link(href: String, title: Option(String), text: String)
}

pub type LexerTokens {
  BeginOpenTag
  EndTag
  ClosingTag
  Space
  // ?
  AttrubuteName(String)
  AttributeValue(String)
  AttributeAssign
  Text(String)
}

pub fn lex_attribute_name(name: String, html: String) -> #(String, String) {
  let assert Ok(re) = regex.from_string("[a-zA-Z0-9-]")
  let c = result.unwrap(string.first(html), "")
  case regex.check(re, c) {
    True -> {
      lex_attribute_name(name <> c, string.drop_left(html, 1))
    }
    False -> {
      #(name, html)
    }
  }
}

// pub fn lex_anchors(
//   html: String,
//   tokens: List(LexerTokens),
//   i: Int,
// ) -> Result(List(LexerTokens), Int) {
//   case html {
//     "" -> Ok(tokens)
//     " " <> rest -> {
//       lex_anchors(rest, tokens, i + 1)
//     }
//     "<a" <> rest -> {
//       lex_anchors(rest, [BeginOpenTag, ..tokens], i + 1)
//     }
//     ">" <> rest -> {
//       lex_anchors(rest, [EndTag, ..tokens], i + 1)
//     }
//     "</a>" <> rest -> {
//       lex_anchors(rest, [ClosingTag, ..tokens], i + 1)
//     }
//     _ -> {
//       case list.first(tokens) {
//         Ok(BeginOpenTag) -> {
//           let #(attritbute_name, rest) = lex_attribute_name("", html)
//           lex_anchors(rest, [AttrubuteName(attritbute_name), ..tokens], i + 1)
//         }
//       }
//     }
//   }
// }
// fn parse_link(html: String) -> Link {
//   let assert Ok(href_re) = regex.from_string("<a href=\"([^\"]+)\"")
//   let href = regex.scan("<a href=\"([^\"]+)\"", html)
//   // |> regex.find_first("<a href=\"([^\"]+)\"")

//   // |> regex.find_first("title=\"([^\"]+)\"")

//   // |> regex.find_first(">([^<]+)</a>")

//   Link(href, title, text)
// }
pub fn find_internal_links(html_content: String) -> List(String) {
  let assert Ok(re) = regex.from_string("href=\"(/[^/][^\"]+)\"")

  regex.scan(re, html_content)
  |> list.map(fn(m) {
    option.unwrap(result.unwrap(list.first(m.submatches), Some("")), "")
  })
  |> list.filter(fn(str) { !string.is_empty(str) })
}
