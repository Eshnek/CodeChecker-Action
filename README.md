# [CodeChecker](http://github.com/Ericsson/CodeChecker/) C++ static analysis action

GitHub Action to execute static analysis over C-family projects (C, C++,
Objective-C) using the [Clang](http://clang.llvm.org/) infrastructure and
[CodeChecker](http://github.com/Ericsson/CodeChecker/) as its driver.

## Overview

:warning: **This action has been written with commands that target Ubuntu-based distributions!**

## Action configuration

### Installing versions

| Variable     | Default                                                          | Description                                                |
|--------------|------------------------------------------------------------------|
| `repository` | [`Ericsson/CodeChecker`](http://github.com/Ericsson/CodeChecker) | The CodeChecker repository to check out and build          |
| `version`    | `master`                                                         | The branch, tag, or commit SHA in the `repository` to use. |

