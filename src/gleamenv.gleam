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

fn get_specific(envs: List(String), print: fn(String) -> Nil) -> Nil {
  let vars = envs |> list.filter_map(envoy.get)

  let exit_code = case list.length(vars) == list.length(envs) {
    True -> exit_success
    False -> exit_failure
  }

  vars |> list.each(print)
  shellout.exit(exit_code)
}

fn get_all(print: fn(String) -> Nil) -> Nil {
  envoy.all() |> dict.each(fn(key, value) {
    let item = key <> "=" <> value
    item |> print
  })
}

fn print_env(args: List(String), print_null: Bool) -> Nil {
  let print = case print_null {
    True -> io.print
    False -> io.println
  }

  case args {
    [] -> get_all(print)
    _ -> get_specific(args, print)
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

