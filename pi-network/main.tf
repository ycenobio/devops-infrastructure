terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.0"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

resource "docker_network" "private_bridge_net" {
  name   = "production_isolated_network"
  driver = "bridge"

  ipam_config {
    subnet  = "10.10.10.0/24"
    gateway = "10.10.10.1"
  }

  options = {
    "com.docker.network.bridge.enable_icc"           = "true"
    "com.docker.network.bridge.name"                 = "br-prod-iso"
    "com.docker.network.driver.mtu"                  = "1500"
  }
}

output "network_id" {
  value       = docker_network.private_bridge_net.id
  description = "The unique ID of the isolated container subnet."
}
# 4. Pull the official lightweight Redis image
resource "docker_image" "redis_img" {
  name         = "redis:7-alpine"
  keep_locally = false
}

# 5. Spin up the Database Container inside our private network
resource "docker_container" "db_container" {
  name  = "production_backend_db"
  image = docker_image.redis_img.image_id

  # Attach it strictly to the private network we created earlier
  networks_advanced {
    name         = docker_network.private_bridge_net.name
    ipv4_address = "10.10.10.25" # Assign a static private IP inside the subnet
  }

  # We are purposely NOT mapping any ports to the host (no "ports" block).
  # This ensures the database can only be reached by other containers inside this network.
}
# 6. Pull the official lightweight Nginx image for the frontend website
resource "docker_image" "nginx_img" {
  name         = "nginx:alpine"
  keep_locally = false
}

# 7. Spin up the Frontend Web Container
resource "docker_container" "web_frontend" {
  name  = "production_frontend_web"
  image = docker_image.nginx_img.image_id

  # Connect it to our custom private subnet
  networks_advanced {
    name         = docker_network.private_bridge_net.name
    ipv4_address = "10.10.10.50" # Assign a separate static private IP
  }

  # Expose port 80 of the container onto port 8080 of your laptop
  ports {
    internal = 80
    external = 8080
  }
}
