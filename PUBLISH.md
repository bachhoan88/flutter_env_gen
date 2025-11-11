# Publishing Guide

This document explains how to publish the flutter_env_gen package to pub.dev.

## Prerequisites

1. **pub.dev Account**: Ensure you have a Google account linked to pub.dev
2. **Package Ownership**: You must be authorized to publish under the package name
3. **GitHub Repository**: https://github.com/bachhoan88/flutter_env_gen

## First-time Setup

### 1. Get pub.dev Credentials

```bash
# Login to pub.dev
dart pub login

# Follow the browser authentication flow
# Credentials will be saved to ~/.config/dart/pub-credentials.json
```

### 2. Configure GitHub Secrets

Go to your GitHub repository:
1. Navigate to Settings ’ Secrets and variables ’ Actions
2. Add the following secrets from `~/.config/dart/pub-credentials.json`:
   - `PUB_ACCESS_TOKEN`
   - `PUB_REFRESH_TOKEN`
   - `PUB_ID_TOKEN`

### 3. (Optional) Configure Codecov

1. Sign up at https://codecov.io
2. Add your repository
3. Copy the token and add as `CODECOV_TOKEN` in GitHub Secrets

## Publishing Process

### Automated Publishing (Recommended)

The package is configured for automated publishing via GitHub Actions:

1. **Update version** in `pubspec.yaml`
2. **Update CHANGELOG.md** with release notes
3. **Commit and push** to main branch
4. **Create and push a tag**:
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```
5. GitHub Actions will automatically:
   - Run tests
   - Check formatting
   - Analyze code
   - Publish to pub.dev

### Manual Publishing

If you need to publish manually:

```bash
# 1. Check everything is ready
dart pub publish --dry-run

# 2. Run tests
dart test

# 3. Check format
dart format --output=none --set-exit-if-changed .

# 4. Analyze
dart analyze

# 5. Publish
dart pub publish
```

## Version Management

Follow semantic versioning:
- **MAJOR** (1.0.0): Breaking changes
- **MINOR** (0.1.0): New features, backward compatible
- **PATCH** (0.0.1): Bug fixes, backward compatible

## Pre-publish Checklist

- [ ] All tests pass
- [ ] Code is formatted (`dart format .`)
- [ ] No analysis issues (`dart analyze`)
- [ ] CHANGELOG.md updated
- [ ] Version bumped in pubspec.yaml
- [ ] README.md is up to date
- [ ] Example project works
- [ ] Documentation is complete

## Troubleshooting

### Authentication Issues

If publishing fails with authentication errors:
1. Re-run `dart pub login`
2. Update GitHub Secrets with new credentials
3. Check token expiration in pub-credentials.json

### Package Validation Issues

```bash
# Check what pub.dev will see
dart pub publish --dry-run

# Common issues:
# - Missing LICENSE file
# - Invalid pubspec.yaml
# - Files too large (check .gitignore)
```

### CI/CD Failures

Check GitHub Actions logs:
1. Go to Actions tab
2. Click on failed workflow
3. Review error messages
4. Common issues:
   - Missing secrets
   - Test failures
   - Format issues

## Post-publish

After successful publishing:
1. Check package on https://pub.dev/packages/flutter_env_gen
2. Verify documentation rendering
3. Test installation in a new project
4. Update GitHub release notes
5. Announce on social media (optional)

## Support

For issues or questions:
- GitHub Issues: https://github.com/bachhoan88/flutter_env_gen/issues
- Email: your-email@example.com