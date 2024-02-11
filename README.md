# SupplyChainLabAI

An OpenTTD AI to investigate properties of supply chains

> [!IMPORTANT]
> This is a work in progress, and this README serves as a rough design spec than actually documenting something that exists.


## Usage

A convenient way of running this AI is with [OpenTTDLab](https://github.com/michalc/OpenTTDLab).

```python
from openttdlab import run_experiment, remote_file

results = run_experiment(
    openttd_version='13.4',
    opengfx_version='7.1',
    seeds=range(0, 10),
    days=365 * 4 + 1,
    ais=(
        ('SupplyChainLabAI', (), remote_file('https://github.com/michalc/SupplyChainLabAI/archive/e4866cbdf3b3507433a09683005c0d6dcd983ae9.tar.gz')),
    ),
)
```
