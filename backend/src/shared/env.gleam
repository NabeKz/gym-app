import gleam/dynamic
import gleam/dynamic/decode
import gleam/result

@external(erlang, "os", "getenv")
fn do_getenv(key: String) -> dynamic.Dynamic

pub fn get(key: String) -> Result(String, Nil) {
  do_getenv(key)
  |> decode.run(decode.string)
  |> result.replace_error(Nil)
}
