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
    if verbose:
        click.echo(version)
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
    nefis.convert.nefis2nc_cf(src, dest, variables=[variable])



@cli.command()
@click.argument('filename', type=click.Path(exists=True))
@click.option('-h', type=bool, default=False)
@click.option('--format', type=str)
@click.option('--variable', type=str)
def dump(filename, h, format, variable):
    """Inspect nefis files"""

    ds = nefis.dataset.Nefis(filename)
    if format is None or format == "json":
        click.echo(ds.dump_json())
    elif format == "ncdump":
        click.echo(ds.dump_ncdump())
    if variable is not None:
        click.echo("VARIABLE")
        var = ds.variables[variable]
        click.echo(var.name)
        click.echo(var.attributes)
        click.echo(var[0])

if __name__ == "__main__":
    main()
