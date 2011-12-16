# source me!


iso_io_cd_write_no_append()
{
    EExec mkisofs -R $mkisofs_path | \
	EExec cdrecord -v $dummy $multi $data 
	    fs=$fs speed=$speed dev="$dev" - || {
		echo 1>&2 "mkisofs | cdrecord pipeline failed."
		exit 1
	    }
}


    if [ "$append" = "n" ]
    then
	if [ "$show_only" != y ]
	then
	    mkisofs -R $mkisofs_path | cdrecord -v $dummy $multi \
		$data fs=$fs speed=$speed dev="$dev" - || {
		echo 1>&2 "mkisofs/cdrecord failed."
    		exit 1
	    }
	else
	    echo "NO append: mkisofs $mkisofs_path"
	fi
    else
	# perform the necessary incantation to append our data to
	# what is already on the disc.
	# Note that we need create a temp image as large as the
	# total image (old+new)
	if [ "$show_only" != 'y' ]
	then
	    magic=$(cdrecord -msinfo dev="$dev")
	else
	    magic="NO MAGIC, dummy run"
	fi
	    
	merge_tmp=/sundry/tmp/cd-bak-merge.iso

	# @todo why can't I just pipe the mkisofs into the cdrecord?
	EExec mkisofs -o $merge_tmp -R -C "$magic" -M "$dev" $mkisofs_path
	EExec cdrecord -v $dummy $multi $data fs=$fs speed=$speed \
		dev="$dev" $merge_tmp
	EExec rm -f $merge_tmp
    fi
