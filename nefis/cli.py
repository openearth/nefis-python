# -*- coding: utf-8 -*-

import click
import nefis.cnefis
from . import dataset


@click.command()
def main(args=None):
    """Console script for nefis"""
    version = nefis.cnefis.getfullversionstring()
    click.echo("Welcome to nefis, the numerical model storage format.")
    click.echo(version)


@click.command()
@click.argument('f', type=click.Path(exists=True))
def dump(f):
    """Inspect nefis files"""
    click.echo(click.format_filename(f))
    ds = dataset.Nefis(f)
    click.echo(ds.dump())




if __name__ == "__main__":
    main()
