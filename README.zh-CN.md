# Maven Deploy Action

[![GitHub release](https://img.shields.io/github/v/release/chensoul/maven-deploy-action)](https://github.com/chensoul/maven-deploy-action/releases)
[![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/chensoul/maven-deploy-action/ci.yml?branch=main)](https://github.com/chensoul/maven-deploy-action/actions/workflows/test.yml)
[![License](https://img.shields.io/github/license/chensoul/maven-deploy-action)](LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/chensoul/maven-deploy-action)](https://github.com/chensoul/maven-deploy-action/stargazers)

[English](README.md) | 简体中文

将 Maven 项目部署到 Maven Central 和 GitHub Pages 的 GitHub Action。

## 特性

* 🚀 **Maven Central 部署** - 自动部署并进行 GPG 签名
* 📚 **GitHub Pages** - 部署 Maven 站点文档
* 🧪 **测试与覆盖率** - JaCoCo 集成
* ⚡ **高性能** - 单次构建流程，无冗余步骤

## 快速开始

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

## 输入参数

| 参数 | 描述 | 必需 | 默认值 |
|------|------|------|--------|
| `java-version` | Java 版本 | 否 | `8` |
| `java-distribution` | Java 发行版 | 否 | `zulu` |
| `server-id` | Maven 服务器 ID | 否 | `central` |
| `maven-args` | 额外的 Maven 参数 | 否 | `-ntp -U -B` |
| `maven-profiles` | 要激活的 Maven profiles | 否 | `central` |
| `gpg-private-key` | GPG 私钥 | 是* | - |
| `gpg-passphrase` | GPG 密码 | 是* | - |
| `maven-username` | Maven Central 用户名 | 是* | - |
| `maven-password` | Maven Central 密码 | 是* | - |
| `github-token` | GitHub token（用于 Pages） | 否** | `''` |
| `skip-tests` | 跳过测试 | 否 | `false` |
| `deploy-pages` | 部署到 GitHub Pages | 否 | `true` |
| `working-directory` | Maven 工作目录 | 否 | `.` |

\* Maven Central 部署必需  
\*\* 仅在 `deploy-pages: 'true'` 时需要

## 输出参数

| 输出 | 描述 |
|------|------|
| `version` | 已部署的版本 |
| `deployed` | 部署是否成功 |

## 使用示例

### 仅 Maven Central

```yaml
- uses: chensoul/maven-deploy-action@v1
  with:
    gpg-private-key: ${{ secrets.GPG_PRIVATE_KEY }}
    gpg-passphrase: ${{ secrets.GPG_PASSPHRASE }}
    maven-username: ${{ secrets.MAVEN_USERNAME }}
    maven-password: ${{ secrets.MAVEN_PASSWORD }}
    deploy-pages: 'false'
```

### 包含 GitHub Pages

```yaml
- uses: chensoul/maven-deploy-action@v1
  with:
    gpg-private-key: ${{ secrets.GPG_PRIVATE_KEY }}
    gpg-passphrase: ${{ secrets.GPG_PASSPHRASE }}
    maven-username: ${{ secrets.MAVEN_USERNAME }}
    maven-password: ${{ secrets.MAVEN_PASSWORD }}
    github-token: ${{ secrets.GITHUB_TOKEN }}
```

### 跳过测试

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

### 子模块

```yaml
- uses: chensoul/maven-deploy-action@v1
  with:
    working-directory: './backend'
    gpg-private-key: ${{ secrets.GPG_PRIVATE_KEY }}
    gpg-passphrase: ${{ secrets.GPG_PASSPHRASE }}
    maven-username: ${{ secrets.MAVEN_USERNAME }}
    maven-password: ${{ secrets.MAVEN_PASSWORD }}
```

### 手动部署工作流

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

## 配置

### 1. GPG 密钥

```bash
# 生成密钥
gpg --full-generate-key

# 导出私钥
gpg --armor --export-secret-keys YOUR_KEY_ID > private-key.asc

# 上传公钥
gpg --keyserver keyserver.ubuntu.com --send-keys YOUR_KEY_ID
```

添加到 GitHub Secrets：
- `GPG_PRIVATE_KEY`: `private-key.asc` 的内容
- `GPG_PASSPHRASE`: GPG 密码

### 2. Maven Central

1. 在 https://central.sonatype.com 创建账户
2. 请求命名空间（例如：`io.github.yourusername`）
3. 生成用户令牌

添加到 GitHub Secrets：
- `MAVEN_USERNAME`: OSSRH 用户名或令牌
- `MAVEN_PASSWORD`: OSSRH 密码或令牌

### 3. GitHub Token

使用 `${{ secrets.GITHUB_TOKEN }}` 或创建具有 `contents: write` 权限的 PAT。

## Maven POM 配置

`pom.xml` 需要包含：

```xml
<project>
  <groupId>io.github.yourusername</groupId>
  <artifactId>your-project</artifactId>
  <version>1.0.0</version>
  
  <!-- 必需的元数据 -->
  <name>Your Project</name>
  <description>项目描述</description>
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

## 故障排除

**GPG 错误**
- 验证密钥格式（包含 BEGIN/END 行）
- 检查密码
- 确保公钥已上传

**Maven Central 失败**
- 验证 OSSRH 凭据
- 检查命名空间批准
- 确保 POM 中包含所有必需元数据

**GitHub Pages 失败**
- 在仓库设置中启用 Pages
- 设置源为 "GitHub Actions"
- 验证 `deploy-pages: 'true'`

**测试失败**
- 本地运行：`mvn clean verify`
- 紧急情况使用 `skip-tests: 'true'`（不推荐）

## 许可证

Apache License 2.0 - 详见 [LICENSE](LICENSE)

## 链接

- [Issues](https://github.com/chensoul/maven-deploy-action/issues)
- [maven-deploy-action](https://github.com/rosestack/maven-deploy-action)
- [actions/setup-java](https://github.com/actions/setup-java)
