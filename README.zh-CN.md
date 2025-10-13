# Maven Release Action

[English](README.md) | 简体中文

一个完整的 GitHub 复合 Action，用于将 Maven 项目发布到 Maven Central，并自动创建 GitHub Releases 和 Pages 部署。

## ✨ 特性

* 🚀 **完整的发布工作流** - 一个 Action 处理整个发布过程
* 📦 **Maven Central 部署** - 自动部署并进行 GPG 签名
* 🏷️ **GitHub Releases** - 自动创建包含构件的发布版本
* 📚 **文档发布** - 将 Maven 站点部署到 GitHub Pages
* 🧪 **测试与覆盖率** - 运行测试并集成 JaCoCo 和 Codecov
* 🔐 **安全签名** - 对所有构件进行 GPG 签名
* 📊 **构建摘要** - 精美的 GitHub Actions 摘要报告
* 🎯 **灵活配置** - 自定义发布的每个方面
* 📁 **多模块支持** - 通过工作目录支持子模块

## 📋 前提条件

* 配置了 Maven Central 部署的 Maven 项目
* 用于签名构件的 GPG 密钥
* Maven Central (OSSRH) 账户
* 仓库启用 GitHub Actions
* Java 8 或更高版本

## 🚀 快速开始

### 最简配置

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
      
      - name: 发布到 Maven Central
        uses: chensoul/maven-release-action@v1
        with:
          java-version: '17'
          gpg-private-key: ${{ secrets.GPG_PRIVATE_KEY }}
          gpg-passphrase: ${{ secrets.GPG_PASSPHRASE }}
          maven-username: ${{ secrets.MAVEN_CENTRAL_USERNAME }}
          maven-password: ${{ secrets.MAVEN_CENTRAL_PASSWORD }}
          github-token: ${{ secrets.GITHUB_TOKEN }}
```

### 完整功能发布

```yaml
- name: 完整发布
  uses: chensoul/maven-release-action@v1
  with:
    java-version: '17'
    java-distribution: 'temurin'
    gpg-private-key: ${{ secrets.GPG_PRIVATE_KEY }}
    gpg-passphrase: ${{ secrets.GPG_PASSPHRASE }}
    maven-username: ${{ secrets.MAVEN_CENTRAL_USERNAME }}
    maven-password: ${{ secrets.MAVEN_CENTRAL_PASSWORD }}
    github-token: ${{ secrets.GITHUB_TOKEN }}
    codecov-token: ${{ secrets.CODECOV_TOKEN }}
    skip-tests: 'false'
    deploy-pages: 'true'
    create-release: 'true'
```

## 📖 输入参数

| 参数              | 描述                                 | 必需 | 默认值 |
|-------------------|--------------------------------------|------|--------|
| java-version      | 使用的 Java 版本                     | 否   | 8      |
| java-distribution | Java 发行版 (temurin, zulu 等)       | 否   | zulu   |
| maven-args        | 额外的 Maven 参数                    | 否   | -ntp -U -B |
| gpg-private-key   | 用于签名的 GPG 私钥                  | **是*** | -      |
| gpg-passphrase    | GPG 密码短语                         | **是*** | -      |
| maven-username    | Maven Central 用户名 (OSSRH)         | **是*** | -      |
| maven-password    | Maven Central 密码 (OSSRH)           | **是*** | -      |
| github-token      | 用于创建发布和部署页面的 GitHub token | 否**    | ''     |
| codecov-token     | 用于上传覆盖率的 Codecov token       | 否   | ''     |
| skip-tests        | 跳过运行测试                         | 否   | false  |
| deploy-pages      | 将文档部署到 GitHub Pages            | 否   | true   |
| create-release    | 创建 GitHub Release                  | 否   | true   |
| working-directory | Maven 的工作目录                     | 否   | .      |
| cache-key-prefix  | Maven 缓存键前缀                     | 否   | maven-release |

**\*** Maven Central 部署必需  
**\*\*** 仅在 `create-release: 'true'` 或 `deploy-pages: 'true'` 时需要

### Java 版本选择

默认 Java 版本为 **8**，以获得最大兼容性：

```yaml
# 默认（Java 8）- 最大兼容性
- uses: chensoul/maven-release-action@v1

