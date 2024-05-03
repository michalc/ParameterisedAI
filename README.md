# ParameterisedAI

A very basic OpenTTD AI, designed for exploring how its behaviour changes as parameters change, rather than as a competitor to play against.

The AI currently make a single bus route, and the only parameter is the number of buses to attempt to build on that route.


## Usage

A convenient way of running this AI is with [OpenTTDLab](https://github.com/michalc/OpenTTDLab), with results then processed and visualised using [pandas](https://pandas.pydata.org/) and [Plotly Express](https://plotly.com/python/plotly-express/).


```bash
python -m pip install OpenTTDLab==0.0.52 pandas==2.2.0 plotly==5.18.0
```

To run an experiment:

```python
from openttdlab import run_experiment, remote_file, bananas_ai_library

results = run_experiments(
    openttd_version='13.4',
    opengfx_version='7.1',
    experiments=(
        {
             'seed': seed,
             'ais': (
                remote_file(
                    'https://github.com/michalc/SupplyChainLabAI/archive/d3ac662b47267ed4fa84a5b3997c020ef140f1e2.tar.gz',
                    ai_name='ParameterisedAI',
                    ai_params=(
                        ('maximum_buses', maximum_buses),
                    ),
                ),
             ),
             # Increase to run for longer
            'days': 365 * 4 + 1,
        }
        for maximum_buses in [1, 2, 4, 8, 16]
        for seed in range(0, 10)
    ),
    ai_libraries=(
        bananas_ai_library('5046524f', 'Pathfinder.Road'),
        bananas_ai_library('4752412a', 'Graph.AyStar'),
        bananas_ai_library('51554248', 'Queue.BinaryHeap'),
    ),
)
```

To then extract results:

```python
import pandas as pd

df = pd.DataFrame(
    {
        # It's slightly awkward right now to get at the original AI params
        'max_buses': row['experiment']['ais'][0][1][0][1],
        'seed': row['experiment']['seed'],
        'date': row['date'],
        'money': row['chunks']['PLYR']['0']['money'],
    }
    for row in results
)
df = df.pivot(index='date', columns=('seed', 'max_buses'), values='money')
df = df.T.groupby(level=1).mean().T
```

And then to plot them:

```python
import plotly.express as px

fig = px.line(df)
fig.show()
```

To show:

![A plot of money against time for a range of buses](https://raw.githubusercontent.com/michalc/ParameterisedAI/main/example-results.svg)

