# POC Benthos Helm Chart Bug

## Bugs

> Both bugs bellow use `--set-file config=./path/config.yaml` to set the config file
1. A `-` is inserted in ConfigMap when replacing the config file by the helm template, making unreadable for Benthos
    - <details>
        <summary>Example</summary>
        
        ```
        http:
        address: 0.0.0.0:4195
        cors:
            enabled: false
        debug_endpoints: false
        enabled: true
        root_path: /benthos
        -
        input:
            http_server:
            path: /poc

        output:
            broker:
            outputs:
                - stdout:
                    codec: lines
                - sync_response: {}
        ```
    </details>

2. Custom config files that have **any extra space or blank line** are are converted to a raw string instead of being converted to YAML
    - <details>
        <summary>Example</summary>

        ```yaml
        http:
          address: 0.0.0.0:4195
          cors:
            enabled: false
          debug_endpoints: false
          enabled: true
          root_path: /benthos
        "input:\n  http_server:\n    path: /poc\n   \npipeline:\n  processors:\n    - noop:
          {}\n    \noutput:\n  broker:\n    outputs:\n      - stdout:\n          codec: lines\n
          \     - sync_response: {}\n"
        ```
    </details>

- The bugs were observed in versions in `2.1.0` and `2.1.1`.
- The unit tests (configuration_test.yaml) also fail if the bug #<!-- -->2 is reproduced

## Environment

- Windows 11 23H2
- WSL 2
- Distribution: Ubuntu 22.04.3 LTS
- Kernel: 5.15.133.1-microsoft-standard-WSL2
- Docker Engine - Community: 25.0.1
- kubectl: v1.29.1
- minikube: v1.32.0
- helm: v3.12.3

## Tests

A test pipeline is described at [poc_benthos.sh](poc_benthos.sh) and the outputs can be found at [stdout/](stdout/).