# 现代项目（Java 11+）
- uses: chensoul/maven-release-action@v1
  with:
    java-version: '17'  # 或 '11', '21'
```

**何时使用不同版本：**
- **Java 8**（默认）：面向广泛用户的库、传统项目
- **Java 11**：使用 Java 11+ 特性的项目、维护 LTS 兼容性
- **Java 17**：现代项目、当前的 LTS 版本，长期支持
- **Java 21**：最新的 LTS 版本、前沿特性

### 各功能所需密钥

| 功能 | 必需的密钥 |
|---------|------------------|
| **Maven Central 部署**（核心） | `gpg-private-key`, `gpg-passphrase`, `maven-username`, `maven-password` |
| **GitHub Release**（可选） | `github-token` |
| **GitHub Pages**（可选） | `github-token` |
| **代码覆盖率**（可选） | `codecov-token` |

## 📤 输出参数

| 输出               | 描述                                   |
|--------------------|----------------------------------------|
| release-version    | 发布的版本号                           |
| release-status     | 发布状态 (success/failure)             |
| artifacts-deployed | 构件是否已部署到 Maven Central         |
| release-url        | GitHub Release URL（如果已创建）       |

## 💡 使用示例

### 示例 1：最小化配置（仅 Maven Central）

如果您只想部署到 Maven Central，不需要 GitHub Release 或 Pages：

```yaml
- name: 部署到 Maven Central
  uses: chensoul/maven-release-action@v1
  with:
    java-version: '17'
    gpg-private-key: ${{ secrets.GPG_PRIVATE_KEY }}
    gpg-passphrase: ${{ secrets.GPG_PASSPHRASE }}
    maven-username: ${{ secrets.MAVEN_CENTRAL_USERNAME }}
    maven-password: ${{ secrets.MAVEN_CENTRAL_PASSWORD }}
    # 禁用这些功能时无需 github-token：
    create-release: 'false'
    deploy-pages: 'false'
```

### 示例 2：标签推送时发布（完整功能）

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
      
      - name: 发布
        uses: chensoul/maven-release-action@v1
        with:
          gpg-private-key: ${{ secrets.GPG_PRIVATE_KEY }}
          gpg-passphrase: ${{ secrets.GPG_PASSPHRASE }}
          maven-username: ${{ secrets.MAVEN_CENTRAL_USERNAME }}
          maven-password: ${{ secrets.MAVEN_CENTRAL_PASSWORD }}
          github-token: ${{ secrets.GITHUB_TOKEN }}
```

### 示例 3：手动发布工作流

```yaml
name: 手动发布

on:
  workflow_dispatch:
    inputs:
      version:
        description: '发布版本 (例如：1.0.0)'
        required: true
      skip-tests:
        description: '跳过测试'
        type: boolean
        default: false

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: 更新 POM 版本
        run: |
          mvn versions:set -DnewVersion=${{ github.event.inputs.version }}
          git config user.name "GitHub Actions"
          git config user.email "actions@github.com"
          git add pom.xml
          git commit -m "chore: 版本升级至 ${{ github.event.inputs.version }}"
          git tag -a "v${{ github.event.inputs.version }}" -m "发布 v${{ github.event.inputs.version }}"
          git push origin "v${{ github.event.inputs.version }}"
      
      - name: 发布
        uses: chensoul/maven-release-action@v1
        with:
          gpg-private-key: ${{ secrets.GPG_PRIVATE_KEY }}
          gpg-passphrase: ${{ secrets.GPG_PASSPHRASE }}
          maven-username: ${{ secrets.MAVEN_CENTRAL_USERNAME }}
          maven-password: ${{ secrets.MAVEN_CENTRAL_PASSWORD }}
          github-token: ${{ secrets.GITHUB_TOKEN }}
          skip-tests: ${{ github.event.inputs.skip-tests }}
```

### 示例 4：带代码覆盖率的发布

```yaml
- name: 带覆盖率的发布
  id: release
  uses: chensoul/maven-release-action@v1
  with:
    gpg-private-key: ${{ secrets.GPG_PRIVATE_KEY }}
    gpg-passphrase: ${{ secrets.GPG_PASSPHRASE }}
    maven-username: ${{ secrets.MAVEN_CENTRAL_USERNAME }}
    maven-password: ${{ secrets.MAVEN_CENTRAL_PASSWORD }}
    github-token: ${{ secrets.GITHUB_TOKEN }}
    codecov-token: ${{ secrets.CODECOV_TOKEN }}

- name: 检查发布状态
  run: |
    echo "发布版本: ${{ steps.release.outputs.release-version }}"
    echo "发布状态: ${{ steps.release.outputs.release-status }}"
    echo "发布 URL: ${{ steps.release.outputs.release-url }}"
```

