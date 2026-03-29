# setup-awf

GitHub Action to install [AWF CLI](https://github.com/awf-project/cli) and optional plugins.

## Usage

### Basic

```yaml
steps:
  - uses: actions/checkout@v4
  - uses: awf-project/setup-awf@v1
  - run: awf run my-workflow.yaml
```

### Pinned version

```yaml
steps:
  - uses: actions/checkout@v4
  - uses: awf-project/setup-awf@v1
    with:
      version: '1.2.0'
  - run: awf run my-workflow.yaml
```

### With plugins

```yaml
steps:
  - uses: actions/checkout@v4
  - uses: awf-project/setup-awf@v1
    with:
      version: '1.2.0'
      plugins: |
        myorg/awf-plugin-jira@v1.0.0
        myorg/awf-plugin-slack@v2.1.0
  - run: awf run my-workflow.yaml
```

### Private repositories

```yaml
steps:
  - uses: actions/checkout@v4
  - uses: awf-project/setup-awf@v1
    with:
      token: ${{ secrets.MY_PAT }}
      plugins: |
        private-org/awf-plugin-internal@v1.0.0
  - run: awf run my-workflow.yaml
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `version` | AWF version (`1.2.0`, `v1.2.0`, or `latest`) | No | `latest` |
| `plugins` | Multi-line plugin list (`owner/repo@version`) | No | `""` |
| `token` | GitHub token for release downloads | No | `${{ github.token }}` |

## Outputs

| Output | Description |
|--------|-------------|
| `version` | Installed AWF version |
| `path` | Path to the AWF binary |

## Caching

The action automatically caches:
- **AWF binary** with key `awf-{version}-{os}-{arch}`
- **Plugins** with key `awf-plugins-{hash}-{os}-{arch}`

Subsequent runs with the same version and plugins skip downloads entirely.

## Platform support

| OS | Architecture | Supported |
|----|-------------|-----------|
| Linux | amd64 | Yes |
| Linux | arm64 | Yes |
| macOS | amd64 (Intel) | Yes |
| macOS | arm64 (Apple Silicon) | Yes |
| Windows | any | No |

## License

MIT
