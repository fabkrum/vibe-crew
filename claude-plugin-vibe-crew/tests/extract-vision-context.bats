#!/usr/bin/env bats
# tests/extract-vision-context.bats
# Tests for scripts/extract-vision-context.sh

setup() {
  load 'test_helper/common-setup'
  setup_vibecrew_dir
  SCRIPT="$SCRIPTS_DIR/extract-vision-context.sh"
}

teardown() {
  teardown_vibecrew_dir
}

@test "missing VISION.md returns error JSON" {
  cd "$TEST_PROJECT_DIR"
  run bash "$SCRIPT" /nonexistent/VISION.md
  assert_success
  echo "$output" | jq empty
  [[ $(echo "$output" | jq -r '.error') == "VISION.md not found" ]]
}

@test "minimal VISION.md extracts product name" {
  cd "$TEST_PROJECT_DIR"
  cat > VISION.md << 'EOF'
# Mealwise
A meal planning app.
EOF
  run bash "$SCRIPT"
  assert_success
  echo "$output" | jq empty
  [[ $(echo "$output" | jq -r '.product_name') == "Mealwise" ]]
}

@test "extracts target audience from audience section" {
  cd "$TEST_PROJECT_DIR"
  cat > VISION.md << 'EOF'
# TestApp

## Target Audience
- Busy professionals
- Health-conscious families
- Students on a budget

## Features
- Feature one
EOF
  run bash "$SCRIPT"
  assert_success
  [[ $(echo "$output" | jq -r '.target_audience') == *"Busy professionals"* ]]
  [[ $(echo "$output" | jq -r '.target_audience') == *"Health-conscious families"* ]]
}

@test "extracts core features from bullet points" {
  cd "$TEST_PROJECT_DIR"
  cat > VISION.md << 'EOF'
# TestApp

## Features
- AI-powered meal planning
- Grocery list generation
- Nutritional tracking
EOF
  run bash "$SCRIPT"
  assert_success
  [[ $(echo "$output" | jq -r '.core_features | length') -eq 3 ]]
  [[ $(echo "$output" | jq -r '.core_features[0]') == "AI-powered meal planning" ]]
  [[ $(echo "$output" | jq -r '.core_features[1]') == "Grocery list generation" ]]
  [[ $(echo "$output" | jq -r '.core_features[2]') == "Nutritional tracking" ]]
}

@test "detects SaaS product type" {
  cd "$TEST_PROJECT_DIR"
  cat > VISION.md << 'EOF'
# MySaaS
A SaaS platform for team collaboration.
EOF
  run bash "$SCRIPT"
  assert_success
  [[ $(echo "$output" | jq -r '.product_type') == "saas" ]]
}

@test "detects mobile app product type" {
  cd "$TEST_PROJECT_DIR"
  cat > VISION.md << 'EOF'
# MyApp
A React Native mobile app for fitness tracking.
EOF
  run bash "$SCRIPT"
  assert_success
  [[ $(echo "$output" | jq -r '.product_type') == "mobile-app" ]]
}

@test "detects developer tool product type" {
  cd "$TEST_PROJECT_DIR"
  cat > VISION.md << 'EOF'
# MyCLI
A developer tool CLI for code generation.
EOF
  run bash "$SCRIPT"
  assert_success
  [[ $(echo "$output" | jq -r '.product_type') == "developer-tool" ]]
}

@test "unknown product type for generic descriptions" {
  cd "$TEST_PROJECT_DIR"
  cat > VISION.md << 'EOF'
# Something
Build a thing that does stuff.
EOF
  run bash "$SCRIPT"
  assert_success
  [[ $(echo "$output" | jq -r '.product_type') == "unknown" ]]
}

@test "detects market-facing product by default" {
  cd "$TEST_PROJECT_DIR"
  cat > VISION.md << 'EOF'
# MyApp
A consumer app for meal planning.
EOF
  run bash "$SCRIPT"
  assert_success
  [[ $(echo "$output" | jq -r '.is_market_facing') == "true" ]]
}

@test "detects internal tool as not market-facing" {
  cd "$TEST_PROJECT_DIR"
  cat > VISION.md << 'EOF'
# AdminPanel
An internal tool for company-only use.
EOF
  run bash "$SCRIPT"
  assert_success
  [[ $(echo "$output" | jq -r '.is_market_facing') == "false" ]]
}

@test "generates keywords from product name" {
  cd "$TEST_PROJECT_DIR"
  cat > VISION.md << 'EOF'
# Mealwise Planner
A meal planning app.
EOF
  run bash "$SCRIPT"
  assert_success
  [[ $(echo "$output" | jq -r '.keywords | length') -ge 2 ]]
  [[ $(echo "$output" | jq -r '.keywords[]' | grep -c "mealwise") -eq 1 ]]
  [[ $(echo "$output" | jq -r '.keywords[]' | grep -c "planner") -eq 1 ]]
}

@test "accepts custom vision file path" {
  cd "$TEST_PROJECT_DIR"
  mkdir -p docs
  cat > docs/my-vision.md << 'EOF'
# CustomApp
A custom app.
EOF
  run bash "$SCRIPT" "$TEST_PROJECT_DIR/docs/my-vision.md"
  assert_success
  [[ $(echo "$output" | jq -r '.product_name') == "CustomApp" ]]
  [[ $(echo "$output" | jq -r '.vision_file') == *"docs/my-vision.md"* ]]
}

@test "handles VISION.md with bold feature names" {
  cd "$TEST_PROJECT_DIR"
  cat > VISION.md << 'EOF'
# TestApp

## Features
- **Meal planning** with AI
- **Grocery lists** auto-generated
EOF
  run bash "$SCRIPT"
  assert_success
  [[ $(echo "$output" | jq -r '.core_features[0]') == "Meal planning with AI" ]]
  [[ $(echo "$output" | jq -r '.core_features[1]') == "Grocery lists auto-generated" ]]
}

@test "output is valid JSON" {
  cd "$TEST_PROJECT_DIR"
  cat > VISION.md << 'EOF'
# App
Description.
EOF
  run bash "$SCRIPT"
  assert_success
  echo "$output" | jq empty
  # Verify all expected fields exist
  echo "$output" | jq -e '.vision_file' >/dev/null
  echo "$output" | jq -e '.product_name' >/dev/null
  echo "$output" | jq -e '.product_type' >/dev/null
  echo "$output" | jq -e '.is_market_facing' >/dev/null
  echo "$output" | jq -e '.target_audience' >/dev/null
  echo "$output" | jq -e '.core_features' >/dev/null
  echo "$output" | jq -e '.keywords' >/dev/null
}
