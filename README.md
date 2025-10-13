# Maven Release Action

English | [简体中文](README.zh-CN.md)

A comprehensive GitHub composite action for releasing Maven projects to Maven Central with automated GitHub Releases and Pages deployment.

## ✨ Features

* 🚀 **Complete Release Workflow** - One action to handle entire release process
* 📦 **Maven Central Deployment** - Automated deployment with GPG signing
* 🏷️ **GitHub Releases** - Automatic release creation with artifacts
* 📚 **Documentation Publishing** - Deploy Maven site to GitHub Pages
* 🧪 **Testing & Coverage** - Run tests with JaCoCo coverage
* 🔐 **Secure Signing** - GPG signing of all artifacts
* 🎯 **Flexible Configuration** - Customize every aspect of the release
* 📁 **Multi-module Support** - Works with submodules via working directory
* ⚡ **High Performance** - Single build process, no redundant steps

## 📋 Prerequisites

* A Maven project configured for Maven Central deployment
* GPG key for signing artifacts
* Maven Central (OSSRH) account
* GitHub Actions enabled on your repository
* Java 8 or later

## 🚀 Quick Start

### Minimal Setup

```yaml
name: Release

on:
  push:
    tags:
      - 'v*'

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Release to Maven Central
        uses: chensoul/maven-release-action@v1
        with:
          gpg-private-key: ${{ secrets.GPG_PRIVATE_KEY }}
          gpg-passphrase: ${{ secrets.GPG_PASSPHRASE }}
          maven-username: ${{ secrets.MAVEN_USERNAME }}
          maven-password: ${{ secrets.MAVEN_PASSWORD }}
          github-token: ${{ secrets.GITHUB_TOKEN }}
```

### Full-Featured Release

```yaml
- name: Complete Release
  uses: chensoul/maven-release-action@v1
  with:
    java-version: '17'
    java-distribution: 'temurin'
    server-id: 'central'
    gpg-private-key: ${{ secrets.GPG_PRIVATE_KEY }}
    gpg-passphrase: ${{ secrets.GPG_PASSPHRASE }}
    maven-username: ${{ secrets.MAVEN_USERNAME }}
    maven-password: ${{ secrets.MAVEN_PASSWORD }}
    github-token: ${{ secrets.GITHUB_TOKEN }}
    skip-tests: 'false'
    deploy-pages: 'true'
    create-release: 'true'
```

## 📖 Inputs

| Input             | Description                              | Required | Default |
|-------------------|------------------------------------------|----------|---------|
| java-version      | Java version to use                      | No       | 8       |
| java-distribution | Java distribution (temurin, zulu, etc.)  | No       | zulu    |
| server-id         | Maven server ID for deployment           | No       | central |
| maven-args        | Additional Maven arguments               | No       | -ntp -U -B |
| gpg-private-key   | GPG private key for signing              | **Yes*** | -       |
| gpg-passphrase    | GPG passphrase                           | **Yes*** | -       |
| maven-username    | Maven Central username                   | **Yes*** | -       |
| maven-password    | Maven Central password                   | **Yes*** | -       |
| github-token      | GitHub token for releases and pages      | No**     | ''      |
| skip-tests        | Skip running tests                       | No       | false   |
| deploy-pages      | Deploy documentation to GitHub Pages     | No       | true    |
| create-release    | Create GitHub Release                    | No       | true    |
| working-directory | Working directory for Maven              | No       | .       |

**\*** Required for Maven Central deployment  
**\*\*** Required only if `create-release: 'true'` or `deploy-pages: 'true'`

### Java Version Selection

The default Java version is **8** for maximum compatibility:

```yaml
# Default (Java 8) - Maximum compatibility
- uses: chensoul/maven-release-action@v1

# Modern projects (Java 11+)
- uses: chensoul/maven-release-action@v1
  with:
    java-version: '17'  # or '11', '21'
```

**When to use different versions:**
- **Java 8** (default): Libraries targeting wide audience, legacy projects
- **Java 11**: Projects using Java 11+ features, maintaining LTS compatibility  
- **Java 17**: Modern projects, current LTS with long-term support
- **Java 21**: Latest LTS, cutting-edge features

### Required Secrets by Feature

| Feature | Required Secrets |
|---------|------------------|
| **Maven Central Deployment** (core) | `gpg-private-key`, `gpg-passphrase`, `maven-username`, `maven-password` |
| **GitHub Release** (optional) | `github-token` |
| **GitHub Pages** (optional) | `github-token` |