### 示例 5：快速发布（跳过测试）

```yaml
- name: 快速发布
  uses: chensoul/maven-release-action@v1
  with:
    gpg-private-key: ${{ secrets.GPG_PRIVATE_KEY }}
    gpg-passphrase: ${{ secrets.GPG_PASSPHRASE }}
    maven-username: ${{ secrets.MAVEN_CENTRAL_USERNAME }}
    maven-password: ${{ secrets.MAVEN_CENTRAL_PASSWORD }}
    github-token: ${{ secrets.GITHUB_TOKEN }}
    skip-tests: 'true'
    deploy-pages: 'false'
```

### 示例 6：发布子模块

```yaml
- name: 发布后端模块
  uses: chensoul/maven-release-action@v1
  with:
    working-directory: './backend'
    gpg-private-key: ${{ secrets.GPG_PRIVATE_KEY }}
    gpg-passphrase: ${{ secrets.GPG_PASSPHRASE }}
    maven-username: ${{ secrets.MAVEN_CENTRAL_USERNAME }}
    maven-password: ${{ secrets.MAVEN_CENTRAL_PASSWORD }}
    github-token: ${{ secrets.GITHUB_TOKEN }}
```

### 示例 7：多 Java 版本发布

```yaml
strategy:
  matrix:
    java: ['11', '17', '21']
steps:
  - name: 在 Java ${{ matrix.java }} 上发布
    uses: chensoul/maven-release-action@v1
    with:
      java-version: ${{ matrix.java }}
      gpg-private-key: ${{ secrets.GPG_PRIVATE_KEY }}
      gpg-passphrase: ${{ secrets.GPG_PASSPHRASE }}
      maven-username: ${{ secrets.MAVEN_CENTRAL_USERNAME }}
      maven-password: ${{ secrets.MAVEN_CENTRAL_PASSWORD }}
      github-token: ${{ secrets.GITHUB_TOKEN }}
```

## 🔐 配置密钥

### 1. GPG 密钥设置

```bash
# 生成 GPG 密钥（如果没有）
gpg --full-generate-key

# 导出私钥
gpg --armor --export-secret-keys YOUR_KEY_ID > private-key.asc

# 导出公钥
gpg --armor --export YOUR_KEY_ID > public-key.asc

# 上传公钥到密钥服务器
gpg --keyserver keyserver.ubuntu.com --send-keys YOUR_KEY_ID
gpg --keyserver keys.openpgp.org --send-keys YOUR_KEY_ID
```

添加到 GitHub Secrets：
- `GPG_PRIVATE_KEY`: `private-key.asc` 的内容
- `GPG_PASSPHRASE`: GPG 密钥密码

### 2. Maven Central (OSSRH) 设置

1. 在 https://central.sonatype.com 创建账户
2. 请求命名空间（例如：`io.github.yourusername`）
3. 生成用户令牌

添加到 GitHub Secrets：
- `MAVEN_CENTRAL_USERNAME`: OSSRH 用户名或令牌用户名
- `MAVEN_CENTRAL_PASSWORD`: OSSRH 密码或令牌密码

### 3. GitHub Token

使用默认的 `${{ secrets.GITHUB_TOKEN }}` 或创建具有 `contents: write` 权限的个人访问令牌。

### 4. Codecov Token（可选）

1. 在 https://codecov.io 注册
2. 链接您的仓库
3. 获取仓库令牌

添加到 GitHub Secrets：
- `CODECOV_TOKEN`: 您的 Codecov 仓库令牌

## 📝 Maven POM 配置

您的 `pom.xml` 应包含：

