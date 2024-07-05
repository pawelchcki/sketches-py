from pkg_resources import DistributionNotFound


def get_version():
    # type: () -> str
    """Return the package version.

    The write_to functionality of setuptools_scm is used (see setup.py)
    to output the version to ddsketch/__version.py which we attempt to import.

    This is done to avoid the expensive overhead of importing pkg_resources.
    """
    try:
        from .__version import version

        return version
    except ImportError:
        import pkg_resources

        try:
            return pkg_resources.get_distribution(__name__).version
        except DistributionNotFound:
            return "0+unknown"
