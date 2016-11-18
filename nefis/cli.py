# -*- coding: utf-8 -*-
import logging

import click
import nefis.cnefis
from . import dataset



@click.command()
def main(args=None):
    """Console script for nefis"""
    error, version = nefis.cnefis.getnfv()
    click.echo("Welcome to nefis, the numerical model storage format.")
    click.echo(version)


@click.command()
@click.argument('filename', type=click.Path(exists=True))
@click.option('-h', type=bool, default=False)
@click.option('--version', type=int, default=1)
@click.option('--variable', type=str)
@click.option('-v', '--verbose', count=True)
def dump(filename, h, version, variable, verbose):
    """Inspect nefis files"""
    loglevels = {
        0: logging.WARN,
        1: logging.INFO,
        2: logging.DEBUG,
        3: logging.NOTSET
    }
    logging.basicConfig(level=loglevels[verbose])

    click.echo(click.format_filename(filename))
    ds = dataset.Nefis(filename)
    if version == 1:
        click.echo(ds.dump())
    if version == 2:
        click.echo(ds.dump2())
    click.echo(("variable", variable))
    if variable:
        click.echo(ds.get_data(variable, "map-series"))




if __name__ == "__main__":
    main()
