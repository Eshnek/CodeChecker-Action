# [CodeChecker](http://github.com/Ericsson/CodeChecker/) C++ static analysis action

GitHub Action to execute static analysis over C-family projects (C, C++,
Objective-C) using the [Clang](http://clang.llvm.org/) infrastructure and
[CodeChecker](http://github.com/Ericsson/CodeChecker/) as its driver.

## Overview

⚠️ **CAUTION! This action has been written with commands that target Ubuntu-based distributions!**

This single action composite script encompasses the following steps:

  1. Obtain a package of the LLVM Clang suite's analysers, and CodeChecker.
  2. _(Optional)_ Log the build commands to prepare for analysis.
  3. Execute the analysis.

ℹ️ **Note:** Static analysis can be a time-consuming process.
It's recommended that the static analysis step is not sequential with the rest of a CI execution, but either runs as its own job in a workflow, or a completely distinct workflow altogether.

Please ensure that your project is completely configured for a build before executing this action.

ℹ️ **Note:** Static analysers can rely on additional information that is optimised out in a true release build.
Hence, it's recommended to configure your project in a **`Debug`** configuration.

Add the job into your CI as follows.
The two versions are mutually exclusive &mdash; you either can give a compilation database, or you instruct CodeChecker to create one.

### Project can generate a [JSON Compilation Database](http://clang.llvm.org/docs/JSONCompilationDatabase.html) and build cleanly (no generated code)

Some projects are trivial enough in their build configuration that no additional steps need to be taken after executing `configure.sh`, `cmake`, or similar tools.
If you are able to generate a _compilation database_ from your build system **without** running the build itself, you can save some time, and go to the analysis immediately.

You can specify the generated compilation database in the `logfile` variable 

```yaml
runs:
  steps:
    # Check YOUR project out!
    - name: "Check out repository"
      uses: actions/checkout@v2

    # Prepare a build
    - name: "Prepare build"
      run: |
        mkdir -pv Build
        cd Build
        cmake .. -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON

    # Run the analysis
    - uses: whisperity/codechecker-analysis-action
      with:
        logfile: ${{ github.workspace }}/Build/compile_commands.json
```

### Projects that need to self-creating a *JSON Compilation Database* or require generated code

Other kinds of projects might rely heavily on _generated code_.
When looking at the source code of these projects **without** a build having been executed beforehand, they do not compile &mdash; as such, analysis cannot be executed either.

In this case, you will need to instruct CodeChecker to log a build (and spend time doing the build) just before analysis.

You can specify the build to execute in the `build-command` variable.

```yaml
runs:
  steps:
    # Check YOUR project out!
    - name: "Check out repository"
      uses: actions/checkout@v2

    # Prepare a build
    - name: "Prepare build"
      run: |
        mkdir -pv Build
        cd Build
        cmake .. -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=OFF

    # Run the analysis
    - uses: whisperity/codechecker-analysis-action
      with:
        build-command: "cd ${{ github.workspace }}/Build; cmake --build ."
```


## Action configuration

| Variable | Default                             | Description                                                                                                                                                                                                                                                                                                                                                  |
|----------|-------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `config` | `$(project-root)/.codechecker.json` | The configuration file containing flags to be appended to the analysis commands. It is recommended that most of the analysis configuration is versioned with the project. 🔖 Read more about the [`codechecker.json`](http://codechecker.readthedocs.io/en/latest/analyzer/user_guide/#configuration-file) configuration file in the official documentation. |

### Versions to install

| Variable       | Default                                                          | Description                                                                                                                                                                                                    |
|----------------|------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `repository`   | [`Ericsson/CodeChecker`](http://github.com/Ericsson/CodeChecker) | The CodeChecker repository to check out and build                                                                                                                                                              |
| `version`      | `master`                                                         | The branch, tag, or commit SHA in the `repository` to use.                                                                                                                                                     |
| `llvm-version` | `latest`                                                         | The major version of LLVM to install and use. LLVM is installed from [PPA](http://apt.llvm.org/). If `latest`, automatically gather the latest version. If `ignore`, don't install anything. (Not recommended) |

### Build log configuration

🔖 Read more about [`CodeChecker log`](http://codechecker.readthedocs.io/en/latest/analyzer/user_guide/#log) in the official documentation.

| Variable        | Default | Description                                                                                                                                                                                                                          |
|-----------------|---------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `logfile`       |         | The location of the JSON Compilation Database which describes how the project is built. This flag is used if the build system can pre-generate the file for us.                                                                      |
| `build-command` |         | The build command to execute. CodeChecker is capable of executing and logging the build for itself. This flag is used if the build-system can not generate the information by itself, or the project relies on other generated code. |

### Analysis configuration

🔖 Read more about [`CodeChecker analyze`](http://codechecker.readthedocs.io/en/latest/analyzer/user_guide/#analyze) in the official documentation.


| Variable         | Default          | Description                                                                                                                                                                                                                                                  |
|------------------|------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `analyze-output` | (auto-generated) | The directory where the **raw** analysis output should be stored.                                                                                                                                                                                            |
| `ctu`            | `false`          | Enable [Cross Translation Unit analysis](http://clang.llvm.org/docs/analyzer/user-docs/CrossTranslationUnit.html) in the _Clang Static Analyzer_. ⚠️ **CAUTION!** _CTU_ analysis might take a very long time, and CTU is officially regarded as experimental. |


## Action *`outputs`* to use in further steps

The action exposes the following outputs which may be used in a workflow's steps succeeding the analysis.

| Variable         | Value                                     | Description                                                          |
|------------------|-------------------------------------------|----------------------------------------------------------------------|
| `logfile`        | Auto-generated, or `logfile` input        | The JSON Compilation Database of the analysis that was executed.     |
| `analyze-output` | Auto-generated, or `analyze-output` input | The directory where the **raw** analysis output files are available. |