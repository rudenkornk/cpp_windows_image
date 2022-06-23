conan config init

@("msvc") | ForEach-Object {
  yq "with(.compiler.[\`"$_\`"].address_sanitizer; . = [\`"None\`", True] | . style=\`"flow\`")"  -i $HOME/.conan/settings.yml
}

@("Visual Studio", "apple-clang", "clang", "gcc") | ForEach-Object {
  yq "with(.compiler.[\`"$_\`"].address_sanitizer; . = [\`"None\`", True] | . style=\`"flow\`")"  -i $HOME/.conan/settings.yml
  yq "with(.compiler.[\`"$_\`"].thread_sanitizer; . = [\`"None\`", True] | . style=\`"flow\`")"  -i $HOME/.conan/settings.yml
  yq "with(.compiler.[\`"$_\`"].ub_sanitizer; . = [\`"None\`", True] | . style=\`"flow\`")"  -i $HOME/.conan/settings.yml
}

$config = Get-Content -Path $HOME/.conan/conan.conf
$config = $config -replace ".*?print_run_commands = .*", "print_run_commands = True"
$config = $config -replace ".*?user_home_short = .*", "user_home_short = None"
Set-Content -Path $HOME/.conan/conan.conf -Value $config

