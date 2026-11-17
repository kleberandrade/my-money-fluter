# Storage and migration

## Back up before upgrading

Quit the old app and make an external copy of `my_money.db` from its application Documents directory. Keep the same application identity: Android `com.example.my_money`, iOS `com.example.myMoney`. A new install or a different application identity cannot discover another app's sandbox. This repository keeps both original IDs.

Native storage still uses `getApplicationDocumentsDirectory()/my_money.db`. Web is a new target: `my_money.db` is stored in IndexedDB for the current browser profile and origin. It is independent of native data; changing host/port or clearing site data changes/removes this storage. No automatic cross-device or native-to-browser import is claimed.

## Version 1 → 2

The old app opened Sembast without a version (version 1). The new opener requests version 2. Sembast runs `onVersionChanged` atomically; every legacy transaction is validated and migrated before the schema version commits. On failure, no partial migration is committed and the app shows a retry screen instead of deleting or replacing data.

The int-keyed `Category` and `Transaction` stores and their keys remain unchanged. Category maps keep `name`, `icon` (Material code point), and `color` (ARGB). Transactions keep `description`, `date` (epoch milliseconds), `isPending`, embedded `category`, `type` (`0` income, `1` expense) and any unknown fields. Migration adds:

- `amountMinor`: integer BRL cents, rounded once from the legacy positive finite `value * 100`. This restores values from the original two-decimal entry UI and removes binary floating point residue such as `0.1 + 0.2`.
- `dateLocal`: a date-only `yyyy-MM-dd` string, derived from the original epoch in the device's local timezone on first upgrade. The old format did not record its originating timezone, so its intended calendar date cannot be recovered if the timezone has changed. Subsequent reads use the date-only field, independent of timezone.

The legacy `value` field remains for audit, but is no longer authoritative and is not updated on edits. **Do not downgrade the database into the old application**: it neither understands cents nor the schema version. Restore your pre-upgrade backup when rolling back.

Invalid legacy records stop migration with their record key in the diagnostic; preserve the database and repair a copy. No record is silently skipped. New values accept 0.01–9,999,999,999.99 BRL and calendar dates 1900–2100. Values beyond those bounds require an explicit data review before upgrading. Numeric input uses Brazilian notation (`1.234,56`), stored values never use localized strings.

Edits and deletion now use actual database keys instead of list positions plus one. Category edits/deletion affect future selections; each old transaction retains its historical category snapshot, matching the original storage design. Unknown legacy icon codes retain their stored value and display a category fallback; supported codes use constant Material icons for release tree shaking.

## Tests

`flutter test test/data` exercises legacy record shapes (including category snapshots, fractional floating point residue, keys with gaps and extra fields), atomic rollback on invalid values, idempotent reopen, CRUD, demo isolation and native-file close/reopen. Tests use synthetic data; no personal financial data is bundled. The disk fixture is created with the current Sembast writer using the original record schema; it is not a captured installation of the old binary.
