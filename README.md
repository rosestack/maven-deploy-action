# Maven Deploy Action

[![GitHub release](https://img.shields.io/github/v/release/chensoul/maven-deploy-action)](https://github.com/chensoul/maven-deploy-action/releases)
[![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/chensoul/maven-deploy-action/ci.yml?branch=main)](https://github.com/chensoul/maven-deploy-action/actions/workflows/test.yml)
[![License](https://img.shields.io/github/license/chensoul/maven-deploy-action)](LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/chensoul/maven-deploy-action)](https://github.com/chensoul/maven-deploy-action/stargazers)

English | [简体中文](README.zh-CN.md)

A GitHub Action for deploying Maven projects to Maven Central and GitHub Pages.

## Features

* 🚀 **Maven Central Deployment** - Automated deployment with GPG signing
* 📚 **GitHub Pages** - Deploy Maven site documentation
* 🧪 **Testing & Coverage** - JaCoCo integration
* ⚡ **High Performance** - Single build process, no redundancy

## Quick Start

```yaml
name: Deploy

on:
  push:
    tags:
      - 'v*'

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - uses: chensoul/maven-deploy-action@v1
        with:
          gpg-private-key: ${{ secrets.GPG_PRIVATE_KEY }}
          gpg-passphrase: ${{ secrets.GPG_PASSPHRASE }}
          maven-username: ${{ secrets.MAVEN_USERNAME }}
          maven-password: ${{ secrets.MAVEN_PASSWORD }}
          github-token: ${{ secrets.GITHUB_TOKEN }}
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `java-version` | Java version | No | `8` |
| `java-distribution` | Java distribution | No | `zulu` |
| `server-id` | Maven server ID | No | `central` |
| `maven-args` | Additional Maven arguments | No | `-ntp -U -B` |
| `maven-profiles` | Maven profiles to activate | No | `central` |
| `gpg-private-key` | GPG private key for signing | Yes* | - |
| `gpg-passphrase` | GPG passphrase | Yes* | - |
| `maven-username` | Maven Central username | Yes* | - |
| `maven-password` | Maven Central password | Yes* | - |
| `github-token` | GitHub token for Pages | No** | `''` |
| `skip-tests` | Skip tests | No | `false` |
| `deploy-pages` | Deploy to GitHub Pages | No | `true` |
| `working-directory` | Maven working directory | No | `.` |

\* Required for Maven Central deployment  
\*\* Required only if `deploy-pages: 'true'`

## Outputs

| Output | Description |
|--------|-------------|
| `version` | Deployed version |
| `deployed` | Whether deployment succeeded |

## Examples

### Maven Central Only

```yaml
- uses: chensoul/maven-deploy-action@v1
  with:
    gpg-private-key: ${{ secrets.GPG_PRIVATE_KEY }}
    gpg-passphrase: ${{ secrets.GPG_PASSPHRASE }}
    maven-username: ${{ secrets.MAVEN_USERNAME }}
    maven-password: ${{ secrets.MAVEN_PASSWORD }}
    deploy-pages: 'false'
```

### With GitHub Pages

```yaml
- uses: chensoul/maven-deploy-action@v1
  with:
    gpg-private-key: ${{ secrets.GPG_PRIVATE_KEY }}
    gpg-passphrase: ${{ secrets.GPG_PASSPHRASE }}
    maven-username: ${{ secrets.MAVEN_USERNAME }}
    maven-password: ${{ secrets.MAVEN_PASSWORD }}
    github-token: ${{ secrets.GITHUB_TOKEN }}
```

### Skip Tests

```yaml
- uses: chensoul/maven-deploy-action@v1
  with:
    gpg-private-key: ${{ secrets.GPG_PRIVATE_KEY }}
    gpg-passphrase: ${{ secrets.GPG_PASSPHRASE }}
    maven-username: ${{ secrets.MAVEN_USERNAME }}
    maven-password: ${{ secrets.MAVEN_PASSWORD }}
    skip-tests: 'true'
    deploy-pages: 'false'
```

### Submodule

```yaml
- uses: chensoul/maven-deploy-action@v1
  with:
    working-directory: './backend'
    gpg-private-key: ${{ secrets.GPG_PRIVATE_KEY }}
    gpg-passphrase: ${{ secrets.GPG_PASSPHRASE }}
    maven-username: ${{ secrets.MAVEN_USERNAME }}
    maven-password: ${{ secrets.MAVEN_PASSWORD }}
```

### Manual Deploy Workflow

```yaml
name: Manual Deploy

on:
  workflow_dispatch:
    inputs:
      version:
        description: 'Version (e.g., 1.0.0)'
        required: true
      skip-tests:
        type: boolean
        default: false

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Update version and tag
        run: |
          mvn versions:set -DnewVersion=${{ github.event.inputs.version }}
          git config user.name "GitHub Actions"
          git config user.email "actions@github.com"
          git add pom.xml
          git commit -m "chore: bump version to ${{ github.event.inputs.version }}"
          git tag -a "v${{ github.event.inputs.version }}" -m "v${{ github.event.inputs.version }}"
          git push origin "v${{ github.event.inputs.version }}"
      
      - uses: chensoul/maven-deploy-action@v1
        with:
          gpg-private-key: ${{ secrets.GPG_PRIVATE_KEY }}
          gpg-passphrase: ${{ secrets.GPG_PASSPHRASE }}
          maven-username: ${{ secrets.MAVEN_USERNAME }}
          maven-password: ${{ secrets.MAVEN_PASSWORD }}
          github-token: ${{ secrets.GITHUB_TOKEN }}
          skip-tests: ${{ github.event.inputs.skip-tests }}
```

## Setup

### 1. GPG Key

```bash
# Generate key
gpg --full-generate-key

# Export private key
gpg --armor --export-secret-keys YOUR_KEY_ID > private-key.asc

# Upload public key
gpg --keyserver keyserver.ubuntu.com --send-keys YOUR_KEY_ID
```

Add to GitHub Secrets:
- `GPG_PRIVATE_KEY`: Content of `private-key.asc`
- `GPG_PASSPHRASE`: Your GPG passphrase

### 2. Maven Central

1. Create account at https://central.sonatype.com
2. Request namespace (e.g., `io.github.yourusername`)
3. Generate User Token

Add to GitHub Secrets:
- `MAVEN_USERNAME`: OSSRH username or token
- `MAVEN_PASSWORD`: OSSRH password or token

### 3. GitHub Token

Use `${{ secrets.GITHUB_TOKEN }}` or create a PAT with `contents: write` permission.

## Maven POM

Your `pom.xml` needs:

```xml
<project>
  <groupId>io.github.yourusername</groupId>
  <artifactId>your-project</artifactId>
  <version>1.0.0</version>
  
  <!-- Required metadata -->
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
      <email>your@email.com</email>
    </developer>
  </developers>
  
  <scm>
    <connection>scm:git:git://github.com/yourusername/your-project.git</connection>
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
          <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-gpg-plugin</artifactId>
            <version>3.1.0</version>
            <executions>
              <execution>
                <phase>verify</phase>
                <goals>
                  <goal>sign</goal>
                </goals>
              </execution>
            </executions>
          </plugin>
          <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-source-plugin</artifactId>
            <version>3.3.0</version>
            <executions>
              <execution>
                <goals>
                  <goal>jar-no-fork</goal>
                </goals>
              </execution>
            </executions>
          </plugin>
          <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-javadoc-plugin</artifactId>
            <version>3.6.3</version>
            <executions>
              <execution>
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
</project>
```

## Troubleshooting

**GPG Error**
- Verify key format (include BEGIN/END lines)
- Check passphrase
- Ensure public key is uploaded

**Maven Central Fails**
- Verify OSSRH credentials
- Check namespace approval
- Ensure all required metadata in POM

**GitHub Pages Fails**
- Enable Pages in repository settings
- Set source to "GitHub Actions"
- Verify `deploy-pages: 'true'`

**Tests Fail**
- Run locally: `mvn clean verify`
- Use `skip-tests: 'true'` for emergencies (not recommended)

## License

Apache License 2.0 - see [LICENSE](LICENSE)

## Links

- [Issues](https://github.com/chensoul/maven-deploy-action/issues)
- [maven-deploy-action](https://github.com/rosestack/maven-deploy-action)
- [actions/setup-java](https://github.com/actions/setup-java)
