#!/usr/bin/env bash

export LC_ALL=C
TOPDIR=${TOPDIR:-$(git rev-parse --show-toplevel)}
BUILDDIR=${BUILDDIR:-$TOPDIR}

BINDIR=${BINDIR:-$BUILDDIR/src}
MANDIR=${MANDIR:-$TOPDIR/doc/man}

RAGECOIND=${BITCOIND:-$BINDIR/ragecoind}
RAGECOINCLI=${BITCOINCLI:-$BINDIR/ragecoin-cli}
RAGECOINTX=${BITCOINTX:-$BINDIR/ragecoin-tx}
RAGECOINQT=${BITCOINQT:-$BINDIR/qt/ragecoin-qt}

[ ! -x $RAGECOIND ] && echo "$RAGECOIND not found or not executable." && exit 1

# The autodetected version git tag can screw up manpage output a little bit
RAGEVER=($($RAGECOINCLI --version | head -n1 | awk -F'[ -]' '{ print $6, $7 }'))

# Create a footer file with copyright content.
# This gets autodetected fine for bitcoind if --version-string is not set,
# but has different outcomes for bitcoin-qt and bitcoin-cli.
echo "[COPYRIGHT]" > footer.h2m
$RAGECOIND --version | sed -n '1!p' >> footer.h2m

for cmd in $RAGECOIND $RAGECOINCLI $RAGECOINTX $RAGECOINQT; do
  cmdname="${cmd##*/}"
  help2man -N --version-string=${RAGEVER[0]} --include=footer.h2m -o ${MANDIR}/${cmdname}.1 ${cmd}
  sed -i "s/\\\-${RAGEVER[1]}//g" ${MANDIR}/${cmdname}.1
done

rm -f footer.h2m
