# Contributing

Thanks for your interest in improving the Confident AI **Azure** Terraform module.

## Ways to contribute

- Report bugs or request features through GitHub Issues.
- Improve the docs (`README.md`, `DEPLOY.md`, the `examples/`).
- Send fixes or enhancements as pull requests.

## Development setup

You'll need:

- [Terraform](https://developer.hashicorp.com/terraform/downloads) 1.5 or newer
- The Azure CLI (`az`), authenticated to a test subscription
- `kubectl` and `helm` if you're testing the full deploy (see [DEPLOY.md](./DEPLOY.md))

There's a runnable minimal config in [`examples/quickstart.tf`](./examples/quickstart.tf).

## Before you open a pull request

Run these and make sure they pass:

```bash
terraform fmt -recursive
terraform init -backend=false
terraform validate
```

- Keep changes focused and backward-compatible where you can.
- If you add or change input variables or outputs, update the Inputs/Outputs tables in `README.md` to match.
- Follow the existing `confident_*` variable-naming convention.

## Commit messages

We use conventional prefixes:

- `feat:` a new capability
- `fix:` a bug fix
- `chore:` tooling or maintenance
- `refac:` refactor with no behavior change
- `docs:` documentation only

## Pull request flow

1. Fork the repo and branch off `main`.
2. Make your change and run the checks above.
3. Open a PR describing what changed and why; link any related issue.
4. A maintainer will review. Please respond to feedback and keep your branch current.

## Reporting security issues

Please do **not** file public issues for security problems. See [SECURITY.md](./SECURITY.md).

## License

By contributing, you agree that your contributions are licensed under the [MIT License](./LICENSE).
