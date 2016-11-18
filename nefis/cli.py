# -*- coding: utf-8 -*-
import logging

import click
import nefis.cnefis
import nefis.convert
import nefis.dataset

msg = r"""
 _______________________________________
/ Welcome to nefis, the numerical model \
\ storage format.                       /
 ---------------------------------------
  \
   \
       __
      UooU\.'@@@@@@`.
      \__/(@@@@@@@@@@)
           (@@@@@@@@)
           `YY~~~~YY'
            ||    ||
 """


@click.group()
@click.option('-v', '--verbose', count=True)
def cli(verbose):
    error, version = nefis.cnefis.getnfv()
    click.echo(version)
    if verbose:
        click.echo(msg)
    loglevels = {
        0: logging.WARN,
        1: logging.INFO,
        2: logging.DEBUG,
        3: logging.NOTSET
    }
    logging.basicConfig(level=loglevels[verbose])


@cli.command()
@click.argument('src', type=click.Path(exists=True))
@click.argument('dest', type=click.Path(exists=False))
@click.option('--variable', type=str)
def convert(src, dest, variable):
    """Console script for nefis"""
    nefis.convert.nefis2nc(src, dest, variables=[variable])



@cli.command()
@click.argument('filename', type=click.Path(exists=True))
@click.option('-h', type=bool, default=False)
@click.option('--version', type=int, default=1)
@click.option('--variable', type=str)
def dump(filename, h, version, variable):
    """Inspect nefis files"""

    click.echo(click.format_filename(filename))
    ds = nefis.dataset.Nefis(filename)
    if version == 1:
        click.echo(ds.dump())
    if version == 2:
        click.echo(ds.dump2())
    if variable:
        click.echo(ds.get_data(variable, "map-series"))




if __name__ == "__main__":
    main()
