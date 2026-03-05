#!/usr/bin/env bats
# Tests for scripts/generate-analysis-docs.sh

load 'test_helper/common-setup'

SCRIPT="$SCRIPTS_DIR/generate-analysis-docs.sh"

setup() {
  setup_vibecrew_dir
  mkdir -p "$VIBECREW_DIR/analysis"
}

teardown() {
  teardown_vibecrew_dir
}

create_findings_json() {
  cat > "$VIBECREW_DIR/onboard-findings.json" <<'EOF'
{
  "dependencies": {
    "language": "TypeScript",
    "framework": "Next.js",
    "runtime": "Node.js",
    "package_manager": "npm",
    "key_deps": {"react": "^18.2.0", "prisma": "^5.0.0"}
  },
  "design_system": {
    "component_library": "shadcn/ui",
    "type": "Tailwind CSS"
  },
  "architecture": {
    "database": "PostgreSQL",
    "deployment": "Vercel",
    "api_style": "REST",
    "state_management": "React Context",
    "error_handling": "try/catch",
    "auth": "NextAuth.js"
  },
  "structure": {
    "source_dirs": ["src/app", "src/lib", "src/components"],
    "component_dirs": ["src/components/ui", "src/components/layout"],
    "api_routes": "src/app/api/",
    "schema_location": "prisma/schema.prisma",
    "has_readme": true,
    "api_docs": "none",
    "todo_count": 12
  },
  "conventions": {
    "quotes": "single",
    "semicolons": "no",
    "indent": "2 spaces",
    "formatter": "Prettier",
    "linter": "ESLint",
    "component_naming": "PascalCase",
    "file_naming": "kebab-case",
    "import_style": "absolute",
    "path_alias": "@/",
    "commit_format": "conventional",
    "test_framework": "Vitest",
    "test_colocation": "__tests__/ dirs"
  },
  "test_gaps": {
    "source_count": 45,
    "test_count": 12,
    "coverage_estimate": "27",
    "untested_modules": ["src/lib/auth.ts", "src/lib/db.ts", "src/app/api/users/route.ts"]
  }
}
EOF
}

# --- Error handling ---

@test "generate-analysis-docs: fails when findings file missing" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_failure
  [[ "$output" == *"Findings file not found"* ]]
}

@test "generate-analysis-docs: accepts --findings flag" {
  create_findings_json
  local custom_path="$TEST_PROJECT_DIR/custom-findings.json"
  cp "$VIBECREW_DIR/onboard-findings.json" "$custom_path"

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' --findings '$custom_path'"
  assert_success
  [ -f "$VIBECREW_DIR/analysis/stack.md" ]
}

# --- File generation ---

@test "generate-analysis-docs: creates all 4 analysis docs" {
  create_findings_json

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success

  [ -f "$VIBECREW_DIR/analysis/stack.md" ]
  [ -f "$VIBECREW_DIR/analysis/architecture.md" ]
  [ -f "$VIBECREW_DIR/analysis/conventions.md" ]
  [ -f "$VIBECREW_DIR/analysis/gaps.md" ]
}

@test "generate-analysis-docs: stack.md contains framework info" {
  create_findings_json

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success

  grep -q "Next.js" "$VIBECREW_DIR/analysis/stack.md"
  grep -q "TypeScript" "$VIBECREW_DIR/analysis/stack.md"
  grep -q "PostgreSQL" "$VIBECREW_DIR/analysis/stack.md"
}

@test "generate-analysis-docs: conventions.md contains code style" {
  create_findings_json

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success

  grep -q "Prettier" "$VIBECREW_DIR/analysis/conventions.md"
  grep -q "Vitest" "$VIBECREW_DIR/analysis/conventions.md"
  grep -q "conventional" "$VIBECREW_DIR/analysis/conventions.md"
}

@test "generate-analysis-docs: gaps.md contains test coverage" {
  create_findings_json

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success

  grep -q "27" "$VIBECREW_DIR/analysis/gaps.md"
  grep -q "src/lib/auth.ts" "$VIBECREW_DIR/analysis/gaps.md"
}

@test "generate-analysis-docs: creates analysis dir if missing" {
  create_findings_json
  rm -rf "$VIBECREW_DIR/analysis"

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  [ -d "$VIBECREW_DIR/analysis" ]
}
