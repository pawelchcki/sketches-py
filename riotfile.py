from riot import Venv
from riot import latest


venv = Venv(
    pys=["3"],
    venvs=[
        Venv(
            name="test",
            command="pytest {cmdargs}",
            pys=["2.7", "3.6", "3.7", "3.8", "3.9"],
            pkgs={
                "pytest": latest,
            },
        ),
    ],
)