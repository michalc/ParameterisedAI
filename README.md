# SupplyChainLabAI

An OpenTTD AI to investigate properties of supply chains

> [!IMPORTANT]
> This is a work in progress, and this README serves as a rough design spec than actually documenting something that exists.


## Usage

A convenient way of running this AI is with [OpenTTDLab](https://github.com/michalc/OpenTTDLab).

```python
from openttdlab import run_experiment, remote_file, bananas_ai_library

results = run_experiment(
    openttd_version='13.4',
    opengfx_version='7.1',
    seeds=range(0, 10),
    days=365 * 4 + 1,
    ais=(
        remote_file(
            'https://github.com/michalc/SupplyChainLabAI/archive/76450b683be2d55c035e385cfc5581d961685ecb.tar.gz',
            ai_name='SupplyChainLabAI',
            ai_params=(),
        ),
    ),
    ai_libraries=(
        bananas_ai_library('5046524f', 'Pathfinder.Road'),
        bananas_ai_library('4752412a', 'Graph.AyStar'),
        bananas_ai_library('51554248', 'Queue.BinaryHeap'),
    ),
)
```