```xml
<project>
  <groupId>io.github.yourusername</groupId>
  <artifactId>your-project</artifactId>
  <version>1.0.0</version>
  
  <!-- Maven Central 必需的元数据 -->
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
          <!-- GPG 签名 -->
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
          
          <!-- 源码 JAR -->
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
  
  <!-- 测试覆盖率 -->
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

## 🎯 最佳实践

1. **使用语义化版本** - 使用 `v1.0.0`、`v1.0.1` 等标签发布
2. **获取完整历史** - 使用 `fetch-depth: 0` 以生成准确的发布说明
3. **设置适当的权限** - 确保工作流具有必要的权限
4. **保持密钥安全** - 永远不要将密钥提交到仓库
5. **发布前测试** - 在创建发布标签之前运行 CI 测试
6. **记录您的发布** - 使用清晰的提交消息以生成发布说明
7. **缓存依赖项** - 缓存是自动的，可加快构建速度

## 🔧 故障排除

### GPG 错误导致发布失败

* 确保 GPG 密钥格式正确（包含 BEGIN/END 行）
* 验证密码短语是否正确
* 检查公钥是否已上传到密钥服务器

### Maven Central 部署失败

* 验证 OSSRH 凭据是否正确
* 检查命名空间是否已批准
* 确保 POM 中包含所有必需的元数据
* 验证构件是否正确签名

### GitHub Release 未创建

* 检查工作流是否在标签推送时运行
* 验证 `github-token` 具有 `contents: write` 权限
* 确保 `create-release` 设置为 `'true'`
* 确认标签遵循版本模式

### GitHub Pages 部署失败

* 在仓库设置中启用 GitHub Pages
* 将 Pages 源设置为 "GitHub Actions"
* 验证 `deploy-pages` 设置为 `'true'`
* 检查 `target/staging` 目录是否存在

### 发布期间测试失败

* 首先在本地运行测试：`mvn clean verify`
* 检查 Actions 构件中的测试报告
* 在紧急发布时使用 `skip-tests: 'true'`（不推荐）

## 📊 GitHub Actions 摘要

此 Action 生成全面的摘要，包括：

* 版本信息
* 构建环境详情
* 项目元数据
* 测试结果（如果运行）
* 生成的构件列表
* 部署状态
* 快速链接：
  * GitHub Release
  * Maven Central 构件
  * 文档站点

## 🔄 版本策略

### 推荐工作流

1. 在功能分支上开发功能
2. 合并到 `main` 分支
3. 创建发布标签：`git tag -a v1.0.0 -m "Release 1.0.0"`
4. 推送标签：`git push origin v1.0.0`
5. GitHub Actions 自动处理其余部分

### 版本格式

支持语义化版本：
* `v1.0.0` - 稳定版本
* `v1.0.0-beta.1` - Beta 版本
* `v1.0.0-RC1` - 候选发布版本
* `v2.0.0-SNAPSHOT` - 快照版本（不推荐用于发布）

## 🧪 本地测试

此仓库包含一个用于本地验证的测试 Maven 项目：

```bash
# 运行本地测试套件
./test-local.sh

# 或手动测试 Maven 项目
cd test-project
mvn clean verify

# 不运行测试的测试
mvn clean install -DskipTests

# 仅编译
mvn clean compile
```

测试项目包括：

* 带 JUnit 5 测试的简单 Calculator 类
* JaCoCo 代码覆盖率配置
* 所有标准 Maven 生命周期阶段
* 兼容 Java 8+

## 📝 许可证

MIT License - 详见 [LICENSE](LICENSE) 文件

## 🤝 贡献

欢迎贡献！请随时提交 Pull Request。

## 📧 支持

如有问题和疑问：
* GitHub Issues: https://github.com/chensoul/maven-release-action/issues
* 文档: https://github.com/chensoul/maven-release-action

## 🙏 致谢

* 受 [maven-build-action](https://github.com/rosestack/maven-build-action) 启发
* 使用 [actions/setup-java](https://github.com/actions/setup-java)
* 使用 [dorny/test-reporter](https://github.com/dorny/test-reporter)
* 使用 [peaceiris/actions-gh-pages](https://github.com/peaceiris/actions-gh-pages)
* 使用 [codecov/codecov-action](https://github.com/codecov/codecov-action)

## 🔗 相关 Actions

* [maven-build-action](https://github.com/rosestack/maven-build-action) - Maven 构建和测试
* [setup-java](https://github.com/actions/setup-java) - Java 环境设置
* [upload-artifact](https://github.com/actions/upload-artifact) - 构件管理

