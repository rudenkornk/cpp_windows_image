conan config init

@("msvc") | ForEach-Object {
  yq "with(.compiler.[\`"$_\`"].address_sanitizer; . = [\`"None\`", True] | . style=\`"flow\`")"  -i $HOME/.conan/settings.yml
}

@("Visual Studio", "apple-clang", "clang", "gcc") | ForEach-Object {
  yq "with(.compiler.[\`"$_\`"].address_sanitizer; . = [\`"None\`", True] | . style=\`"flow\`")"  -i $HOME/.conan/settings.yml
  yq "with(.compiler.[\`"$_\`"].thread_sanitizer; . = [\`"None\`", True] | . style=\`"flow\`")"  -i $HOME/.conan/settings.yml
  yq "with(.compiler.[\`"$_\`"].ub_sanitizer; . = [\`"None\`", True] | . style=\`"flow\`")"  -i $HOME/.conan/settings.yml
}

