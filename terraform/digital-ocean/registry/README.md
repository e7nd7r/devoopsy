# DigitalOcean Container Registry Terraform Module

This Terraform module provisions a DigitalOcean Container Registry. It's a small, reusable component to create a private container registry in DigitalOcean for storing and distributing Docker/OCI images, with a simple interface and sensible defaults.

## Features

- Create a DigitalOcean Container Registry with a configurable name and subscription tier (basic or pro).
- Exposes outputs for registry name, registry URL, and creation timestamp.
- Simple module with minimal variables — designed to be used as a building block in larger infrastructure modules.

## Resources Managed

- digitalocean_container_registry.this

## Inputs (variables)

- registry_name (string, required)
  - Registry name (must be lowercase and can contain letters, numbers and dashes). This becomes the registry ID used when pushing images: registry.digitalocean.com/<name>.

- subscription_tier_slug (string, default: "basic")
  - Registry subscription tier: `basic` or `pro`.

## Outputs

- registry_name
  - The name of the created container registry.

- registry_url
  - The full registry URL prefix. You will push images to: `registry.digitalocean.com/<name>/<repo>:<tag>`.

- created_at
  - Timestamp when the registry was created.

## Usage Example

Simple example to create a registry:

```hcl
module "registry" {
  source = "./terraform/digital-ocean/registry"

  registry_name         = "my-registry"
  subscription_tier_slug = "basic"
}
```

To push an image to this registry from your machine:

1. Authenticate with DigitalOcean's registry (using doctl or Docker):

   - With doctl:
     - doctl registry login
   - With Docker (using a DO access token):
     - echo $DO_TOKEN | docker login registry.digitalocean.com -u doctl --password-stdin

2. Tag and push your image:

```bash
docker tag my-image:latest registry.digitalocean.com/my-registry/my-image:latest
docker push registry.digitalocean.com/my-registry/my-image:latest
```

## Notes & Considerations

- DigitalOcean registries are global to your account; there is no region argument required.
- The registry name must be unique within your DigitalOcean account and follow the naming constraints (lowercase, letters/numbers/dashes).
- Choose the subscription tier according to your expected storage and network requirements: `basic` or `pro`.
- This module is intentionally small — it focuses on creating the registry itself. For more complex workflows (CI/CD, automated image builds, lifecycle policies) combine this module with your CI pipeline or additional modules.

## License

This module is provided as-is without warranty. Use according to your organization's policies.