## 📤 Outputs

| Output      | Description                              |
|-------------|------------------------------------------|
| version     | The version that was released            |
| deployed    | Whether artifacts were deployed          |
| release-url | GitHub Release URL (if created)          |

## 💡 Usage Examples

### Example 1: Minimal Setup (Maven Central Only)

If you only want to deploy to Maven Central without GitHub Release or Pages:

```yaml
- name: Deploy to Maven Central
  uses: chensoul/maven-release-action@v1
  with:
    java-version: '17'
    gpg-private-key: ${{ secrets.GPG_PRIVATE_KEY }}
    gpg-passphrase: ${{ secrets.GPG_PASSPHRASE }}
    maven-username: ${{ secrets.MAVEN_USERNAME }}
    maven-password: ${{ secrets.MAVEN_PASSWORD }}
    # No github-token needed if you disable these:
    create-release: 'false'
    deploy-pages: 'false'
```

### Example 2: Release on Tag Push (Full Features)

```yaml
name: Release

on:
  push:
    tags:
      - 'v[0-9]+.[0-9]+.[0-9]+'

jobs:
  release:
    runs-on: ubuntu-latest
    permissions:
      contents: write
      pages: write
      id-token: write
      
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      
      - name: Release
        uses: chensoul/maven-release-action@v1
        with:
          gpg-private-key: ${{ secrets.GPG_PRIVATE_KEY }}
          gpg-passphrase: ${{ secrets.GPG_PASSPHRASE }}
          maven-username: ${{ secrets.MAVEN_USERNAME }}
          maven-password: ${{ secrets.MAVEN_PASSWORD }}
          github-token: ${{ secrets.GITHUB_TOKEN }}
```

### Example 3: Manual Release with Workflow Dispatch

```yaml
name: Manual Release

on:
  workflow_dispatch:
    inputs:
      version:
        description: 'Release version (e.g., 1.0.0)'
        required: true
      skip-tests:
        description: 'Skip tests'
        type: boolean
        default: false

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Update POM version
        run: |
          mvn versions:set -DnewVersion=${{ github.event.inputs.version }}
          git config user.name "GitHub Actions"
          git config user.email "actions@github.com"
          git add pom.xml
          git commit -m "chore: bump version to ${{ github.event.inputs.version }}"
          git tag -a "v${{ github.event.inputs.version }}" -m "Release v${{ github.event.inputs.version }}"
          git push origin "v${{ github.event.inputs.version }}"
      
      - name: Release
        uses: chensoul/maven-release-action@v1
        with:
          gpg-private-key: ${{ secrets.GPG_PRIVATE_KEY }}
          gpg-passphrase: ${{ secrets.GPG_PASSPHRASE }}
          maven-username: ${{ secrets.MAVEN_USERNAME }}
          maven-password: ${{ secrets.MAVEN_PASSWORD }}
          github-token: ${{ secrets.GITHUB_TOKEN }}
          skip-tests: ${{ github.event.inputs.skip-tests }}
```

### Example 4: Release with Code Coverage

```yaml
- name: Release with Coverage
  id: release
  uses: chensoul/maven-release-action@v1
  with:
    gpg-private-key: ${{ secrets.GPG_PRIVATE_KEY }}
    gpg-passphrase: ${{ secrets.GPG_PASSPHRASE }}
    maven-username: ${{ secrets.MAVEN_USERNAME }}
    maven-password: ${{ secrets.MAVEN_PASSWORD }}
    github-token: ${{ secrets.GITHUB_TOKEN }}

- name: Check Release Status
  run: |
    echo "Release Version: ${{ steps.release.outputs.version }}"
    echo "Deployment Status: ${{ steps.release.outputs.deployed }}"
    echo "Release URL: ${{ steps.release.outputs.release-url }}"
```

### Example 5: Fast Release (Skip Tests)

```yaml
- name: Fast Release
  uses: chensoul/maven-release-action@v1
  with:
    gpg-private-key: ${{ secrets.GPG_PRIVATE_KEY }}
    gpg-passphrase: ${{ secrets.GPG_PASSPHRASE }}
    maven-username: ${{ secrets.MAVEN_USERNAME }}
    maven-password: ${{ secrets.MAVEN_PASSWORD }}
    github-token: ${{ secrets.GITHUB_TOKEN }}
    skip-tests: 'true'
    deploy-pages: 'false'
```

