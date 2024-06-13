import gleeunit
import gleeunit/should
import html

pub fn main() {
  gleeunit.main()
}

pub fn lex_attribute_name_test() {
  html.lex_attribute_name("", "foo") |> should.equal(#("foo", ""))
  html.lex_attribute_name("", "data-foo") |> should.equal(#("data-foo", ""))
  html.lex_attribute_name("", "foo=\"asdf\"")
  |> should.equal(#("foo", "=\"asdf\""))
  html.lex_attribute_name("", "foo-data=\"asdf\"")
  |> should.equal(#("foo-data", "=\"asdf\""))
  html.lex_attribute_name("", "foo-data=\"asdf\"")
  |> should.equal(#("foo-data", "=\"asdf\""))
  html.lex_attribute_name("", "=\"asdf\"")
  |> should.equal(#("", "=\"asdf\""))
}

pub fn find_internal_links_test() {
  let text = "<a href=\"http://example.com\">example</a>"

  html.find_internal_links(text) |> should.equal([])
  let text = "<a href=\"/foo\">example</a>"

  html.find_internal_links(text) |> should.equal(["/foo"])

  let text = "<a hidden href=\"/foo\" title=\"example\">example</a>"

  html.find_internal_links(text) |> should.equal(["/foo"])

  let text =
    "<a hidden href=\"/foo\" title=\"example\">example</a><a href=\"/bar\">example</a>"
  html.find_internal_links(text) |> should.equal(["/foo", "/bar"])
}
