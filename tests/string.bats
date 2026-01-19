# bats file
load 'test_helper.bash'  # optional helpers

setup() {
  # shellcheck source=bootstrap.sh
  source "${BATS_TEST_DIRNAME}/../bootstrap.sh"
}

@test "string::trim removes leading/trailing spaces" {
  run bash -c 'string::trim "  hi  "'
  [ "$status" -eq 0 ]
  [ "$output" = "hi" ]
