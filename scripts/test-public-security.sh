#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
temporary=$(mktemp -d "${TMPDIR:-/tmp}/public-security-test.XXXXXX")
trap 'rm -rf "$temporary"' EXIT
mkdir -p "$temporary/tests" "$temporary/provider-cache"
touch "$temporary/empty.tfrc"
cp main.tf public-security.tf home-assistant-public.tf home-studio.tf home-studio-closed-build.tf desloc-coderabbit.tf lg-tv-capture.tf echomuse.tf public-adapters.tf community-tools.tf ruview-home-sensing.tf tests/public-security-main.tf.fixture "$temporary/"
mv "$temporary/public-security-main.tf.fixture" "$temporary/test-providers.tf"
cp tests/public-security.tftest.hcl "$temporary/tests/"
cp tests/public-adapters.tftest.hcl "$temporary/tests/"
cp tests/home-studio.tftest.hcl "$temporary/tests/"
cp tests/community-tools.tftest.hcl "$temporary/tests/"
cp tests/ruview-home-sensing.tftest.hcl "$temporary/tests/"
cp public-release-reviewers.tf cloudflare-home-assistant.tf "$temporary/"
cp tests/cloudflare-home-assistant.tftest.hcl "$temporary/tests/"
cp techo5-dot.tf "$temporary/"
cp tests/techo5-dot.tftest.hcl "$temporary/tests/"
cp tests/public-release-reviewers.tftest.hcl "$temporary/tests/"
if [[ -f .terraform.lock.hcl ]]; then
  cp .terraform.lock.hcl "$temporary/"
fi
test_terraform() {
  env -i PATH="$PATH" HOME="$temporary" TF_IN_AUTOMATION=1 TF_INPUT=0 \
    TF_CLI_CONFIG_FILE="$temporary/empty.tfrc" TF_PLUGIN_CACHE_DIR="$temporary/provider-cache" \
    terraform -chdir="$temporary" "$@"
}
test_terraform init -backend=false -input=false -no-color
test_terraform test -no-color
