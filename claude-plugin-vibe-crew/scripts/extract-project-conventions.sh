#!/usr/bin/env bash
# scripts/extract-project-conventions.sh
# Deep scanner: import style, component patterns, state management, API patterns,
# error handling. Extends detect-conventions.sh with architectural pattern detection.
# Outputs JSON with detailed convention data.
# Exit 0 always.

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

# --- Detect primary language ---
LANGUAGE="unknown"
if [[ -f "$PROJECT_ROOT/package.json" ]]; then
  LANGUAGE="javascript"
  [[ -f "$PROJECT_ROOT/tsconfig.json" ]] && LANGUAGE="typescript"
elif [[ -f "$PROJECT_ROOT/pyproject.toml" || -f "$PROJECT_ROOT/setup.py" || -f "$PROJECT_ROOT/requirements.txt" ]]; then
  LANGUAGE="python"
elif [[ -f "$PROJECT_ROOT/Gemfile" ]]; then
  LANGUAGE="ruby"
elif [[ -f "$PROJECT_ROOT/go.mod" ]]; then
  LANGUAGE="go"
elif [[ -f "$PROJECT_ROOT/Cargo.toml" ]]; then
  LANGUAGE="rust"
elif [[ -f "$PROJECT_ROOT/composer.json" ]]; then
  LANGUAGE="php"
elif [[ -f "$PROJECT_ROOT/pom.xml" || -f "$PROJECT_ROOT/build.gradle" || -f "$PROJECT_ROOT/build.gradle.kts" ]]; then
  LANGUAGE="java"
fi

# --- Initialize defaults ---
FRAMEWORK="unknown"
STATE_MGMT="none"
API_STYLE="unknown"
SERVER_STATE="none"
COMPONENT_LIB="none"
ERROR_HANDLING="none"
AUTH="none"
DATABASE="none"

