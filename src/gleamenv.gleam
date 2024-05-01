import argv
import envoy
import gleam/dict
import gleam/list
import gleam/io
import shellout

const exit_success = 0
const exit_failure = 1
const version = "1.0.0"
const usage = "Usage: gleamenv [OPTION]... [VARIABLE]...
Print the values of the specified environment VARIABLE(s).
If no VARIABLE is specified, print name and value pairs for them all.

      --null     End each output line with NUL, not newline
      --help     Display this help and exit
      --version  Output version information and exit"

fn print_list(envs: List(String), print_null: Bool) -> Nil {
  let print = case print_null {
    True -> io.print
    False -> io.println
  }

  envs |> list.each(print)
}

fn get_specific(envs: List(String), print_null: Bool) -> Nil {
  let vars = envs
    |> list.filter_map(envoy.get)

  vars |> print_list(print_null)

  let exit_code = case list.length(vars) == list.length(envs) {
    True -> exit_success
    False -> exit_failure
  }

  shellout.exit(exit_code)
}

fn format_pair(pair: #(String, String)) -> String {
  pair.0 <> "=" <> pair.1
}

fn get_all(print_null: Bool) -> Nil {
  envoy.all() 
    |> dict.to_list() 
    |> list.map(format_pair)
    |> print_list(print_null)
}

fn print_env(args: List(String), print_null: Bool) -> Nil {
  case args {
    [] -> get_all(print_null)
    _ -> get_specific(args, print_null)
  }
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

