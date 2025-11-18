# msdf-atlas-gen-builder
This repository uses [Github Actions](./actions) to self-build Viktor Chlumský's [msdf-atlas-gen](https://github.com/Chlumsky/msdf-atlas-gen) upon triggering a workflow.

_This work is unofficial_. If you are new to **msdf-atlas-gen**, please refer to [the official distribution](https://github.com/Chlumsky/msdf-atlas-gen/releases) (never download any software that you haven't built yourself or fetched from an official source).

## Why?
This repository does a few things differently than the official distribution to better serve the specific needs of Flying Oak Games' projects.

It mainly generates binaries that are not officially distributed, and builds them in a fashion that dependencies are minimal (this repository can be built offline with no need of a package manager).

## How to use
You can either fork/download the repository and run ```./build.ps1``` (the binaries will be output in the ```./binaries``` folder), or fork and trigger a manual [Github Actions workflow run](./actions) (the binaries will be available in the run artifacts once completed).

## Requirements

- A valid Visual Studio installation with the C++ development workload;
- PowerShell;
- CMake 3.15 (or newer) accessible from PATH.

## Generated binaries

The following binaries will be generated for ```Windows x64```:

- The standalone msdf-atlas-gen executable, with the VCRuntime statically linked (and no Skia support);
- The dynamic msdf-atlas-gen library, with the VCRuntime statically linked (and no Skia support);
- The static msdf-atlas-gen library, with the VCRuntime statically linked (and no Skia support).

## To do

- Better logging;
- make a msdf-atlas-gen branch with local forks only
- Generating ```macOS ARM64``` and ```Linux x64``` binaries.
