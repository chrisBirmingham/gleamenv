import argv
import envoy
import gleam/dict
import gleam/list
import gleam/io
import gleam/result
import gleam/string

const version = "1.0.0"
const usage = "Usage: gleamenv [OPTION]... [VARIABLE]...
Print the values of the specified environment VARIABLE(s).
If no VARIABLE is specified, print name and value pairs for them all.

      --null     End each output line with NUL, not newline
      --help     Display this help and exit
      --version  Output version information and exit"

fn get_env(env: String) -> String {
  envoy.get(env)
    |> result.unwrap("")
}

fn get_specific(envs: List(String)) -> List(String) {
  envs
    |> list.map(get_env)
    |> list.filter(fn(n) { !string.is_empty(n) })
}

fn format_pair(pair: #(String, String)) -> String {
  pair.0 <> "=" <> pair.1
}

fn get_all() -> List(String) {
  envoy.all() 
    |> dict.to_list() 
    |> list.map(format_pair)
}

fn print_env(args: List(String), print_null: Bool) -> Nil {
  let res = case args {
    [] -> get_all()
    _ -> get_specific(args)
  }

  let newline = case print_null {
    True -> ""
    False -> "\n"
  }

  let res = string.join(res, newline) <> newline
  io.print(res)
}

pub fn main() {
  let args = argv.load().arguments
  
  case args {
    ["--help", ..] -> io.println(usage)
    ["--version", ..] -> io.println(version)
    ["--null", ..tail] -> print_env(tail, True)
    _ -> print_env(args, False)
  }
}

