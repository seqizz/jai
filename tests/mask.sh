#!/bin/sh

. ./common.sh

setup_test mask
init_config

TARGET_NAME=jai-mask-target-$$
TARGET_PATH=$REAL_HOME/$TARGET_NAME

register_cleanup_path "$TARGET_PATH"

real_user_write_file "$TARGET_PATH" "mask-me"

cat >"$CONFIG_DIR/mask-on.conf" <<EOF
conf .defaults
mode casual
jail masked
mask $TARGET_NAME
EOF

cleanup_jai
capture_in_dir "$WORKDIR" run_jai -C mask-on /bin/sh -c '[ -e "$1" ] && printf visible || printf hidden' sh "$TARGET_PATH"
assert_status 0
assert_eq "$CAPTURE_STDOUT" "hidden"

cat >"$CONFIG_DIR/mask-off.conf" <<EOF
conf .defaults
mode casual
jail unmasked
mask $TARGET_NAME
unmask $TARGET_NAME
EOF

cleanup_jai
capture_in_dir "$WORKDIR" run_jai -C mask-off /bin/sh -c '[ -e "$1" ] && printf visible || printf hidden' sh "$TARGET_PATH"
assert_status 0
assert_eq "$CAPTURE_STDOUT" "visible"
assert_file_equals "$TARGET_PATH" "mask-me"

# --- Absolute path masking (directories) ---

ABS_TARGET=/tmp/jai-mask-abs-$$
register_cleanup_path "$ABS_TARGET"
mkdir -p "$ABS_TARGET"
echo "sensitive" > "$ABS_TARGET/secret"

# Absolute mask should hide the directory
cleanup_jai
capture_in_dir "$WORKDIR" run_jai -C mask-on --mask "$ABS_TARGET" /bin/sh -c \
    '[ -d "$1" ] && printf visible || printf hidden' sh "$ABS_TARGET"
assert_status 0
assert_eq "$CAPTURE_STDOUT" "hidden"

# Absolute unmask should reverse
cleanup_jai
capture_in_dir "$WORKDIR" run_jai -C mask-on --mask "$ABS_TARGET" --unmask "$ABS_TARGET" /bin/sh -c \
    '[ -d "$1" ] && printf visible || printf hidden' sh "$ABS_TARGET"
assert_status 0
assert_eq "$CAPTURE_STDOUT" "visible"