### Example 6: Release Submodule

```yaml
- name: Release Backend Module
  uses: chensoul/maven-release-action@v1
  with:
    working-directory: './backend'
    gpg-private-key: ${{ secrets.GPG_PRIVATE_KEY }}
    gpg-passphrase: ${{ secrets.GPG_PASSPHRASE }}
    maven-username: ${{ secrets.MAVEN_USERNAME }}
    maven-password: ${{ secrets.MAVEN_PASSWORD }}
    github-token: ${{ secrets.GITHUB_TOKEN }}
```

### Example 7: Multi-Java Version Release

```yaml
strategy:
  matrix:
    java: ['11', '17', '21']
steps:
  - name: Release on Java ${{ matrix.java }}
    uses: chensoul/maven-release-action@v1
    with:
      java-version: ${{ matrix.java }}
      gpg-private-key: ${{ secrets.GPG_PRIVATE_KEY }}
      gpg-passphrase: ${{ secrets.GPG_PASSPHRASE }}
      maven-username: ${{ secrets.MAVEN_USERNAME }}
      maven-password: ${{ secrets.MAVEN_PASSWORD }}
      github-token: ${{ secrets.GITHUB_TOKEN }}
```

## 🔐 Setting Up Secrets

### 1. GPG Key Setup

```bash
# Generate GPG key (if you don't have one)
gpg --full-generate-key

# Export private key
gpg --armor --export-secret-keys YOUR_KEY_ID > private-key.asc

# Export public key
gpg --armor --export YOUR_KEY_ID > public-key.asc

# Upload public key to key servers
gpg --keyserver keyserver.ubuntu.com --send-keys YOUR_KEY_ID
gpg --keyserver keys.openpgp.org --send-keys YOUR_KEY_ID
```

Add to GitHub Secrets:
- `GPG_PRIVATE_KEY`: Content of `private-key.asc`
- `GPG_PASSPHRASE`: Your GPG key passphrase

### 2. Maven Central (OSSRH) Setup

1. Create account at https://central.sonatype.com
2. Request namespace (e.g., `io.github.yourusername`)
3. Generate User Token

Add to GitHub Secrets:
- `MAVEN_USERNAME`: Your OSSRH username or token username
- `MAVEN_PASSWORD`: Your OSSRH password or token password

### 3. GitHub Token

Use the default `${{ secrets.GITHUB_TOKEN }}` or create a Personal Access Token with `contents: write` permission.

## 📝 Maven POM Configuration

Your `pom.xml` should include:

```xml
<project>
  <groupId>io.github.yourusername</groupId>
  <artifactId>your-project</artifactId>
  <version>1.0.0</version>
  
  <!-- Required metadata for Maven Central -->
  <name>Your Project</name>
  <description>Project description</description>
  <url>https://github.com/yourusername/your-project</url>
  
  <licenses>
    <license>
      <name>MIT License</name>
      <url>https://opensource.org/licenses/MIT</url>
    </license>
  </licenses>
  
  <developers>
    <developer>
      <name>Your Name</name>
      <email>your.email@example.com</email>
    </developer>
  </developers>
  
  <scm>
    <connection>scm:git:git://github.com/yourusername/your-project.git</connection>
    <developerConnection>scm:git:ssh://github.com:yourusername/your-project.git</developerConnection>
    <url>https://github.com/yourusername/your-project</url>
  </scm>
  
  <distributionManagement>
    <repository>
      <id>central</id>
      <url>https://central.sonatype.com/api/v1/publisher/upload</url>
    </repository>
  </distributionManagement>
  
  <profiles>
    <profile>
      <id>central</id>
      <build>
        <plugins>
          <!-- GPG Signing -->
          <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-gpg-plugin</artifactId>
            <version>3.1.0</version>
            <executions>
              <execution>
                <id>sign-artifacts</id>
                <phase>verify</phase>
                <goals>
                  <goal>sign</goal>
                </goals>
                <configuration>
                  <gpgArguments>
                    <arg>--pinentry-mode</arg>
                    <arg>loopback</arg>
                  </gpgArguments>
                </configuration>
              </execution>
            </executions>
          </plugin>
          
          <!-- Source JAR -->
          <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-source-plugin</artifactId>
            <version>3.3.0</version>
            <executions>
              <execution>
                <id>attach-sources</id>
                <goals>
                  <goal>jar-no-fork</goal>
                </goals>
              </execution>
            </executions>
          </plugin>
          
          <!-- Javadoc JAR -->
          <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-javadoc-plugin</artifactId>
            <version>3.6.3</version>
            <executions>
              <execution>
                <id>attach-javadocs</id>
                <goals>
                  <goal>jar</goal>
                </goals>
              </execution>
            </executions>
          </plugin>
        </plugins>
      </build>
    </profile>
  </profiles>
  
  <!-- For test coverage -->
  <build>
    <plugins>
      <plugin>
        <groupId>org.jacoco</groupId>
        <artifactId>jacoco-maven-plugin</artifactId>
        <version>0.8.11</version>
        <executions>
          <execution>
            <goals>
              <goal>prepare-agent</goal>
            </goals>
          </execution>
          <execution>
            <id>report</id>
            <phase>verify</phase>
            <goals>
              <goal>report</goal>
            </goals>
            <configuration>
              <outputDirectory>target/jacoco-results</outputDirectory>
            </configuration>
          </execution>
        </executions>
      </plugin>
    </plugins>
  </build>
</project>
```

