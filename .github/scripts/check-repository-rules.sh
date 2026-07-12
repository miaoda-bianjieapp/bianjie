#!/usr/bin/env bash
set -euo pipefail

failures=0

error() {
  echo "::error::$1"
  failures=$((failures + 1))
}

mapfile -t tracked_files < <(git ls-files)

echo "Checking tracked generated and local-only files..."
for file in "${tracked_files[@]}"; do
  case "/$file/" in
    */.dart_tool/*|*/build/*|*/target/*|/apps/api-java/data/*|*/.idea/*|*/.gradle/*)
      error "Generated or local directory is tracked: $file"
      ;;
  esac
  case "$file" in
    *.apk|*.aab|*.class|*.iml|*.jks|*.keystore|*/android/local.properties|*/application-local.yml)
      error "Generated, machine-specific, or secret-bearing file is tracked: $file"
      ;;
  esac
done

echo "Checking common secret patterns..."
secret_pattern='(sk-[A-Za-z0-9._-]{16,}|AIza[0-9A-Za-z_-]{30,}|-----BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY-----|github_pat_[A-Za-z0-9_]{20,}|gh[pousr]_[A-Za-z0-9]{20,})'
if matches=$(git grep -nI -E "$secret_pattern" -- . \
  ':(exclude).github/scripts/check-repository-rules.sh' \
  ':(exclude)**/*.example.yml' 2>/dev/null); then
  echo "$matches"
  error "Potential secret found in tracked content. Remove it and rotate the credential if it was real."
fi

migration_dir='apps/api-java/src/main/resources/db/migration/postgresql'
echo "Checking Flyway migrations..."
declare -A seen_versions=()
if [[ -d "$migration_dir" ]]; then
  while IFS= read -r file; do
    name=$(basename "$file")
    if [[ "$name" =~ ^V([0-9]+)__([a-z0-9_]+)\.sql$ ]]; then
      version="${BASH_REMATCH[1]}"
      description="${BASH_REMATCH[2]}"
      if [[ -n "${seen_versions[$version]:-}" ]]; then
        error "Duplicate Flyway version V$version: ${seen_versions[$version]} and $name"
      fi
      seen_versions[$version]="$name"

      if [[ "$version" != "1" && "$version" != "2" && ! "$version" =~ ^[0-9]{14}$ ]]; then
        error "New Flyway migration must use a 14-digit UTC timestamp: $name"
      fi
    else
      error "Invalid Flyway migration filename: $name"
    fi
  done < <(find "$migration_dir" -maxdepth 1 -type f -name '*.sql' | sort)
fi

if [[ -n "${BASE_SHA:-}" && "$BASE_SHA" != "0000000000000000000000000000000000000000" ]]; then
  echo "Checking locked Flyway migrations against base $BASE_SHA..."
  while IFS= read -r changed; do
    case "$changed" in
      "$migration_dir/V1__initial_schema.sql"|"$migration_dir/V2__migrate_tool_configs_to_database.sql")
        error "Locked Flyway migration was modified or deleted: $changed"
        ;;
    esac
  done < <(git diff --name-only --diff-filter=ACDMRT "$BASE_SHA" HEAD -- "$migration_dir")
fi

if (( failures > 0 )); then
  echo "Repository rule checks failed with $failures issue(s)."
  exit 1
fi

echo "Repository rule checks passed."
