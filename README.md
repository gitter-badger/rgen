[![Gem Version](https://badge.fury.io/rb/rggen.svg)](https://badge.fury.io/rb/rggen)
[![Build Status](https://travis-ci.org/taichi-ishitani/rggen.svg?branch=master)](https://travis-ci.org/taichi-ishitani/rggen)
[![Code Climate](https://codeclimate.com/github/taichi-ishitani/rggen/badges/gpa.svg)](https://codeclimate.com/github/taichi-ishitani/rggen)
[![Test Coverage](https://codeclimate.com/github/taichi-ishitani/rggen/badges/coverage.svg)](https://codeclimate.com/github/taichi-ishitani/rggen/coverage)

# RgGen

[![Join the chat at https://gitter.im/taichi-ishitani/rggen](https://badges.gitter.im/taichi-ishitani/rggen.svg)](https://gitter.im/taichi-ishitani/rggen?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

RgGen is a code generation tool for SoC designers.
It will automatically generate source code for control registers in a SoC design, e.g. RTL, UVM RAL model, from its register map document.
Also RgGen is customizable so you can build your specific generate tool.

## Ruby

RgGen is written in the [*Ruby*](https://www.ruby-lang.org/en/about/) programing language and supports version 2.0 or later.
If you don't have above version of Ruby, you need to install the Ruby at first.
To install the Ruby, see [this page](https://www.ruby-lang.org/en/downloads/).

## Installation

To install RgGen and required libraries, use the following command:

    $ gem install rggen

RgGen will be installed under your system root.

If you want to install them on other location, you need to specify the install directory and set the **GEM_PATH** environment variable like below:

    $ gem install --install-dir YOUR_INSTALL_DIRECTORY rggen
    $ export GEM_PATH=YOUR_INSTALL_DIRECTORY

## Usage

### Writing Configuration File

A configuration file is to describe attributes of your design, e.g. data bus width, address bus width, host interface protocol.
RgGen supports YAML and JSON for its file format and allows to use Hash notation to describe attributes of your design like below.

- YAML
~~~YAML
address_width: 16
data_width: 32
host_if: apb
~~~
- JSON
~~~JSON
{
  "address_width": 16,
  "data_width": 32,
  "host_if": "apb"
}
~~~

These attributes have default values. If you use a default value, you don't specify its value.
In addition, if you use default values for all of attributes, you don't need to write a configuration file.

### Writing Register Map Document

RgGen allows to use a spreadsheet to input the register map of your design so you can directly input your register map document to RgGen.
To do this, you need to write your register map document according to below table format.

|    |A   |B             |C            |D              |E                                |F             |G         |H   |I           |
|:---|:---|:-------------|:------------|:--------------|:--------------------------------|:-------------|:---------|:---|:-----------|
|1   |    |Block Name    |block_0      |               |                                 |              |          |    |            |
|2   |    |Byte Size     |256          |               |                                 |              |          |    |            |
|3   |    |              |             |               |                                 |              |          |    |            |
|4   |    |Offset Address|Register Name|Array Dimension|Shadow Index                     |Bit Assignment|Field Name|Type|Iitial Value|
|5   |    |0x00          |register_0   |               |                                 |[31:16]       |field_0_0 |rw  |0           |
|6   |    |              |             |               |                                 |[15:0]        |field_0_1 |rw  |0           |
|7   |    |0x04          |register_1   |               |                                 |[16]          |field_1_0 |rw  |0           |
|8   |    |              |             |               |                                 |[0]           |field_1_1 |ro  |            |
|9   |    |0x10 - 0x1F   |register_2   |[4]            |                                 |[7:0]         |field_2_0 |rw  |0           |
|10  |    |0x20          |register_3   |[2, 4]         |field_1_0:1, field_0_0, field_0_1|[7:0]         |field_3_0 |rw  |0           |

By default, RgGen supports CSV, ODS, XLS and XLSX sparedsheet file types.

### Generating Source Code

To generate soruce code from your register map document, use the following command:

    $ rggen your_register_map.xls

If you have a configuration file, you need to use `-c/--configuration` option:

    $ rggen -c your_configuration.yml your_register_map.xls

By default, RgGen will generate RTL SV code under `rtl` directory and UVM RAL model under `ral` dicrectory.
In addition, file name of generated files is accoding to below rule.
- RTL
  - `your_block_name`.sv
- RAL model
  - `your_block_name`_ral_pkg.sv

### Compiling Your Design

RgGen has base RTL modules and RAL model package (the base library) to build generated RTL and UVM RAL models.
Therefore, to compile your design with the base library, you need followins steps:

1. Set the RGGEN_HOME environment variable
2. Link the base library with you design

**RGGEN_HOME** environement variable is to show the install direcoty.
To set the variable, you can use `--show-home` option like below:

    $ export RGGEN_HOME=`rggen --show-home`

To link the base library with your design, RgGen has file lists for the base library.
By using the lists, you can compile your design and the base library like below:

    $ simulator \
      -f $RGGEN_HOME/rtl/compile.f \
      -f $RGGEN_HOME/ral/compile.f \
      rtl/your_register_block.sv \
      ral/your_register_block_ral_pkg.sv \
      your_test_bench.sv \
      your_design.v

### Note

Contents of configuration file and register map document and structure of genrerated RTL and RAL model described above are default.
Also you can change these by customizing RgGen.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/taichi-ishitani/rggen. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

Copyright &copy; 2015-2016 [Taichi Ishitani](mailto:taichi730@gmail.com).
RgGen is available as open source under the terms of the [MIT License](LICENSE.txt).