## 🎯 Best Practices

1. **Use Semantic Versioning** - Tag releases with `v1.0.0`, `v1.0.1`, etc.
2. **Fetch Full History** - Use `fetch-depth: 0` for accurate release notes
3. **Set Proper Permissions** - Ensure workflow has necessary permissions
4. **Keep Secrets Secure** - Never commit secrets to repository
5. **Test Before Release** - Run CI tests before creating release tags
6. **Document Your Release** - Use clear commit messages for release notes
7. **Cache Dependencies** - Caching is automatic, speeds up builds

## 🔧 Troubleshooting

### Release Fails with GPG Error

* Ensure GPG key is properly formatted (include BEGIN/END lines)
* Verify passphrase is correct
* Check that public key is uploaded to key servers

### Maven Central Deployment Fails

* Verify OSSRH credentials are correct
* Check that namespace is approved
* Ensure all required metadata is in POM
* Verify artifacts are properly signed

### GitHub Release Not Created

* Check that workflow runs on tag push
* Verify `github-token` has `contents: write` permission
* Ensure `create-release` is set to `'true'`
* Confirm tag follows version pattern

### GitHub Pages Deployment Fails

* Enable GitHub Pages in repository settings
* Set Pages source to "GitHub Actions"
* Verify `deploy-pages` is set to `'true'`
* Check that `target/staging` directory exists

### Tests Fail During Release

* Run tests locally first: `mvn clean verify`
* Check test reports in Actions artifacts
* Use `skip-tests: 'true'` for emergency releases (not recommended)

## 📊 GitHub Actions Summary

This action generates comprehensive summaries including:

* Version information
* Build environment details
* Project metadata
* Test results (if run)
* Generated artifacts list
* Deployment status
* Quick links to:
  * GitHub Release
  * Maven Central artifact
  * Documentation site

## 🔄 Version Strategy

### Recommended Workflow

1. Develop features on feature branches
2. Merge to `main` branch
3. Create release tag: `git tag -a v1.0.0 -m "Release 1.0.0"`
4. Push tag: `git push origin v1.0.0`
5. GitHub Actions automatically handles the rest

### Version Format

Supports semantic versioning:
* `v1.0.0` - Stable release
* `v1.0.0-beta.1` - Beta release
* `v1.0.0-RC1` - Release candidate
* `v2.0.0-SNAPSHOT` - Snapshot (not recommended for releases)

## 📝 License

MIT License - see [LICENSE](LICENSE) file for details

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📧 Support

For issues and questions:
* GitHub Issues: https://github.com/chensoul/maven-release-action/issues
* Documentation: https://github.com/chensoul/maven-release-action

## 🙏 Acknowledgments

* Inspired by [maven-build-action](https://github.com/rosestack/maven-build-action)
* Uses [actions/setup-java](https://github.com/actions/setup-java)
* Uses [peaceiris/actions-gh-pages](https://github.com/peaceiris/actions-gh-pages)

## 🔗 Related Actions

* [maven-build-action](https://github.com/rosestack/maven-build-action) - Maven build and test
* [setup-java](https://github.com/actions/setup-java) - Java environment setup
* [upload-artifact](https://github.com/actions/upload-artifact) - Artifact management
