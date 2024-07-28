group "default" {
    targets = ["bin", "image"]
}

target "docker-metadata-action" {}

variable "BIRD_VERSION" {
    default = "2.13.1"
}

target "base" {
    inherits = ["docker-metadata-action"]
    args = {
        bird_version = "${BIRD_VERSION}"
    }
    labels = {
        "org.opencontainers.image.title" = "bird"
        "org.opencontainers.image.description" = "BIRD Internet Routing Daemon"
        "org.opencontainers.image.version" = "${BIRD_VERSION}"
    }
}

target "bin" {
    inherits = ["base"]
    target = "bin"
    platforms = ["linux/amd64", "linux/arm64", "linux/mips"]
    output = ["type=local,dest=bin"]
}

target "image" {
    inherits = ["base"]
    target = "image"
    platforms = ["linux/amd64", "linux/arm64"]
}
