from datetime import date
from openttdlab import bananas_ai_library, run_experiments, local_folder, remote_file


def test_regression():
    results = run_experiments(
        experiments=(
            {
                'seed': seed,
                'ais': (
                    local_folder('.', 'ParameterisedAI'),
                ),
                'days': 366 * 1 + 1,
            }
            for seed in range(0, 10)
        ),
        ai_libraries=(
            bananas_ai_library('5046524f', 'Pathfinder.Road'),
        ),
        openttd_version='13.4',
        opengfx_version='7.1',
        result_processor=lambda result_row: [{
            'seed': result_row['experiment']['seed'],
            'date': result_row['date'],
            'openttd_version': result_row['openttd_version'],
            'opengfx_version': result_row['opengfx_version'],
            'name': result_row['chunks']['PLYR']['0']['name'],
            'money': result_row['chunks']['PLYR']['0']['money'],
        }],
    )

    assert results[-1] == {
        'seed': 9,
        'date': date(1951, 1, 1),
        'openttd_version': '13.4',
        'opengfx_version': '7.1',
        'name': 'ParameterisedAI',
        'money': 73886,
    }
