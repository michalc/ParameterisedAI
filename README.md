# ParameterisedAI

A very basic OpenTTD AI, designed for exploring how its behaviour changes as parameters change, rather than as a competitor to play against.


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
            'https://github.com/michalc/ParameterisedAI/archive/76450b683be2d55c035e385cfc5581d961685ecb.tar.gz',
            ai_name='ParameterisedAI',
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
To then plot results [pandas](https://pandas.pydata.org/) and [Plotly express](https://plotly.com/python/plotly-express/) can be used.
```python
import pandas as pd
import plotly.express as px

df = pd.DataFrame(
    {
        'seed': row['seed'],
        'date': row['date'],
        'money': row['chunks']['PLYR']['0']['money'],
    }
    for row in results
)
df = df.pivot(index='date', columns='seed', values='money')
fig = px.line(df)
fig.show()
```