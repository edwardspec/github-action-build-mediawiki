# github-action-build-mediawiki

GitHub Action to download/install MediaWiki for the purpose of running phpunit, phan, etc. on a MediaWiki extension.

What it does:
- It will download MediaWiki core of selected branch (e.g. REL1_35),
- It will download all extensions/skins that are usually shipped with MediaWiki tarball,
- It will download additional extensions (optional), additional skins (optional), etc.,
- It will then run install.php (this step is optional; it can be disabled with `noinstall: 1` parameter - for example, you don't need full installation to run Phan).
- Then it will append `DevelopmentSettings.php` (things like "throw fatal error on any warnings", which are good for tests) to `LocalSettings.php`.
- If `extraLocalSettings: SomeFile.php` parameter is specified, then this file will also be appended to `LocalSettings.php`.
- In the end, LocalSettings.php will be linted (checked for syntax errors) with `php -l`.

Note that this action **doesn't run update.php**. You need to do it yourself (in your `.github/actions/main.yml`).

Also note that GitHub actions (including this one) can't call other actions (such as "install PHP") or start services (such as MariaDB). You need to do this in your .github/actions/main.yml.

## Sample usage

See `action.yml` for all supported parameters.

Simple "get sources only" for Phan:
```yaml
      - uses: edwardspec/github-action-build-mediawiki@v1
        with:
          branch: REL1_35
          noinstall: 1
```

Full installation that supports both MySQL/MariaDB and PostgreSQL (env.DBTYPE can be either "mysql" or "postgres"):
```yaml
      - uses: edwardspec/github-action-build-mediawiki@v1
        with:
          branch: REL1_35
          extraLocalSettings: tests/ExtraLocalSettings.php
          extensions: "AbuseFilter CheckUser Echo MobileFrontend PageForms VisualEditor"
          skins: "MinervaNeue"
          dbtype: ${{ env.DBTYPE }}
          dbname: testwiki
          dbpass: 123456
          dbserver: ${{ env.DBTYPE == 'mysql' && '127.0.0.1:3306' || '127.0.0.1' }}
```

## Practical examples

See https://github.com/edwardspec/mediawiki-moderation/blob/master/.github/workflows/main.yml (from Extension:Moderation) and https://github.com/edwardspec/mediawiki-aws-s3/blob/master/.github/workflows/main.yml (from Extension:AWS) for practical examples.
