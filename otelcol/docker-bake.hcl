group "default" {
    targets = ["router"]
}

target "docker-metadata-action" {}

target "gosum" {
    name = "gosum-${tgt}"
    target = "gosum"
    matrix = {
        tgt = ["mini", "router"]
    }
    args = {
        target = tgt
    }
    output = ["type=local,dest=${tgt}"]
}

target "router" {
    inherits = ["docker-metadata-action"]
    tags = make_tags("router")
    args = {
        baseimage = "systemd"
        target = "router"
    }
    platforms = ["linux/amd64"]
}

target "mini-bin" {
    inherits = ["docker-metadata-action"]
    target = "bin"
    args = {
        target = "mini"
    }
    platforms = ["linux/amd64", "linux/mips64"]
    output = ["type=local,dest=bin"]
}

variable "DOCKER_METADATA_OUTPUT_TAGS" {
    default = ""
}
function "make_tags" {
    params = [ns]
    result = split("\n", replace("${DOCKER_METADATA_OUTPUT_TAGS}", ":", "/${ns}:"))
}

