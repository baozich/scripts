#!/bin/bash
# Plot free memory over time

DIRNAME=`dirname $0`
SCRIPTDIR=`cd "$DIRNAME" && pwd`
PLOT=$SCRIPTDIR/plot
. $SCRIPTDIR/../config
. $SCRIPTDIR/common-cmdline-parser.sh
. $SCRIPTDIR/common-testname-markup.sh

PLOTS=
TITLES=
for SINGLE_KERNEL in $KERNEL; do
	PLOTS="$PLOTS proc-vmstat-$SINGLE_KERNEL.plot"
	START=`head -1 tests-timestamp-$SINGLE_KERNEL | awk '{print $3}'`
	zcat proc-vmstat-$SINGLE_KERNEL-*.gz | perl -e "\$timestamp = 0;
	while (<>) {
		if (/^time: ([0-9]*)/) {
			\$timestamp=(\$1-$START);
		}
		if (/^nr_free_pages ([.0-9]*)/) {
			\$used=($PRESENT_PAGES-\$1)*4096;
			print \"\$timestamp \$used\n\";
		}
	}" > proc-vmstat-$SINGLE_KERNEL.plot-unsorted
	sort -n proc-vmstat-$SINGLE_KERNEL.plot-unsorted > proc-vmstat-$SINGLE_KERNEL.plot
	rm proc-vmstat-$SINGLE_KERNEL.plot-unsorted

	if [ "$TITLES" != "" ]; then
		TITLES=$TITLES,
	fi
	TITLES="$TITLES$SINGLE_KERNEL"
done

$PLOT --mem-usage \
	--title "$NAME Memory Usage Comparison" \
	--format "postscript color" \
	--titles $TITLES \
	--extra $TMPDIR/$NAME-extra \
	--yrange 0:$PRESENT_MB \
	--dump \
	--output $OUTPUTDIR/memory-usage-comparison-$NAME.ps \
	$PLOTS > $OUTPUTDIR/memory-usage-comparison-$NAME.gp
echo Generated memory-usage-$NAME.ps
