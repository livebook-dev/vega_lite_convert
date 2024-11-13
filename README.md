# VegaLite.Convert

[![Actions
Status](https://github.com/livebook-dev/vega_lite_convert/workflows/Test/badge.svg)](https://github.com/livebook-dev/vega_lite_convert/actions)
[![Docs](https://img.shields.io/badge/docs-gray.svg)](https://hexdocs.pm/vega_lite_convert)

Elixir bindings to the Rust library [vl-convert](https://github.com/vega/vl-convert).

You can use this library to generate PNGs, PDFs, SVGs, etc from [VegaLite](https://github.com/livebook-dev/vega_lite) specifications.

## Installation

You can add the `:vega_lite_convert` dependency to your `mix.exs`:

```elixir
def deps do
  [
    {:vega_lite_convert, "~> 0.1.0"}
  ]
end
```

## License

Copyright (C) 2024 Dashbit

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at [http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