# =============================================================================
# Node.js / TypeScript detection (existing logic, unchanged)
# =============================================================================
if [[ "$LANGUAGE" == "javascript" || "$LANGUAGE" == "typescript" ]]; then

  # --- Detect framework ---
  if [[ -f "$PROJECT_ROOT/package.json" ]]; then
    # Check dependencies for framework
    for fw in next nuxt remix astro svelte angular express fastify nestjs; do
      HAS_FW=$(jq -r --arg f "$fw" '.dependencies[$f] // .devDependencies[$f] // empty' "$PROJECT_ROOT/package.json" 2>/dev/null || echo "")
      if [[ -n "$HAS_FW" ]]; then
        FRAMEWORK="$fw"
        break
      fi
    done
    # Check for Vite (generic)
    if [[ "$FRAMEWORK" == "unknown" ]]; then
      HAS_VITE=$(jq -r '.devDependencies.vite // empty' "$PROJECT_ROOT/package.json" 2>/dev/null || echo "")
      if [[ -n "$HAS_VITE" ]]; then
        FRAMEWORK="vite"
      fi
    fi
  fi

  # --- Detect state management ---
  if [[ -f "$PROJECT_ROOT/package.json" ]]; then
    for sm in zustand @reduxjs/toolkit redux jotai recoil valtio pinia vuex; do
      HAS_SM=$(jq -r --arg s "$sm" '.dependencies[$s] // .devDependencies[$s] // empty' "$PROJECT_ROOT/package.json" 2>/dev/null || echo "")
      if [[ -n "$HAS_SM" ]]; then
        STATE_MGMT="$sm"
        break
      fi
    done
  fi

  # --- Detect API style ---
  if [[ -f "$PROJECT_ROOT/package.json" ]]; then
    HAS_TRPC=$(jq -r '.dependencies["@trpc/server"] // .dependencies["@trpc/client"] // empty' "$PROJECT_ROOT/package.json" 2>/dev/null || echo "")
    HAS_GRAPHQL=$(jq -r '.dependencies["@apollo/client"] // .dependencies.urql // .dependencies["graphql-request"] // empty' "$PROJECT_ROOT/package.json" 2>/dev/null || echo "")
    HAS_AXIOS=$(jq -r '.dependencies.axios // empty' "$PROJECT_ROOT/package.json" 2>/dev/null || echo "")

    if [[ -n "$HAS_TRPC" ]]; then
      API_STYLE="trpc"
    elif [[ -n "$HAS_GRAPHQL" ]]; then
      API_STYLE="graphql"
    elif [[ -n "$HAS_AXIOS" ]]; then
      API_STYLE="rest"
    else
      # Check for fetch usage in source files
      FETCH_COUNT=$(grep -rl "fetch(" "$PROJECT_ROOT/src" 2>/dev/null | head -5 | wc -l | tr -d ' ' || echo "0")
      if [[ "$FETCH_COUNT" -gt 0 ]]; then
        API_STYLE="rest"
      fi
    fi
  fi

  # --- Detect server state ---
  if [[ -f "$PROJECT_ROOT/package.json" ]]; then
    HAS_RQ=$(jq -r '.dependencies["@tanstack/react-query"] // .dependencies["react-query"] // empty' "$PROJECT_ROOT/package.json" 2>/dev/null || echo "")
    HAS_SWR=$(jq -r '.dependencies.swr // empty' "$PROJECT_ROOT/package.json" 2>/dev/null || echo "")
    if [[ -n "$HAS_RQ" ]]; then
      SERVER_STATE="react-query"
    elif [[ -n "$HAS_SWR" ]]; then
      SERVER_STATE="swr"
    fi
  fi

  # --- Detect component library ---
  if [[ -f "$PROJECT_ROOT/package.json" ]]; then
    for lib in "@radix-ui/react-dialog" "@radix-ui/react-slot" "@mui/material" "@chakra-ui/react" "antd" "@headlessui/react"; do
      HAS_LIB=$(jq -r --arg l "$lib" '.dependencies[$l] // .devDependencies[$l] // empty' "$PROJECT_ROOT/package.json" 2>/dev/null || echo "")
      if [[ -n "$HAS_LIB" ]]; then
        case "$lib" in
          @radix-ui/*) COMPONENT_LIB="radix" ;;
          @mui/*) COMPONENT_LIB="mui" ;;
          @chakra-ui/*) COMPONENT_LIB="chakra" ;;
          antd) COMPONENT_LIB="antd" ;;
          @headlessui/*) COMPONENT_LIB="headlessui" ;;
        esac
        break
      fi
    done
    # Check for shadcn (components.json)
    if [[ -f "$PROJECT_ROOT/components.json" ]]; then
      COMPONENT_LIB="shadcn"
    fi
  fi

  # --- Detect error handling patterns ---
  # Check for error boundary
  if grep -rl "ErrorBoundary\|error\.tsx\|error\.js" "$PROJECT_ROOT/src" "$PROJECT_ROOT/app" 2>/dev/null | head -1 > /dev/null 2>&1; then
    ERROR_HANDLING="error-boundaries"
  fi
  # Check for global error handler
  if grep -rl "window\.onerror\|process\.on.*uncaughtException\|app\.use.*err" "$PROJECT_ROOT/src" 2>/dev/null | head -1 > /dev/null 2>&1; then
    if [[ "$ERROR_HANDLING" == "none" ]]; then
      ERROR_HANDLING="global-handler"
    else
      ERROR_HANDLING="$ERROR_HANDLING,global-handler"
    fi
  fi

  # --- Detect auth pattern ---
  if [[ -f "$PROJECT_ROOT/package.json" ]]; then
    HAS_NEXTAUTH=$(jq -r '.dependencies["next-auth"] // .dependencies["@auth/core"] // empty' "$PROJECT_ROOT/package.json" 2>/dev/null || echo "")
    HAS_CLERK=$(jq -r '.dependencies["@clerk/nextjs"] // .dependencies["@clerk/clerk-react"] // empty' "$PROJECT_ROOT/package.json" 2>/dev/null || echo "")
    HAS_SUPABASE_AUTH=$(jq -r '.dependencies["@supabase/auth-helpers-nextjs"] // .dependencies["@supabase/ssr"] // empty' "$PROJECT_ROOT/package.json" 2>/dev/null || echo "")
    if [[ -n "$HAS_NEXTAUTH" ]]; then
      AUTH="next-auth"
    elif [[ -n "$HAS_CLERK" ]]; then
      AUTH="clerk"
    elif [[ -n "$HAS_SUPABASE_AUTH" ]]; then
      AUTH="supabase"
    fi
  fi

  # --- Detect database/ORM ---
  if [[ -f "$PROJECT_ROOT/package.json" ]]; then
    HAS_PRISMA=$(jq -r '.dependencies.prisma // .devDependencies.prisma // .dependencies["@prisma/client"] // empty' "$PROJECT_ROOT/package.json" 2>/dev/null || echo "")
    HAS_DRIZZLE=$(jq -r '.dependencies["drizzle-orm"] // empty' "$PROJECT_ROOT/package.json" 2>/dev/null || echo "")
    HAS_MONGOOSE=$(jq -r '.dependencies.mongoose // empty' "$PROJECT_ROOT/package.json" 2>/dev/null || echo "")
    if [[ -n "$HAS_PRISMA" ]]; then
      DATABASE="prisma"
    elif [[ -n "$HAS_DRIZZLE" ]]; then
      DATABASE="drizzle"
    elif [[ -n "$HAS_MONGOOSE" ]]; then
      DATABASE="mongoose"
    fi
  fi

# =============================================================================
# Non-Node.js language detection
# =============================================================================
elif [[ "$LANGUAGE" == "python" ]]; then

  # --- Detect framework ---
  # Helper: check if a dependency name appears in pyproject.toml or requirements.txt
  _py_has_dep() {
    local dep="$1"
    if [[ -f "$PROJECT_ROOT/pyproject.toml" ]]; then
      grep -qi "$dep" "$PROJECT_ROOT/pyproject.toml" 2>/dev/null && return 0
    fi
    if [[ -f "$PROJECT_ROOT/requirements.txt" ]]; then
      grep -qi "$dep" "$PROJECT_ROOT/requirements.txt" 2>/dev/null && return 0
    fi
    if [[ -f "$PROJECT_ROOT/setup.py" ]]; then
      grep -qi "$dep" "$PROJECT_ROOT/setup.py" 2>/dev/null && return 0
    fi
    return 1
  }
  if _py_has_dep "django"; then FRAMEWORK="django"
  elif _py_has_dep "flask"; then FRAMEWORK="flask"
  elif _py_has_dep "fastapi"; then FRAMEWORK="fastapi"
  fi

  # --- Detect database/ORM ---
  if _py_has_dep "sqlalchemy"; then DATABASE="sqlalchemy"
  elif _py_has_dep "django" && [[ -d "$PROJECT_ROOT" ]]; then DATABASE="django-orm"
  elif _py_has_dep "tortoise-orm"; then DATABASE="tortoise-orm"
  fi

  # --- Detect auth ---
  if _py_has_dep "django-allauth"; then AUTH="django-allauth"
  elif _py_has_dep "authlib"; then AUTH="authlib"
  elif _py_has_dep "python-jose\|pyjwt"; then AUTH="jwt"
  fi

elif [[ "$LANGUAGE" == "ruby" ]]; then

  # --- Detect framework ---
  if grep -q 'rails' "$PROJECT_ROOT/Gemfile" 2>/dev/null; then FRAMEWORK="rails"
  elif grep -q 'sinatra' "$PROJECT_ROOT/Gemfile" 2>/dev/null; then FRAMEWORK="sinatra"
  fi

  # --- Detect database/ORM ---
  if grep -q 'activerecord' "$PROJECT_ROOT/Gemfile" 2>/dev/null || [[ "$FRAMEWORK" == "rails" ]]; then
    DATABASE="activerecord"
  fi

  # --- Detect auth ---
  if grep -q 'devise' "$PROJECT_ROOT/Gemfile" 2>/dev/null; then AUTH="devise"
  elif grep -q 'omniauth' "$PROJECT_ROOT/Gemfile" 2>/dev/null; then AUTH="omniauth"
  fi

elif [[ "$LANGUAGE" == "go" ]]; then

  # --- Detect framework ---
  if grep -q 'gin-gonic/gin' "$PROJECT_ROOT/go.mod" 2>/dev/null; then FRAMEWORK="gin"
  elif grep -q 'labstack/echo' "$PROJECT_ROOT/go.mod" 2>/dev/null; then FRAMEWORK="echo"
  elif grep -q 'gofiber/fiber' "$PROJECT_ROOT/go.mod" 2>/dev/null; then FRAMEWORK="fiber"
  fi

  # --- Detect database/ORM ---
  if grep -q 'gorm.io/gorm' "$PROJECT_ROOT/go.mod" 2>/dev/null; then DATABASE="gorm"
  elif grep -q 'sqlx' "$PROJECT_ROOT/go.mod" 2>/dev/null; then DATABASE="sqlx"
  fi

elif [[ "$LANGUAGE" == "rust" ]]; then

  # --- Detect framework ---
  if grep -q 'actix-web' "$PROJECT_ROOT/Cargo.toml" 2>/dev/null; then FRAMEWORK="actix"
  elif grep -q 'axum' "$PROJECT_ROOT/Cargo.toml" 2>/dev/null; then FRAMEWORK="axum"
  elif grep -q 'rocket' "$PROJECT_ROOT/Cargo.toml" 2>/dev/null; then FRAMEWORK="rocket"
  fi

  # --- Detect database/ORM ---
  if grep -q 'diesel' "$PROJECT_ROOT/Cargo.toml" 2>/dev/null; then DATABASE="diesel"
  elif grep -q 'sea-orm' "$PROJECT_ROOT/Cargo.toml" 2>/dev/null; then DATABASE="sea-orm"
  elif grep -q 'sqlx' "$PROJECT_ROOT/Cargo.toml" 2>/dev/null; then DATABASE="sqlx"
  fi

elif [[ "$LANGUAGE" == "php" ]]; then

  # --- Detect framework ---
  if grep -q 'laravel/framework' "$PROJECT_ROOT/composer.json" 2>/dev/null; then FRAMEWORK="laravel"
  elif grep -q 'symfony/framework-bundle' "$PROJECT_ROOT/composer.json" 2>/dev/null; then FRAMEWORK="symfony"
  fi

  # --- Detect database/ORM ---
  if [[ "$FRAMEWORK" == "laravel" ]]; then DATABASE="eloquent"
  elif grep -q 'doctrine/orm' "$PROJECT_ROOT/composer.json" 2>/dev/null; then DATABASE="doctrine"
  fi

  # --- Detect auth ---
  if grep -q 'laravel/sanctum' "$PROJECT_ROOT/composer.json" 2>/dev/null; then AUTH="sanctum"
  elif grep -q 'tymon/jwt-auth' "$PROJECT_ROOT/composer.json" 2>/dev/null; then AUTH="jwt"
  fi

elif [[ "$LANGUAGE" == "java" ]]; then

  # --- Helper: check pom.xml or build.gradle for a dependency ---
  _java_has_dep() {
    local dep="$1"
    if [[ -f "$PROJECT_ROOT/pom.xml" ]]; then
      grep -qi "$dep" "$PROJECT_ROOT/pom.xml" 2>/dev/null && return 0
    fi
    if [[ -f "$PROJECT_ROOT/build.gradle" ]]; then
      grep -qi "$dep" "$PROJECT_ROOT/build.gradle" 2>/dev/null && return 0
    fi
    if [[ -f "$PROJECT_ROOT/build.gradle.kts" ]]; then
      grep -qi "$dep" "$PROJECT_ROOT/build.gradle.kts" 2>/dev/null && return 0
    fi
    return 1
  }

  # --- Detect framework ---
  if _java_has_dep "spring-boot"; then FRAMEWORK="spring-boot"
  elif _java_has_dep "quarkus"; then FRAMEWORK="quarkus"
  elif _java_has_dep "micronaut"; then FRAMEWORK="micronaut"
  fi

  # --- Detect database/ORM ---
  if _java_has_dep "hibernate"; then DATABASE="hibernate"
  elif _java_has_dep "mybatis"; then DATABASE="mybatis"
  fi

  # --- Detect auth ---
  if _java_has_dep "spring-security"; then AUTH="spring-security"
  fi

fi

# --- Output JSON ---
jq -n \
  --arg lang "$LANGUAGE" \
  --arg framework "$FRAMEWORK" \
  --arg state_mgmt "$STATE_MGMT" \
  --arg api_style "$API_STYLE" \
  --arg server_state "$SERVER_STATE" \
  --arg comp_lib "$COMPONENT_LIB" \
  --arg error_handling "$ERROR_HANDLING" \
  --arg auth "$AUTH" \
  --arg database "$DATABASE" \
  '{
    language: $lang,
    framework: $framework,
    state_management: $state_mgmt,
    api_style: $api_style,
    server_state: $server_state,
    component_library: $comp_lib,
    error_handling: $error_handling,
    auth: $auth,
    database: $database
  }'

exit 0
