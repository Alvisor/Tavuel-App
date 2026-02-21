# Tavuel App - Build Commands
# Usage: make <target>

PROD_API = https://tavuel-back-production.up.railway.app/v1
DEV_API = http://192.168.10.7:3000/v1
DEBUG_INFO_DIR = build/debug-info

# ── Development ─────────────────────────────────

.PHONY: run
run:
	flutter run --dart-define=API_BASE_URL=$(DEV_API)

# ── Release APK (Production) ────────────────────

.PHONY: apk
apk:
	flutter build apk --release \
		--dart-define=API_BASE_URL=$(PROD_API) \
		--obfuscate \
		--split-debug-info=$(DEBUG_INFO_DIR)

# ── Release App Bundle (Play Store) ─────────────

.PHONY: appbundle
appbundle:
	flutter build appbundle --release \
		--dart-define=API_BASE_URL=$(PROD_API) \
		--obfuscate \
		--split-debug-info=$(DEBUG_INFO_DIR)

# ── Clean ────────────────────────────────────────

.PHONY: clean
clean:
	flutter clean
	rm -rf $(DEBUG_INFO_DIR)
