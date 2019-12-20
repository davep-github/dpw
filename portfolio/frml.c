#include <sys/types.h>
#include <sys/buf.h>
#include <sys/ioctl.h>
#include <sys/stat.h>
#include <sys/errno.h>
#include <sys/param.h>
#include <sys/systm.h>
#include <sys/malloc.h>
#include <sys/proc.h>
#include <sys/namei.h>
#include <sys/vnode.h>
#include <sys/fcntl.h>
#include <sys/device.h>
#include <sys/disk.h>
#include <sys/disklabel.h>
#ifdef SKIFF
#include <arm32/footbridge/skiff_flash.h>
#endif

/*
 * Overall system design based on:
 * A Flash-Memory Based File System
 * by
 * Atsuo Kawaguchi, Shingo Nishioka and Hiroshi Motoda
 * Advanced research Lab, Hitachi.
 *
 * Large chunks of DDI infrastructure copped from vnd.c
 */

#define	CLEAN_SECTORS_INLINE	1
#define	TRY_TO_OVERWRITE	1
#ifdef	WRITE_SVC
#undef	WRITE_SVC
#endif
#define	WRITE_SVC		1

#define FRML_DEBUG  1
#define FRML_SANITY 1
#define AUTO_INIT   1

#ifdef SKIFF
#ifdef CATS_TEST
#undef CATS_TEST
#endif
#define ENV_32_BIT  1

#else

#define CATS_TEST   1
#define ENV_32_BIT  1
#endif

#include "frml.h"

#ifdef FRML_DEBUG
#define frml_error(a)	printf a
#define frml_warn(a)	printf a
#define frml_trace(n,a)	if (frml_trace_val >= (n)) printf a
#define frml_show_rc(rc, f) if (rc) printf("%s(): rc: %d\n", f, rc)

int	frml_trace_val = 0;

#else
#define frml_error(a)
#define frml_warn(a)
#define frml_trace(n,a)
#define frml_show_rc(rc, a)
#endif

#define	frmlunit(x)	DISKUNIT(x)

#define	FRMLLABELDEV(dev) \
	(MAKEDISKDEV(major((dev)), frmlunit((dev)), RAW_PART))
    
/* point to flash or flash substitute */
frml_word_t *skiff_flash_vbase;

#ifdef USER_MODE_TEST

#include <stdlib.h>
#include <assert.h>

#define frml_malloc(n)	malloc(n)
#define frml_free(p)	free(p)

uint	num_free_sectors_counted = 0;
uint	debug_this = 0;

#else

#define frml_mallocx(n)	malloc(n, M_DEVBUF, M_NOWAIT)
#define frml_freex(p)	free(p, M_DEVBUF)

#endif

void*
frml_malloc(
    size_t  n)
{
    void*   ret;

    ret = malloc(n, M_DEVBUF, M_NOWAIT);
    frml_trace(1, ("frml_malloc, ret: %p\n", ret));
    return (ret);
}

void
frml_free(
    void*   p)
{
    frml_trace(1, ("frml_free, p: %p\n", p));
    free(p, M_DEVBUF);
}

/*
************************************************************************
*
* Todo:
* . Make write flash tsleep w/ small timo while polling
* . 
* 
************************************************************************
*/


/*
************************************************************************
*
* 
* 
************************************************************************
*/
typedef struct softc_s
{
    frml_system_t	frml_system;
    uint		num_vblocks;
    frml_remap_entry_t*	remap_table; /* XXX ??? why not in frml_system ??? */
    struct buf		io_q;
    volatile int	run_write_svc;
    volatile int	write_svc_sleeping;
    uint		num_readers;
    uint		num_modders;
    uint		lock_sleepers;
#ifdef FRML_STATS
    ulong		num_reads;
    ulong		num_writes;
    ulong		num_overwrites;
#endif
    struct disk		dkdev;	/* generic disk device info */
    uint		flags;
}
softc_t;

#define softc_to_fsp(sp)    (&(sp)->frml_system)
#ifdef FRML_STATS
#define FRML_STAT_COUNT_READS(sc)	((sc)->num_reads++)
#define FRML_STAT_COUNT_WRITES(sc)	((sc)->num_writes++)
#define FRML_STAT_COUNT_OVERWRITES(sc)  ((sc)->num_overwrites++)
#else
#define FRML_STAT_COUNT_READS(sc)
#define FRML_STAT_COUNT_WRITES(sc)
#define FRML_STAT_COUNT_OVERWRITES(sc)
#endif

#define	FRMLF_LABELLING		(0x01)
#define	FRMLF_WLABEL		(0x02)
#define	FRMLF_ERASING		(0x02)

softc_t*    flashes = NULL;
int	    numfrml = 0;

/*
 * sectors on the flash device we are driving.
 */

static frml_off_t   def_sector_offs[] =
{
    0x00000000,			/* 0 */
    0x00008000,			/* 1 */
    0x0000c000,			/* 2 */
    0x00010000,			/* 3 */
    0x00020000,			/* 4 */
    0x00040000,			/* 5 */
    0x00060000,			/* 6 */
    0x00080000,			/* 7 */
    0x000A0000,			/* 8 */
    0x000C0000,			/* 9 */
    0x000E0000,			/* 10 */
    0x00100000,			/* 11 */
    0x00120000,			/* 12 */
    0x00140000,			/* 13 */
    0x00160000,			/* 14 */
    0x00180000,			/* 15 */
    0x001A0000,			/* 16 */
    0x001C0000,			/* 17 */
    0x001E0000,			/* 18 */
    0x00200000,			/* 19 */
    0x00220000,			/* 20 */
    0x00240000,			/* 21 */
    0x00260000,			/* 22 */
    0x00280000,			/* 23 */
    0x002A0000,			/* 24 */
    0x002C0000,			/* 25 */
    0x002E0000,			/* 26 */
    0x00300000,			/* 27 */
    0x00320000,			/* 28 */
    0x00340000,			/* 29 */
    0x00360000,			/* 30 */
    0x00380000,			/* 31 */
    0x003A0000,			/* 32 */
    0x003C0000,			/* 33 */
    0x003E0000,			/* 34 */
    0x00400000			/* 35, guard sector */
};

#define DIM(a)	((sizeof(a)/sizeof(a[0])))
#define DEF_NUM_SECTORS	DIM(def_sector_offs)


/* we may want to set these via an ioctl or some such method. */
/* or we could have a number of configs selected by minor dev num */
static frml_off_t*  sector_offs = def_sector_offs;

#ifdef CATS_TEST
static int def_num_sectors = 2;
static int def_sector_zero = 0;
#elif defined (SKIFF)
static int def_sector_zero = 19;
static int def_num_sectors = 16;
#else
static int def_num_sectors = DEF_NUM_SECTORS - 1;
static int def_sector_zero = 0;
#endif

#ifdef USER_MODE_TEST
static int def_num_vblocks = 0;
#endif

#if defined(USER_MODE_TEST) || defined(CATS_TEST)


/*
************************************************************************
*
* 
* 
************************************************************************
*/
int
erase_sector(
    frml_off_t	off)
{
    uint    off_idx;
    uint    len = 0;
    int	    i;
    
    /* find len... */
    for (i = 0; i < def_num_sectors; i++) {
	off_idx = i + def_sector_zero;
	if (sector_offs[off_idx] == off) {
	    len = sector_offs[off_idx+1] - sector_offs[off_idx];
	    break;
	}
    }
    if (len == 0) {
	frml_warn(("cannot find len of sector at off: 0x%lx\n", (long)off));
	frml_warn(("def_sector_zero: %d, def_num_sectors: %d\n",
		   def_sector_zero, def_num_sectors));
	assert(len != 0);
    }
    
    memset((char*)skiff_flash_vbase + off, 0xff, len);

    return (0);
}

/*
************************************************************************
*
* 
* 
************************************************************************
*/
int
frml_write_word(
    frml_off_t	off,
    frml_word_t	datum)
{
    frml_word_t*    fp = (frml_word_t*)((char*)skiff_flash_vbase + off);
    
    if (flash_word_unwritable(*fp, datum)) {
	frml_error(("unwritable bits in word (0 --> 1): *fp: 0x%lx, dat: 0x%lx"
		    "\n", *fp, datum));
	return (EIO);
    }

    *fp = datum;

    return (0);
}
#endif

#ifdef USER_MODE_TEST
static volatile frml_word_t *flashword;

int
wakeup(
    void*   chan)
{
    frml_warn(("wakeup called on chan: %p\n", chan));
    return (0);
}

int
tsleep(
    void*   chan,
    int	    pri,
    char*   msg,
    int	    timo)
{
    frml_warn(("wakeup called on chan: %p, msg>%s<\n", chan, msg));
    return (0);
}

/*
************************************************************************
*
* 
* 
************************************************************************
*/
int
biodone(
    struct buf*	bp)
{
    if (bp->b_error) {
	frml_error(("biodone, b_error: %d\n", bp->b_error));
    }
    
    return (0);
}

#elif !defined(CATS_TEST)

extern int eraseFlashSector(frml_off_t off);
extern int programFlashWord(frml_off_t off, frml_word_t data);

#define erase_sector(p)	eraseFlashSector(p)
#define frml_write_word(off, data)  programFlashWord(off, data)

#endif

#define RL_ID	"fbrl"

int
fb_read_lock(
    frml_bank_t*    fbp,
    block_flag_t    flag,
    char*	    id)
    
{
    char    id_buf[32];
    
    if (fbp->num_modders != 0) {
	
	if (flag == FRML_NO_BLOCK)
	    return (EWOULDBLOCK);
	
	while (fbp->num_modders) {
	    fbp->lock_sleepers++;
	    memcpy(id_buf, RL_ID, sizeof(RL_ID));
	    id_buf[sizeof(RL_ID)] = id[0];
	    id_buf[sizeof(RL_ID)+1] = '\0';
	    tsleep(&fbp->lock_sleepers, PZERO-1, id_buf, 0);
	    fbp->lock_sleepers--;
	}
    }

    fbp->num_readers++;
    return (0);
}

void
fb_read_unlock(
    frml_bank_t*    fbp)
{
    fbp->num_readers--;
    if (fbp->lock_sleepers)
	wakeup(&fbp->lock_sleepers);
}

#define WL_ID	"fbwl"
int
fb_write_lock(
    frml_bank_t*    fbp,
    block_flag_t    flag,
    char*	    id)
{
    char    id_buf[32];
    
    if (fbp->num_modders || fbp->num_readers) {
	
	if (flag == FRML_NO_BLOCK)
	    return (EWOULDBLOCK);
	
	while (fbp->num_modders || fbp->num_readers) {
	    fbp->lock_sleepers++;
	    memcpy(id_buf, WL_ID, sizeof(WL_ID));
	    id_buf[sizeof(WL_ID)] = id[0];
	    id_buf[sizeof(WL_ID)+1] = '\0';
	    tsleep(&fbp->lock_sleepers, PZERO-1, id_buf, 0);
	    fbp->lock_sleepers--;
	}
    }

    fbp->num_modders++;
    return (0);
}

void
fb_write_unlock(
    frml_bank_t*    fbp)
{
    fbp->num_modders--;
    if (fbp->lock_sleepers)
	wakeup(&fbp->lock_sleepers);
}

/*
************************************************************************
*
* 
* 
************************************************************************
*/
softc_t*
frml_dev_to_sp(
    dev_t   dev)
{
    int	    unit = frmlunit(dev);

    if (unit >= numfrml) {
	frml_error(("frml: unit(%d) > numfrml(%d)\n", unit, numfrml));
	return ((softc_t*)NULL);
    }

    if (flashes == NULL) {
	frml_error(("frml: flashes is NULL\n"));
	return ((softc_t*)NULL);
    }
    
    return (&flashes[unit]);
}

/*
************************************************************************
*
* 
* 
************************************************************************
*/
int
frml_write_ptr(
    frml_word_t*    fp,
    frml_word_t	    datum,
    frml_bank_t*    fbp)
{
    return (frml_write_word((char*)fp - fbp->vbase, datum));
}
    
/*
************************************************************************
*
* 
* 
************************************************************************
*/
int
frml_write_buf(
    caddr_t	dest0,		/* in flash */
    caddr_t	src0,		/* from a bp */
    size_t	num,
    frml_bank_t	*fbp)
{
    frml_word_t*    src = (frml_word_t*)src0;
    frml_word_t*    dest = (frml_word_t*)dest0;

    frml_trace(1, ("frml_write_buf: %p\n", dest0));
    
    if (num & 3) {
	frml_error(("non dword write to flash\n"));
	return (EFAULT);
    }

    num /= sizeof(frml_word_t);
    
    while (num--) {
	frml_write_ptr(dest, *src, fbp);
	src++;
	dest++;
    }

    return (0);
}

/*
************************************************************************
*
* rmt_add_entry - add an entry to the remap table
* 
* 
************************************************************************
*/
int
rmt_add_entry(
    frml_remap_entry_t*	rt,
    frml_remap_t	remap,
    void*		block_vaddr,
    uint		sector_idx,
    uint		block_idx)
{
    frml_block_t    blk;

    /* (valid is ready or written)
     * add this entry to the remap table if:
     * 1) no entry in table and this is a valid entry
     * 2) there is an entry and the new one is written
     *	  convert old to superseded and new to ready
     */

    blk = fr_get_block(remap);

#ifdef FRML_SANITY
    /* we'll handle in the future */
    if (!REMAP_READY(remap)) {
	frml_error(("non-ready block found\n"));
	return (EINVAL);
    }
#endif
    
    if (rt[blk].block_vaddr != 0) {
	/* error for now */
	frml_error(("additional remap for block 0x%lx seen, "
		   "old: 0x%lx, new: 0x%lx\n", (long)blk,
		    (long)(rt[blk].block_vaddr),
		   remap));
	return (EINVAL);
    }

    rt[blk].block_vaddr = block_vaddr;
    frsi_init(&rt[blk].source_info, sector_idx, block_idx);

    return (0);
}

/*
************************************************************************
* sector linked lists:
* 
*  head->  sector-(flink)-> sector-(flink)->X <-tail
*              X<-(blink)<- sector-(blink)
*
************************************************************************
*/
void
fb_unlink_sector(
    frml_sector_t** headp,
    frml_sector_t** tailp,
    frml_sector_t*  fs)
{
    /* fix head 'n' tail */
    if (*headp == fs)
	*headp = fs->flink;
    if (*tailp == fs)
	*tailp = fs->blink;
    if (fs->flink)
	fs->flink->blink = fs->blink;
    if (fs->blink)
	fs->blink->flink = fs->flink;
}
#define fb_unlink_free_sector(f, s)    fb_unlink_sector(&(f)->free_head, \
						  &(f)->free_tail,	 \
						  s)
    
#define fb_unlink_depleted_sector(f, s)	fb_unlink_sector(&(f)->depleted_head, \
						      &(f)->depleted_tail,    \
						      s)

#define fb_unlink_erasable_sector(f, s)	fb_unlink_sector(&(f)->erasable_head, \
						      &(f)->erasable_tail,    \
						      s)


/*
************************************************************************
*
* 
* 
************************************************************************
*/
void    
fb_add_sector(
    frml_sector_t** headp,
    frml_sector_t** tailp,
    frml_sector_t*  fs,
    frml_list_id_t  lid)
{
    if (*headp == NULL) {
	/* empty */
	fs->flink = fs->blink = NULL;
	*headp = *tailp = fs;
    }
    else {
	fs->flink = NULL;
	fs->blink = *tailp;
	fs->blink->flink = fs;
	*tailp = fs;
    }
    fs->lid = lid;
}

#define fb_add_free_sector(f, s)    fb_add_sector(&(f)->free_head,	\
						  &(f)->free_tail,	\
						  s, frml_lid_free)
#define fb_add_depleted_sector(f, s)	fb_add_sector(&(f)->depleted_head, \
						      &(f)->depleted_tail, \
						      s, frml_lid_depleted)

#define fb_add_erasable_sector(f, s)	fb_add_sector(&(f)->erasable_head, \
						      &(f)->erasable_tail, \
						      s, frml_lid_erasable)
/*
************************************************************************
*
* 
* 
************************************************************************
*/
void*
new_frml_obj(
    size_t  size,
    char*   ids)
{
    void*  ret;

    ret = frml_malloc(size);
    if (ret) {
	memset((void*)ret, 0x00, size);
    }

    return (ret);
}
    
#define	new_frml_sector()   (frml_sector_t*)new_frml_obj(	\
    sizeof(frml_sector_t),					\
    "frml_sector")

#define	new_frml_bank()	    (frml_bank_t*)new_frml_obj(	\
    sizeof(frml_bank_t),				\
    "frml_bank")

#define	new_frml_remap_table(n)	    (frml_remap_entry_t*)new_frml_obj(	\
    sizeof(frml_remap_entry_t) * (n),					\
    "frml_remap_table")

#define free_frml_remap_table(p)    frml_free(p)
    
#define	new_frml_sector_table(n)    (frml_sector_t**)new_frml_obj(	\
    sizeof(frml_sector_t*) * (n),					\
    "frml_sector_table")

#define free_frml_sector_table(p)   frml_free(p)    

/*
************************************************************************
*
* 
* 
************************************************************************
*/
void
free_frml_sector(
    frml_sector_t   *sp)
{
    frml_free((void*)sp);
}
    
/*
************************************************************************
*
* 
* 
************************************************************************
*/
void    
free_frml_bank(
    frml_bank_t*    fbp)
{
    frml_sector_t*  sp;
    frml_sector_t*  nsp;

    for (sp = fbp->free_head; sp; sp = nsp) {
	nsp = sp->flink;
	free_frml_sector(sp);
    }

    for (sp = fbp->depleted_head; sp; sp = nsp) {
	nsp = sp->flink;
	free_frml_sector(sp);
    }
    
    for (sp = fbp->erasable_head; sp; sp = nsp) {
	nsp = sp->flink;
	free_frml_sector(sp);
    }

    frml_free(fbp);
}

/*
************************************************************************
*
* 
* 
************************************************************************
*/
void
free_frml_system(
    frml_system_t*  fsp)
{
    frml_bank_t*    fbp;
    frml_bank_t*    nfbp;

    for (fbp = fsp->bank_head; fbp; fbp = nfbp) {
	nfbp = fbp->flink;
	free_frml_bank(fbp);
    }
    fsp->bank_head = fsp->bank_tail = NULL;
    free_frml_sector_table(fsp->sector_table);
    memset(fsp, 0x00, sizeof(*fsp));
}

/*
************************************************************************
*
* 
* 
************************************************************************
*/
uint
fs_add_sector(
    frml_system_t*  sys,
    frml_sector_t*  fsp)
{
    
    sys->sector_table[sys->next_sector] = fsp;
    return (sys->next_sector++);
}


/*
************************************************************************
*
* scan a sector into the system
* 
************************************************************************
*/
int
fb_scan_sector(
    softc_t*		    scp,
    frml_bank_t*	    fbp,
    frml_remap_entry_t*	    rt,
    frml_on_dev_sector_t*   ods,
    size_t		    sec_len)
{
    int	num_blocks = ods->num_blocks;
    int		    i;
    frml_sector_t*  fs;
    frml_remap_t    remap;
    char*	    block_vaddr;
    uint	    sector_idx;
    uint	    superseded_cnt = 0;

    frml_trace(1, (("enter fb_scan_sector\n")));

    /* skip mundane sectors */
    if (ods->magic_num != FRML_MAGIC_NUM)
    {
	frml_warn(("mundane sector seen, off: 0x%08lx\n",
		   (unsigned long)((char*)ods - (char*)skiff_flash_vbase)));
	
	return (EINVAL);		/* ??? or error ??? */
    }
    
    fs = new_frml_sector();
    if (!fs) {
	frml_error(("cannot alloc flash sector in fb_scan_sector\n"));
	return (ENOMEM);
    }
    sector_idx = fs->my_idx = fs_add_sector(fbp->parent, fs);

    fs->num_blocks = num_blocks;
    fs->od_sec = ods;
    fs->bank = fbp;
    fs->sec_len = sec_len;
    
    /* initialize to no free blocks */
    fs->alloc_next = fs->num_blocks;
    block_vaddr = (char*)ods + fods_len_round(ods);

    /* count vblocks in system */
    scp->num_vblocks += num_blocks;
    
    for (i = 0; i < num_blocks; i++) {
	remap = ods->remaps[i];
	
	/* find place to begin allocating in this sector */
	if (REMAP_FREE(remap)) {
	    /* set it if it hasn't been set yet. */
	    if (fs->alloc_next == num_blocks)
		fs->alloc_next = i;

#ifdef USER_MODE_TEST
	    num_free_sectors_counted++;
#endif	    
	    /* we *should* be able to break, here */
	    /* unless we do non-compressing cleaning */
	    continue;
	}

	if (REMAP_SUPERSEDED(remap)) {
	    superseded_cnt++;
	    continue;
	}

	if (!REMAP_READY(remap)) {
	    frml_warn(("non ready block seen.  repair req'd\n"));
	}
	
	/* add entry to remap table */
	rmt_add_entry(rt, remap,
		      (void*)(block_vaddr + (i << FRML_BSIZE_SHIFT)),
		      sector_idx, i);
    }

    /* any space in this sector ??? */
    if (fs->alloc_next != num_blocks) {
	fb_add_free_sector(fbp, fs);
    }
    else if (superseded_cnt != 0) {
	fb_add_erasable_sector(fbp, fs);
    }
    else {
	fb_add_depleted_sector(fbp, fs);
    }

    return (0);
}

    
/*
************************************************************************
*
* build a frml_system_t
* Some day, this may be able to find out more about the system dynamically
* or via some kind of ioctl config, or something.
* For now it is hard coded.
* 
************************************************************************
*/
int
frml_scan_flash(
    softc_t*	scp)
{
    int	i;
    int	rc;
    frml_system_t*  fsp = softc_to_fsp(scp);
    frml_bank_t*    fbp;
    uint	    num_vblocks;
    
    frml_trace(1, (("enter frml_scan_flash\n")));
    
    /*
     * we can't easily compute the number of vblocks in the system since
     * it must be adjusted downward for the number of remap blocks in
     * each sector.  So we'll simply count 'em as we scan.
     * *BUT* we need a number so we can allocate the remap table
     * which must be in place as we scan.  So we precompute a number
     * which is guaranteed to be large enough.
     */
    scp->num_vblocks = 0;
    num_vblocks = sector_offs[def_sector_zero + def_num_sectors] -
	sector_offs[def_sector_zero];
    num_vblocks >>= FRML_BSIZE_SHIFT;
    
    scp->remap_table = new_frml_remap_table(num_vblocks);
    if (scp->remap_table == NULL) {
	frml_error(("cannot malloc remap table.\n"));
	return(ENOMEM);
    }
    
    fsp->num_sectors = def_num_sectors;
    fsp->sector_table = new_frml_sector_table(fsp->num_sectors);
    if (fsp->sector_table == NULL) {
	frml_error(("cannot malloc sector table.\n"));
	free_frml_remap_table(scp->remap_table);
	return(ENOMEM);
    }
    
    fbp = new_frml_bank();
    if (fbp == NULL) {
	frml_error(("cannot alloc frml_bank in scan_flash\n"));
	free_frml_remap_table(scp->remap_table);
	free_frml_sector_table(fsp->sector_table);
	return (ENOMEM);
    }
    fbp->parent = fsp;
    fbp->vbase = (char*)skiff_flash_vbase;
    fbp->sector_zero = def_sector_zero;
    fbp->num_sectors = def_num_sectors;

    /* for all banks  */
    /* for all segments per bank */
    /* for all sectors per segment */
    fsp->bank_head = fsp->bank_tail = fbp;
    fbp->flink = fbp->blink = NULL;

    for (i = 0; i < fbp->num_sectors; i++) {
	int off_idx = i + fbp->sector_zero;
	rc = fb_scan_sector(scp,
			    fbp,
			    scp->remap_table,
			    (frml_on_dev_sector_t*)(fbp->vbase +
						    sector_offs[off_idx]),
			    sector_offs[off_idx+1] - sector_offs[off_idx]);
	if (rc != 0) {
	    frml_error(("fb_scan_sector returned %d\n", rc));
	    free_frml_remap_table(scp->remap_table);
	    free_frml_sector_table(fsp->sector_table);
	    free_frml_bank(fbp);	    
	    break;
	}
	
    }

    if (rc == 0) {
	if (scp->num_vblocks > FRML_RESERVED_BLOCKS) {
	    frml_trace(1, ("num_vblocks(before): %d\n", scp->num_vblocks));
	    scp->num_vblocks -= FRML_RESERVED_BLOCKS;
	    fsp->alloc_sector = fbp->free_head;
	    fsp->alloc_bank = fbp;
	    frml_trace(1, ("num_vblocks(after): %d\n", scp->num_vblocks));
	}
	else {
	    frml_error(("Not enough vblocks in the system\n"));
	    free_frml_remap_table(scp->remap_table);
	    free_frml_sector_table(fsp->sector_table);
	    free_frml_bank(fbp);	    
	    rc = ENOSPC;
	}
    }

    return (rc);
}

/*
************************************************************************
*
* 
* 
************************************************************************
*/
void
frml_read(
    softc_t*	scp,
    struct buf*	bp,
    daddr_t	blk)
{
    void*   datap;
    caddr_t buf;

    buf = bp->b_un.b_addr;
    
    while (bp->b_resid) {
	if (blk >= scp->num_vblocks)
	    break;
	
	FRML_STAT_COUNT_READS(scp);
	datap = scp->remap_table[blk].block_vaddr;
	frml_trace(1, ("frml_read(): datap: %p\n", datap));
	
	if (!datap) {
	    frml_trace(2, ("frml_read(): unmapped sector, ret zeroes\n"));
	    memset(buf, 0x00, FRML_BSIZE);
	}
	else {
	    frml_bank_t*    fbp = fre_to_bank(softc_to_fsp(scp),
					      &scp->remap_table[blk]);

	    fb_read_lock(fbp, FRML_BLOCK, "a");
	    bcopy(datap, buf, FRML_BSIZE);
	    fb_read_unlock(fbp);
	}
	
	bp->b_resid -= FRML_BSIZE;
	blk++;
	buf += FRML_BSIZE;
    }	

    bp->b_error = 0;
    biodone(bp);
}

/*
************************************************************************
*
* find_erasable_sector. assume we're locked and loaded...
* 
************************************************************************
*/
frml_sector_t*
find_erasable_sector(
    softc_t*	    scp,
    frml_bank_t**   cur_bankp)
{
    frml_bank_t*    alloc_bank;
    frml_sector_t*  alloc_sector;
    int		    i;
    frml_remap_t    remap;

    /* pull one off an erasable list if there are any */
    /* XXX we may want to thread all erasables on a single list...*/
    for (alloc_bank = softc_to_fsp(scp)->alloc_bank; alloc_bank;
	 alloc_bank = alloc_bank->flink) {
	if (alloc_bank->erasable_head != NULL) {
	    /* got one... */
	    alloc_sector = alloc_bank->erasable_head;
	    fb_unlink_erasable_sector(alloc_bank, alloc_sector);
	    *cur_bankp = alloc_bank;
	    return (alloc_sector);
	}
    }

    /* none are ready to go, see if there are any in the depleted lists
     * (sectors can move from depleted to erasble when a block is
     * superseded)
     * This should never succeed since we now move blocks to the
     * erasable list when we detect they are candidates for
     * erasing.
     */
    for (alloc_bank = softc_to_fsp(scp)->alloc_bank; alloc_bank;
	 alloc_bank = alloc_bank->flink) {
	fb_read_lock(alloc_bank, FRML_BLOCK, "b");
	for (alloc_sector = alloc_bank->depleted_head; alloc_sector;
	     alloc_sector = alloc_sector->flink) {
	    for (i = 0; i < alloc_sector->num_blocks; i++) {
		remap = alloc_sector->od_sec->remaps[i];
		if (REMAP_SUPERSEDED(remap)) {
		    fb_unlink_depleted_sector(alloc_bank, alloc_sector);
		    *cur_bankp = alloc_bank;
		    frml_warn(("returning erasable sector from depleted list\n"));
		    fb_read_unlock(alloc_bank);
		    return (alloc_sector);
		}
	    }
	}
	fb_read_unlock(alloc_bank);
    }
    
    /* no can do, jonny. */
    return (NULL);
}

/*
************************************************************************
*
* 
* 
************************************************************************
*/
caddr_t
frml_get_cleaner_buf(
    softc_t*	scp,
    size_t	len)
{
    return(frml_malloc(len));
}

/*
************************************************************************
*
* 
* 
************************************************************************
*/
void
frml_free_cleaner_buf(
    softc_t*	scp,
    void*	buf,
    size_t	len)
{
    frml_free(buf);
}

/*
************************************************************************
*
* clean_a_sector
* 
************************************************************************
*/
int
clean_a_sector(
    softc_t*	    scp,
    frml_sector_t*  sector,
    caddr_t	    buf,
    size_t	    len)
{
    int			    i;
    uint		    num_blocks;
    frml_remap_t	    remap;
    caddr_t		    dst;
    caddr_t		    src;
    frml_on_dev_sector_t*   core_ods;
    frml_on_dev_sector_t*   ods;
    frml_bank_t*	    fbp = frml_sector_to_bank(sector);
    int			    num_free_blocks = 0;
    int			    free_the_buffer = 0;
    int			    rc;
    int			    locked = 0;

    /*
     * ??? XXX ???
     * Mark block's progress thru the erase process to make sure we do not
     * end up with an inconsistent remap block.
     */

    frml_trace(1, ("enter clean_a_sector\n"));
    
    if (len) {
	if (len < sector->sec_len) {
	    frml_error(("buf passed to clean_a_sector is too small\n"));
	    return (-1);
	}
    }
    else {
	len = sector->sec_len;
	if ((buf = frml_get_cleaner_buf(scp, len)) == NULL) {
	    frml_error(("cannot get cleaner buffer\n"));
	    return (-1);
	}
	free_the_buffer = 1;
    }

    ods = sector->od_sec;

    fb_write_lock(fbp, FRML_BLOCK, "c");
    locked = 1;
    
    /* copy header to buffer */
    dst = buf;
    core_ods = (frml_on_dev_sector_t*)dst;
    num_blocks = fods_len_round(ods);
    bcopy(ods, dst, num_blocks);
    dst += num_blocks;		/* point past header to data blocks */
	    
    /* copy ready blocks from sector into temp buf */
    num_blocks = ods->num_blocks;
    src = (char*)ods + fods_len_round(ods);
    for (i = 0; i < num_blocks; i++) {
	remap = ods->remaps[i];
	if (REMAP_READY(remap) && !REMAP_SUPERSEDED(remap)) {
	    /* copy the sector */
	    uint tmp = i << FRML_BSIZE_SHIFT;
	    bcopy(src + tmp, dst + tmp, FRML_BSIZE);
	}
	else {
	    /* convert non-ready remaps to free */
	    core_ods->remaps[i] = REMAP_UNUSED;
	    num_free_blocks++;
	}
    }

    /* erase the sector */
    erase_sector(frml_sector_offset(sector));

    frml_trace(1, ("writing ready sectors back\n"));
    
    /* use core since ods is now erased. */
    dst = (char*)ods + fods_len_round(core_ods);
    src = (char*)core_ods + fods_len_round(core_ods);
    /* write ready blocks back to sector */
    for (i = 0; i < num_blocks; i++) {
	remap = core_ods->remaps[i];
	if (REMAP_READY(remap)) {
	    /* write the block back */
	    uint tmp = i << FRML_BSIZE_SHIFT;
	    rc = frml_write_buf(dst + tmp, src + tmp, FRML_BSIZE, fbp);
	    if (rc != 0)
		goto out;
	}
    }

    frml_trace(1, ("writing header back\n"));
    sector->alloc_next = 0;
    /* write back remap header */
    rc = frml_write_buf((char*)ods, (char*)core_ods,
			fods_len_round(core_ods), fbp);

  out:

    if (locked)
	fb_write_unlock(fbp);
    
    if (free_the_buffer)
	frml_free_cleaner_buf(scp, buf, len);
	    
    return (rc ? -rc : num_free_blocks);
}


/*
************************************************************************
*
* find_and_clean_a_sector, return num blocks freed or (-error)
* 
************************************************************************
*/
int
find_and_clean_a_sector(
    softc_t*	    scp,
    frml_bank_t*    cur_bank,
    caddr_t	    buf,
    size_t	    len)
{
    frml_sector_t*  sector;
    int		    rc;

    frml_trace(1, ("enter find_and_clean_a_sector\n"));
    
    sector = find_erasable_sector(scp, &cur_bank);
    if (!sector)
	return (0);

    rc = clean_a_sector(scp, sector, buf, len);
    if (rc > 0) {
	fb_add_free_sector(cur_bank, sector);
    }
    else if (rc == 0) {
	/* should never happen */
	frml_warn(("find_and_clean_a_sector: adding sector to depleted list!\n"));
	
	fb_add_depleted_sector(cur_bank, sector);
    }

    return (rc);
}

/*
************************************************************************
*
* 
* 
************************************************************************
*/
void
handle_depleted_sector(
    frml_bank_t*    alloc_bank,
    frml_sector_t*  alloc_sector)
{
    int	i;

    frml_trace(1, ("handle_depleted_sector called\n"));
    
    /*
     * this sector has no more free blocks in it.
     * if there are any superseded sectors in it, then
     * this is a sector that will benefit from erasing, so
     * we put it on the erasable list.  Otherwise it is simply
     * depleted.
     * ??? do we want to do this here or just scan the depleted list
     * when we run out of blocks???
     */
    fb_unlink_free_sector(alloc_bank, alloc_sector);
    for (i = 0; i < alloc_sector->num_blocks; i++) {
	if (REMAP_SUPERSEDED(alloc_sector->od_sec->remaps[i])) {
	    fb_add_erasable_sector(alloc_bank, alloc_sector);
	    break;
	}
    }
    if (i >= alloc_sector->num_blocks)
	fb_add_depleted_sector(alloc_bank, alloc_sector);
}

/*
************************************************************************
*
* returns a write locked bank.  No lock if no space remains.
* 
************************************************************************
*/
int
frml_block_alloc(
    softc_t*			scp,
    daddr_t			blk,
    caddr_t*			block_vaddrp,
    frml_remap_source_info_t*	infop,
    frml_bank_t**		bankp)
{
    frml_bank_t*    alloc_bank;
    frml_sector_t*  alloc_sector;
    frml_sector_t*  nas;
    int		    i;
    frml_remap_t    remap;

#if CLEAN_SECTORS_INLINE
  again:
#endif
    
    for (alloc_bank = softc_to_fsp(scp)->alloc_bank; alloc_bank;
	 alloc_bank = alloc_bank->flink) {
	fb_write_lock(alloc_bank, FRML_BLOCK, "d");
	for (alloc_sector = alloc_bank->free_head; alloc_sector;
	     alloc_sector = nas) {
	    nas = alloc_sector->flink;
	    for (i = alloc_sector->alloc_next; i < alloc_sector->num_blocks;
		 i++) {
		remap = alloc_sector->od_sec->remaps[i];
		if (REMAP_FREE(remap)) {
		    /* we got one */
		    /* create initial remap entry: allocated<blk> */
		    remap = fr_set_block(remap, blk);
		    remap = SET_FLAG(remap, FRML_FLAG_ALLOCATED);
		    REMAP_SET_REMAP(&alloc_sector->od_sec->remaps[i],
				    remap, alloc_bank);
		    *block_vaddrp = (char*)alloc_sector->od_sec +
			fods_len_round(alloc_sector->od_sec) +
			(i << FRML_BSIZE_SHIFT);
		    
		    alloc_sector->alloc_next = i + 1;
		    *bankp = alloc_bank;
		    frsi_init(infop, alloc_sector->my_idx, i);

		    if (alloc_sector->alloc_next >= alloc_sector->num_blocks) {
			handle_depleted_sector(alloc_bank, alloc_sector);
		    }
		    return(0);
		}
	    }

	    /*
	     * we may get here if we allocated the last free block in an
	     * unconsolidated erased sector
	     */
	    handle_depleted_sector(alloc_bank, alloc_sector);
	}
	fb_write_unlock(alloc_bank);
    }

#if CLEAN_SECTORS_INLINE
    /*
     * test some erase logic... and we may want to do something like this
     * in the real driver
     */
    if (find_and_clean_a_sector(scp, NULL, NULL, (size_t)0)) {
	/*
	 * we can do this better since clean_a_sector will know where
	 * a free block is...
	 */
	
	goto again;
    }
#endif

    frml_error(("frml: no space in frml_block_alloc\n"));
    return (ENOSPC);
}

#ifdef TRY_TO_OVERWRITE
/*
************************************************************************
*
* 
* 
************************************************************************
*/
int
frml_block_overwritable(
    caddr_t block_vaddr,
    caddr_t buf)
{
    int	i;

    for (i = 0; i < FRML_BSIZE; i++) {
	if (flash_word_unwritable(*block_vaddr, *buf))
	    return (0);
	block_vaddr++;
	buf++;
    }

    return (1);
}
#endif

/*
************************************************************************
*
* 
* 
************************************************************************
*/
int
frml_write_block(
    softc_t*		scp,
    frml_remap_entry_t*	frep,
    daddr_t		blk,
    caddr_t		buf)
{
    caddr_t			block_vaddr;
    frml_remap_t*		source_remap;
    int				rc;
    frml_bank_t*		fbp;
    frml_remap_source_info_t	info;
    frml_system_t*		fsp = softc_to_fsp(scp);

#ifdef TRY_TO_OVERWRITE
    /*
     * an optimiztion to save on flash writes is to see if we can write the
     * new sector to the existing sector.  We can do this if none of
     * the bits are required to change from the written state to the
     * erased state.
     */
    block_vaddr = frep->block_vaddr;
    FRML_STAT_COUNT_OVERWRITES(sp);
    if (block_vaddr && frml_block_overwritable(frep->block_vaddr, buf)) {
	frml_trace(2, ("overwriting!\n"));
	fbp = fre_to_bank(fsp, frep);
	fb_write_lock(fbp, FRML_BLOCK, "e");
	rc = frml_write_buf(frep->block_vaddr,
			    buf,
			    FRML_BSIZE,
			    fre_to_bank(softc_to_fsp(scp), frep));
	fb_write_unlock(fbp);
	return (rc);
    }
#endif
    
    rc = frml_block_alloc(scp, blk, &block_vaddr, &info, &fbp);
    if (rc != 0) {
	/* no unlock needed since we got an error. */
	return (rc);
    }
    rc = frml_write_buf(block_vaddr, buf, FRML_BSIZE, fbp);
    
    if (rc != 0) {
	/* XXX may want to retry */
	fb_write_unlock(fbp);
	return (rc);
    }

    source_remap = frsi_to_remapp(fsp, &info);
    REMAP_SET_WRITTEN(source_remap, fbp);
    fb_write_unlock(fbp);	/* was locked in alloc */
    
    if (frep->block_vaddr != NULL) {
	frml_sector_t*  ssector;
	frml_bank_t*    sbank;

	ssector = fre_to_sector(fsp, frep);
	sbank = frml_sector_to_bank(ssector);

	/* queue this update if locked as done in the Kawaguchi paper??? */
	fb_write_lock(sbank, FRML_BLOCK, "f");
	REMAP_SET_SUPERSEDED(fre_to_remapp(fsp, frep), sbank);
	fb_write_unlock(sbank);
	/*
	 * see if we superseded something in a depleted sector
	 */
	if (sector_on_depleted_list(ssector)) {
	    /*
	     * move this newly erasable sector to the eraseable list.
	     */
	    fb_unlink_depleted_sector(sbank, ssector);
	    fb_add_erasable_sector(sbank, ssector);
	}
    }

    fb_write_lock(fbp, FRML_BLOCK, "g");
    REMAP_SET_READY(source_remap, fbp);
    fb_write_unlock(fbp);

    frep->block_vaddr = block_vaddr;
    frep->source_info = info;
    
    return (0);
}

/*
************************************************************************
*
* 
* 
************************************************************************
*/
int
frml_write(
    softc_t*	scp,
    struct buf*	bp,
    daddr_t	blk)

{
    caddr_t buf;
    int	    rc;

    frml_trace(1, ("frml_write, blk: 0x%x\n", blk));
    
    buf = bp->b_un.b_addr;
    while (bp->b_resid) {
	if (blk >= scp->num_vblocks)
	    break;

	FRML_STAT_COUNT_WRITES(scp);
	rc = frml_write_block(scp,
			      &scp->remap_table[blk],
			      blk,
			      buf);
	if (rc) {
	    bp->b_flags |= B_ERROR;
	    break;
	}
	
	bp->b_resid -= FRML_BSIZE;
	blk++;
	buf += FRML_BSIZE;
    }

    bp->b_error = rc;
    biodone(bp);

    return (rc);
}

int
frml_read_lock(
    softc_t*	    scp,
    block_flag_t    flag)
{
    if (scp->num_modders != 0) {
	
	if (flag == FRML_NO_BLOCK)
	    return (EWOULDBLOCK);
	
	while (scp->num_modders) {
	    scp->lock_sleepers++;
	    tsleep(&scp->lock_sleepers, PZERO-1, "frml_rl", 0);
	    scp->lock_sleepers--;
	}
    }

    scp->num_readers++;
    return (0);
}

void
frml_read_unlock(
    softc_t*	scp)
{
    scp->num_readers--;
    if (scp->lock_sleepers)
	wakeup(&scp->lock_sleepers);
}

int
frml_write_lock(
    softc_t*	    scp,
    block_flag_t    flag)
{
    if (scp->num_modders || scp->num_readers) {
	
	if (flag == FRML_NO_BLOCK)
	    return (EWOULDBLOCK);
	
	while (scp->num_modders || scp->num_readers) {
	    scp->lock_sleepers++;
	    tsleep(&scp->lock_sleepers, PZERO-1, "frml_wl", 0);
	    scp->lock_sleepers--;
	}
    }

    scp->num_modders++;
    return (0);
}

void
frml_write_unlock(
    softc_t*	scp)
{
    scp->num_modders--;
    if (scp->lock_sleepers)
	wakeup(&scp->lock_sleepers);
}


#ifdef WRITE_SVC
#define READ_BLOCK  FRML_NO_BLOCK    
#else
    /* we will block until we can read */
#define READ_BLOCK  FRML_BLOCK
#endif
    
/*
************************************************************************
*
* 
* 
************************************************************************
*/
void
frmlstrategy(
    struct buf*	bp)
{
    softc_t*		scp = frml_dev_to_sp(bp->b_dev);
    struct disklabel*	lp;
    struct partition*	pp;
    daddr_t		blk;
    int			wlabel;

    frml_trace(1, ("frmlstrategy, bp: %p, dev: 0x%x, flags: 0x%lx, blk: 0x%x, "
		   "resid: 0x%lx, count: 0x%lx, sc_flags: 0x%x\n",
		   bp,
		   bp->b_dev, bp->b_flags,
		   bp->b_blkno, bp->b_resid, bp->b_bcount, scp->flags));
    
    if (scp == NULL) {
	bp->b_flags |= B_ERROR;
	bp->b_error = ENXIO;
	frml_show_rc(ENXIO, "frmlstrategy.scp_null");
	return;
    }

    lp = scp->dkdev.dk_label;

    /*
     * The transfer must be a whole number of blocks.
     */
    if ((bp->b_bcount % lp->d_secsize) != 0) {
	bp->b_error = EINVAL;
	bp->b_flags |= B_ERROR;
	frml_warn(("bcount(0x%lx) not mult of secsize(0x%lx)\n",
		   (long)bp->b_bcount, (long)lp->d_secsize));
	goto done;
    }

#ifdef notyet
    if (scp->flags & FRMLF_ERASING)
	goto q_it;
#endif
    
    /*
     * Do bounds checking and adjust transfer.  If there's an error,
     * the bounds check will flag that for us.
     */
    wlabel = scp->flags & (FRMLF_WLABEL|FRMLF_LABELLING);
    if (DISKPART(bp->b_dev) != RAW_PART)
	if (bounds_check_with_label(bp, lp, wlabel) <= 0)
	    goto done;

    bp->b_resid = bp->b_bcount;
    blk = bp->b_blkno;

    /*
     * Translate the partition-relative block number to an absolute.
     */
    if (DISKPART(bp->b_dev) != RAW_PART) {
	pp = &scp->dkdev.dk_label->d_partitions[DISKPART(bp->b_dev)];
	blk += pp->p_offset;
    }
    
    if (bp->b_flags & B_READ) {
	frml_read(scp, bp, blk);
	return;
    }

#ifdef WRITE_SVC
  /* q_it: */
    {
	struct buf* ioq;

	ioq = &scp->io_q;
	disksort(ioq, bp);
	if (scp->write_svc_sleeping)
	    wakeup(ioq);
    }
    
#else
    frml_write(scp, bp, blk);
#endif

    return;
	
 done:
    biodone(bp);
}



/*
************************************************************************
*
* 
* 
************************************************************************
*/
int
write_svc(
    softc_t*	scp)
{
    struct buf*		ioq = &scp->io_q;
    struct buf*		bp;
    struct partition*	pp;
    daddr_t		blk;

    while (scp->run_write_svc) {
	if ((bp = ioq->b_actf) != NULL) {
	    ioq->b_actf = bp->b_actf; /* point to the next 'un */

	    frml_trace(1, ("write_svc, bp: %p, dev: 0x%x, flags: 0x%lx, "
			   "blk: 0x%x, resid: 0x%lx, count: 0x%lx, "
			   "sc_flags: 0x%x\n",
			   bp,
			   bp->b_dev, bp->b_flags,
			   bp->b_blkno, bp->b_resid,
			   bp->b_bcount, scp->flags));
	    
	    blk = bp->b_blkno;
	    if (DISKPART(bp->b_dev) != RAW_PART) {
		pp = &scp->dkdev.dk_label->d_partitions[DISKPART(bp->b_dev)];
		blk += pp->p_offset;
	    }

	    frml_write(scp, bp, blk);
	    /* XXX ??? sleep occasionally for fairness ??? */
	}
	else {
	    scp->write_svc_sleeping++;
	    tsleep(ioq, PZERO - 1, "fwscv", 0);
	    scp->write_svc_sleeping--;
	}
    }

    return (0);
}

/*
************************************************************************
*
* 
* 
************************************************************************
*/
int
frml_init_remaps(
    uint    sector_zero,
    uint    num_sectors)
{
    int			    i;
    size_t		    sec_len;
    frml_on_dev_sector_t*   ods;
    uint		    num0;
    uint		    num_remaps;
    uint		    num_blocks;
    uint		    off_idx;
    frml_off_t		    off;

    for (i = 0; i < num_sectors; i++) {
	off_idx = i + sector_zero;
	sec_len = sector_offs[off_idx+1] - sector_offs[off_idx];
	ods = (frml_on_dev_sector_t*)((char*)skiff_flash_vbase +
				      sector_offs[off_idx]);
	
	erase_sector(sector_offs[off_idx]);
	
	num0 = sec_len >> FRML_BSIZE_SHIFT; /* num blocks in sector */
	/* initial guess on how big the header must be */
	num_remaps = 1;
	num_blocks = num0 - num_remaps;
	while (num_blocks) {
	    if (fods_mappable_blocks(num_remaps) >= num_blocks)
		break;
	    num_blocks--;
	    num_remaps++;
	}

	if (num_blocks == 0) {
	    frml_error(("cannot compute number of remaps required.\n"));
	    return (EINVAL);
	}

	off = sector_offs[off_idx];
	frml_write_word(off + field_offset(magic_num, frml_on_dev_sector_t),
			FRML_MAGIC_NUM);
	frml_write_word(off + field_offset(num_blocks, frml_on_dev_sector_t),
			num_blocks);
	
	frml_warn(("init sector at 0x%lx, len: %ld, num0: %d, num_remaps: %d, "
		   "num_blocks: %d\n",
		   (long)((char*)ods - (char*)skiff_flash_vbase),
		   (long)sec_len,
		   num0, num_remaps, num_blocks));
    }

    return(0);
}


int
frmlread(
    dev_t	dev,
    struct uio*	uio,
    int		ioflag)
{
    softc_t*	scp = frml_dev_to_sp(dev);
    
    if (scp == NULL)
	return (ENXIO);
    
    frml_trace(1, ("frmlread, dev: 0x%x, flag: 0x%x\n",
		   dev, ioflag));

    return (physio(frmlstrategy, NULL, dev, B_READ, minphys, uio));
}

int
frmlwrite(
    dev_t	dev,
    struct uio*	uio,
    int		ioflag)
{
    softc_t*	scp = frml_dev_to_sp(dev);
    
    if (scp == NULL)
	return (ENXIO);
    
    frml_trace(1, ("frmlwrite, dev: 0x%x, flag: 0x%x\n",
		   dev, ioflag));

    return (physio(frmlstrategy, NULL, dev, B_WRITE, minphys, uio));
}

#ifdef CATS_TEST

struct vnode*	frml_test_vp;
caddr_t		frml_test_buf;
int		frml_file_ready = 0;

/*
************************************************************************
*
* 
* 
************************************************************************
*/
void
frml_close_test_file(
    softc_t*	scp,
    struct proc *proc)
{
#if 0    
    int			rc;

    rc = vn_rdwr(UIO_WRITE, frml_test_vp, frml_test_buf,
		 0x0000c000, 0, UIO_SYSSPACE, IO_NODELOCKED|IO_UNIT,
		 proc->p_ucred, NULL, proc);

    if (rc) {
	frml_error(("frml_close_test_file(): vn_rdwr failed, rc: %d\n", rc));
    }

    VOP_UNLOCK(frml_test_vp, 0);
    rc = vn_close(frml_test_vp, FREAD|FWRITE, proc->p_ucred, proc);

    frml_show_rc(rc, "frml_close_test_file.vn_close");
    
    frml_file_ready = 0;
    
    frml_free(frml_test_buf);
    frml_test_buf = NULL;
#endif
}


/*
************************************************************************
*
* 
* 
************************************************************************
*/
int
frml_open_test_file(
    softc_t*	scp,
    struct proc *proc)

{
    int	    rc = 0;
    
#if 0
    int			rc1;
    struct nameidata	nd;
#endif
    
    if (frml_file_ready)
	return (0);
#if 0    
    NDINIT(&nd, LOOKUP, FOLLOW, UIO_SYSSPACE, "/usr/tmp/dev-flash", proc);
    if ((rc = vn_open(&nd, FREAD|FWRITE, 0))) {
	frml_error(("frml: cannot open test file, rc: %d\n", rc));
	return (rc);
    }
    frml_test_vp = nd.ni_vp;
    VOP_LEASE(frml_test_vp, proc, proc->p_ucred, LEASE_WRITE);
#endif
    
    /* copy into buffer */
    frml_test_buf = frml_malloc(0x0000c000);
    if (!frml_test_buf)
	return (ENOMEM);
    else {
	frml_warn(("frml_test_buf: %p\n", frml_test_buf));
	memset(frml_test_buf, 0x2a, 0x0000c000);
    }

#if 0    
    rc = vn_rdwr(UIO_READ, frml_test_vp, frml_test_buf,
		 (int)0x0000c000, (off_t)0, UIO_SYSSPACE,
		 IO_NODELOCKED|IO_UNIT,
		 proc->p_ucred, NULL, proc);
	
    if (rc != 0) {
	frml_error(("frml: cannot read test file, rc: %d\n", rc));
	frml_free(frml_test_buf);
	frml_test_buf = NULL;	
	VOP_UNLOCK(frml_test_vp, 0);
	rc1 = vn_close(frml_test_vp, FREAD|FWRITE, proc->p_ucred, proc);
	if (!rc)
	    rc = rc1;
    }
#endif
    
    if (rc == 0) {
	frml_file_ready = 1;
	skiff_flash_vbase = (frml_word_t*)frml_test_buf;
    }
    
    frml_show_rc(rc, "frml_open_test_file");

    return (rc);
}

#endif

/* stolen from vnd.c */
void
frmlgetdefaultlabel(
    softc_t*		scp,
    struct disklabel*   lp)
{
    struct partition *pp;

    frml_trace(1, (("enter frmlgetdefaultlabel\n")));
    
    bzero(lp, sizeof(*lp));
    
    lp->d_secperunit = scp->num_vblocks;
    lp->d_secsize = FRML_BSIZE;
    lp->d_nsectors = scp->num_vblocks;
    lp->d_ntracks = 1;
    lp->d_ncylinders = 1;
    lp->d_secpercyl = scp->num_vblocks;
    
    strncpy(lp->d_typename, "frml", sizeof(lp->d_typename));
    lp->d_type = DTYPE_DEC;
    strncpy(lp->d_packname, "fictitious", sizeof(lp->d_packname));
    lp->d_rpm = 3600;
    lp->d_interleave = 1;
    lp->d_flags = 0;
    
    pp = &lp->d_partitions[RAW_PART];
    pp->p_offset = 0;
    pp->p_size = lp->d_secperunit;
    pp->p_fstype = FS_UNUSED;
    lp->d_npartitions = RAW_PART + 1;
    
    lp->d_magic = DISKMAGIC;
    lp->d_magic2 = DISKMAGIC;
    lp->d_checksum = dkcksum(lp);
}

/*
 * Read the disklabel from a vnd.  If one is not present, create a fake one.
 * (stolen from vnd.c)
 */
void
frmlgetdisklabel(
    softc_t*	scp,
    dev_t	dev)
{
    char *errstring;
    struct disklabel *lp = scp->dkdev.dk_label;
    struct cpu_disklabel *clp = scp->dkdev.dk_cpulabel;
    int i;

    frml_trace(1, (("enter frmlgetdisklabel\n")));
    
    bzero(clp, sizeof(*clp));
    
    frmlgetdefaultlabel(scp, lp);
    
    /*
     * Call the generic disklabel extraction routine.
     */
    errstring = readdisklabel(FRMLLABELDEV(dev), frmlstrategy, lp, clp);
    if (errstring) {
	/*
	 * Lack of disklabel is common, but we print the warning
	 * anyway, since it might contain other useful information.
	 */
	printf("frml(0x%x): %s\n", dev, errstring);
	
	/*
	 * For historical reasons, if there's no disklabel
	 * present, all partitions must be FS_BSDFFS and
	 * occupy the entire disk.
	 */
	for (i = 0; i < MAXPARTITIONS; i++) {
	    /*
	     * Don't wipe out port specific hack (such as
	     * dos partition hack of i386 port).
	     */
	    if (lp->d_partitions[i].p_fstype != FS_UNUSED)
		continue;
	    
	    lp->d_partitions[i].p_size = lp->d_secperunit;
	    lp->d_partitions[i].p_offset = 0;
	    lp->d_partitions[i].p_fstype = FS_BSDFFS;
	}
	
	strncpy(lp->d_packname, "default label",
		sizeof(lp->d_packname));
	
	lp->d_checksum = dkcksum(lp);
    }
}

/*
************************************************************************
*
* chunks stolen from vnd.c
* 
************************************************************************
*/
int
frmlopen(
    dev_t   dev,
    int     flag,
    int	    mode,
    struct proc *proc)
{
    softc_t*		scp = frml_dev_to_sp(dev);
    int			rc = 0;
    struct disklabel*	lp;
    int			part, pmask;

    printf("frmlopen called\n");
    
    frml_trace(1, ("frmlopen, dev: 0x%x, flag: 0x%x, mode: 0x%x\n",
		   dev, flag, mode));
    
    if (scp == NULL) {
	frml_warn(("frmlopen, scp null\n"));
	return (ENXIO);
    }
    
    if ((rc = frml_write_lock(scp, FRML_BLOCK)) != 0)
	return (rc);

    part = DISKPART(dev);
    pmask = (1 << part);
    
    /*
     * Check to see if there are any other
     * open partitions.  If not, then it's safe to update the
     * in-core disklabel.
     */
    if (scp->dkdev.dk_openmask == 0) {
	disk_attach(&scp->dkdev);
	
#if defined(CATS_TEST)
	frml_warn(("frmlopen, opening test file\n"));
	if ((rc = frml_open_test_file(scp, proc))) {
	    goto done;
	}
#elif !defined(USER_MODE_TEST)
	skiff_flash_vbase = (frml_word_t*)SKIFF_FLASH_VBASE;
#endif
	
#ifdef AUTO_INIT
	if (rc == 0) {
	    frml_on_dev_sector_t*   ods;
	    
	    /* XXX clean up this code!!! */
	    /* init the fs if no magic on it */
	    ods = (frml_on_dev_sector_t*)
		((char*)skiff_flash_vbase + sector_offs[def_sector_zero]);
	    
	    if (ods->magic_num != FRML_MAGIC_NUM) {
		frml_warn(("frmlopen: auto-initing remaps.\n"));
		rc = frml_init_remaps(def_sector_zero, def_num_sectors);
		if (rc != 0) {
		    frml_error(("frmlopen: cannot init remaps, rc: %d\n", rc));
		    goto done;
		}
	    }
	}
#endif    
	
	/* XXX !!! make a maybe_scan_flash which doesn't scan if scanned */
	frml_warn(("frmlopen, calling scan_flash\n"));
	rc = frml_scan_flash(scp);
	
	if (rc != 0) {
	    frml_warn(("scan_flash failed: rc: %d\n", rc));
	    goto done;
	}
	
	frmlgetdisklabel(scp, dev);
    }

    lp = scp->dkdev.dk_label;
    
    /* Check that the partitions exists. */
    if (part != RAW_PART) {
	if (((part >= lp->d_npartitions) ||
	     (lp->d_partitions[part].p_fstype == FS_UNUSED))) {
	    rc = ENXIO;
	    goto done;
	}
    }

    /* Prevent our unit from being unconfigured while open. */
    switch (mode) {
	case S_IFCHR:
	    scp->dkdev.dk_copenmask |= pmask;
	    break;
	    
	case S_IFBLK:
	    scp->dkdev.dk_bopenmask |= pmask;
	    break;
    }
    
    scp->dkdev.dk_openmask =
	scp->dkdev.dk_copenmask | scp->dkdev.dk_bopenmask;
    
  done:
    frml_write_unlock(scp);
    frml_show_rc(rc, "frmlopen");
    return (rc);
}

/*
************************************************************************
*
* 
* 
************************************************************************
*/
void
free_softc(
    softc_t*	scp)
{
    free_frml_system(&scp->frml_system);
    free_frml_remap_table(scp->remap_table);
}

/*
************************************************************************
*
* 
* 
************************************************************************
*/
int
frmlclose(
    dev_t dev,
    int flags,
    int	mode,
    struct proc *p)
{
    softc_t*	scp = frml_dev_to_sp(dev);
    int		rc;
    int		part;

    frml_trace(1, ("frmlclose, dev: 0x%x, flag: 0x%x, mode: 0x%x\n",
		   dev, flags, mode));

    if (scp == NULL)
	return (ENXIO);

    if ((rc = frml_write_lock(scp, FRML_BLOCK)) != 0)
	return (rc);

    part = DISKPART(dev);

    switch (mode) {
	case S_IFCHR:
	    scp->dkdev.dk_copenmask &= ~(1 << part);
	    break;
	    
	case S_IFBLK:
	    scp->dkdev.dk_bopenmask &= ~(1 << part);
	    break;  
    }

    scp->dkdev.dk_openmask =
	scp->dkdev.dk_copenmask | scp->dkdev.dk_bopenmask;
    
    if (scp->dkdev.dk_openmask == 0) {
#ifdef CATS_TEST    
	frml_close_test_file(scp, p);
#endif    
	/* fully closed, free resources */
	disk_detach(&scp->dkdev);
	free_softc(scp);
    }

    frml_write_unlock(scp);

    frml_show_rc(rc, "frmlclose");
    return (rc);
}

/*
************************************************************************
*
* 
* 
************************************************************************
*/
int
frmlioctl(
    dev_t   dev,
    u_long  cmd,
    caddr_t addr,
    int	    flag,
    struct  proc *p)
{
    softc_t*	scp = frml_dev_to_sp(dev);
    int		rc = 0;

    frml_trace(1, ("frmlioctl: dev: 0x%x, cmd: 0x%lx, flag: 0x%x\n",
		   dev, cmd, flag));
    
    if (scp == NULL)
	return (ENXIO);

    rc = suser(p->p_ucred, &p->p_acflag);
    if (rc) {
	frml_error(("frmlioctl(), not suser\n"));
	return (rc);
    }

    switch (cmd) {
	case FRML_IO_CLEAN:
	{
	    frml_clean_request_t* req = (frml_clean_request_t*)addr;
	    int	    num_cleaned;

	    req->rc = 0;
	    for (;;) {
		num_cleaned = find_and_clean_a_sector(scp,
						  NULL,
						  req->buf,
						  req->buf_len);
		if (num_cleaned <= 0)
		    break;
		req->rc += num_cleaned;
	    }
	    frml_trace(1, ("cleaned %d blocks\n", req->rc));
	    break;
	}

	case FRML_IO_WRITE_SVC:
	    scp->run_write_svc = 1;
	    *((int*)addr) = write_svc(scp);
	    rc = 0;
	    break;

	case FRML_IO_WRITE_SVC_STOP:
	    scp->run_write_svc = 0;
	    break;

	case FRML_IO_INIT:
	{
	    frml_init_request_t* req = (frml_init_request_t*)addr;

	    req->rc = frml_init_remaps(req->num_sectors, req->sector_zero);
	    break;
	}

	case FRML_IO_SET_TRACE:
	{
	    frml_trace_request_t* req = (frml_trace_request_t*)addr;

	    req->rc = frml_trace_val;
	    frml_trace_val = req->trace_val;

	    return (0);
	}
	    
	case DIOCGDINFO:
	    *(struct disklabel *)addr = *(scp->dkdev.dk_label);
	    break;

	case DIOCGPART:
	    ((struct partinfo *)addr)->disklab = scp->dkdev.dk_label;
	    ((struct partinfo *)addr)->part =
		&scp->dkdev.dk_label->d_partitions[DISKPART(dev)];
	    break;
	    
	case DIOCWDINFO:
	case DIOCSDINFO:
	    if ((flag & FWRITE) == 0)
		return (EBADF);
	    
	    if ((rc = frml_write_lock(scp, FRML_BLOCK)) != 0)
		return (rc);
	    
	    scp->flags |= FRMLF_LABELLING;
	    
	    rc = setdisklabel(scp->dkdev.dk_label,
			      (struct disklabel *)addr,
			      0, scp->dkdev.dk_cpulabel);
	    frml_show_rc(rc, "frmlioctl.setdisklabel");
	    if (rc == 0) {
		if (cmd == DIOCWDINFO) {
		    rc = writedisklabel(FRMLLABELDEV(dev),
					frmlstrategy, scp->dkdev.dk_label,
					scp->dkdev.dk_cpulabel);
		    frml_show_rc(rc, "frmlioctl.writedisklabel");
		}
	    }
	    
	    scp->flags &= ~FRMLF_LABELLING;
	    
	    frml_write_unlock(scp);
	    
	    break;
	    
	case DIOCWLABEL:
	    if ((flag & FWRITE) == 0)
		return (EBADF);
	    if (*(int *)addr != 0)
		scp->flags |= FRMLF_WLABEL;
	    else
		scp->flags &= ~FRMLF_WLABEL;
	    break;
	    
	case DIOCGDEFLABEL:
	    frmlgetdefaultlabel(scp, (struct disklabel *)addr);
	    break;
	    
	default:
	    frml_warn(("illegal cmd: 0x%lx\n", cmd));
	    rc = EINVAL;
	    break;
    }

    frml_show_rc(rc, "ioctl");
    return (rc);
}

/*
************************************************************************
*
* seems to be used to provide swap partition size
* 
************************************************************************
*/
int
frmlsize(
    dev_t   dev)
{
    frml_trace(1, ("frmlsize, dev: 0x%x\n", dev));
    return(-1);
}

/*
************************************************************************
*
* No swapping to flash.
* 
************************************************************************
*/
int
frmldump(
    dev_t dev,
    daddr_t blkno,
    caddr_t va,
    size_t size)
{
    frml_trace(1, ("frmldump, dev: 0x%x, blkno: 0x%x, va: 0x%x, siz: 0x%x\n",
		   dev, blkno, (int)va, size));
    
    return (EINVAL);
}

/*
************************************************************************
*
* 
* 
************************************************************************
*/
void
frmlattach(
    int	num)
{
    char *mem;
    register u_long size;
    
    if (num <= 0)
	return;
    size = num * sizeof(softc_t);
    mem = malloc(size, M_DEVBUF, M_NOWAIT);
    if (mem == NULL) {
	frml_error(("frml: no memory for frml devices\n"));
	return;
    }
    bzero(mem, size);
    flashes = (softc_t*)mem;
    numfrml = num;
}

/*
************************************************************************
*
* 
* 
************************************************************************
*/

#ifdef USER_MODE_TEST
#include <stdio.h>
#include <fcntl.h>
#include <sys/mman.h>

char*	fname = "dev-flash";



typedef enum seq_type
{
    seq_one,
    seq_rand,
    seq_seq
}
seq_t;

void
next_data(
    daddr_t	*blkp,
    uint32*	datap,
    softc_t*	scp)
{
    *blkp = rand() % (scp->num_vblocks - 4);
    *datap = rand() * rand();
}

/*
************************************************************************
*
* 
* 
************************************************************************
*/
main(
    int	    argc,
    char*   argv)
{
    int		    fd;
    int		    init_flag = 0;
    int		    option;
    int		    wrote_string = 0;
    char	    flenbuf[16];
    char*	    options = "if:b:s:d:l:rn:0:N:S:";
    extern char*    optarg;
    extern int	    optind;
    extern int	    opterr;
    softc_t*	    scp;
    struct buf	    iobuf;
    daddr_t	    blk = 0;
    char	    buf_buf[FRML_BSIZE * 10];
    ulong	    buf_len = FRML_BSIZE;
    int		    rc;
    int		    just_read = 0;
    ulong	    num_iters = 0;
    seq_t	    block_seq = seq_seq;
    seq_t	    data_seq = seq_seq;
    char	    data_str[FRML_BSIZE];
    char	    data_str2[FRML_BSIZE];
    uint	    str_num = 0;
    int		    seed;	/* uninit... random contents??? */
    int		    verify = 1;
    ulong	    save_num_iters;
    daddr_t	    save_blk;
    uint	    save_str_num;
    uint32	    data;
    uint32*	    data_list;
    uint	    loop_cnt = 0;
    uint32	    num_mismatches = 0;

    opterr = 1;

    while((option = getopt(argc, argv, options)) != EOF) {
	switch (option) {
	    case 'i':
		init_flag++;
		break;

	    case 'f':
		fname = optarg;
		break;

	    case 'b':
		blk = strtoul(optarg, NULL, 0);
		break;

	    case 's':
		strcpy(data_str, optarg);
		wrote_string = 1;
		break;

	    case 'd':
	    {
		ulong	datum;
		datum = strtoul(optarg, NULL, 0);
		memset(buf_buf, (int)datum, sizeof(buf_buf));
		break;
	    }

	    case 'l':
		buf_len = strtoul(optarg, NULL, 0);
		if (buf_len > sizeof(buf_buf))
		{
		    fprintf(stderr, "len too long, trunc to: %d\n",
			    sizeof(buf_buf));
		    buf_len = sizeof(buf_buf);
		}
		break;

	    case 'r':
		just_read = 1;
		break;

	    case 'n':
		num_iters = strtoul(optarg, NULL, 0);
		break;

	    case '0':
		def_sector_zero = strtoul(optarg, NULL, 0);
		break;

	    case 'N':
	    {
		uint	n;
		
		n = strtoul(optarg, NULL, 0);
		if (n <= 0)
		    n = DEF_NUM_SECTORS - 1;
		
		if (def_sector_zero + n >= DEF_NUM_SECTORS) {
		    fprintf(stderr, "too many sectors\n");
		    exit(1);
		}
		def_num_sectors = n;
		
		break;
	    }

	    case 'S':
		seed = strtoul(optarg, NULL, 0);
		break;
		
	    default:
		frml_error(("bad option\n"));
		exit(1);
	}
    }

    def_num_vblocks = sector_offs[def_sector_zero + def_num_sectors] -
	sector_offs[def_sector_zero];
    def_num_vblocks >>= FRML_BSIZE_SHIFT;

    if ((data_list = malloc(def_num_vblocks * sizeof(data_list[0]))) == NULL) {
	fprintf(stderr, "cannot malloc data_list\n");
	exit(1);
    }
    memset(data_list, 0x00, def_num_vblocks * sizeof(data_list[0]));
    
#define FSIZE	(4 * 1024 * 1024)    
    if ((fd = open(fname, O_RDWR|O_CREAT, 0666)) < 0) {
	perror("opening/creating file");
	exit(1);
    }

    /* force file size to max */
    if (lseek(fd, FSIZE - 1, SEEK_SET) != FSIZE - 1) {
	perror("lseek failed");
	exit(1);
    }
    read(fd, flenbuf, 1);
    if (lseek(fd, FSIZE - 1, SEEK_SET) != FSIZE - 1) {
	perror("lseek failed");
	exit(1);
    }
    write(fd, flenbuf, 1);

    skiff_flash_vbase = (frml_word_t *)mmap(NULL, (size_t)FSIZE,
					    PROT_READ|PROT_WRITE,
					    MAP_FILE|MAP_VARIABLE|MAP_SHARED,
					    fd,
					    (off_t)0);
    if (skiff_flash_vbase == (frml_word_t*)-1) {
	perror("mmap failed");
	exit(1);
    }
    flashword = skiff_flash_vbase;
    
    if (init_flag) {
	rc = frml_init_remaps(def_sector_zero, def_num_sectors);
	if (rc != 0) {
	    fprintf(stderr, "frml_init_remaps failed, rc: %d\n", rc);
	    exit(2);
	}

	if (init_flag > 1) {
	    munmap(skiff_flash_vbase, FSIZE);
	    close(fd);
	    exit(0);
	}
    }

#if 0    
    if ((rc = frml_scan_flash(&softc)) != 0) {
	fprintf(stderr, "scan_flash failed, rc: %d\n", rc);
	exit(1);
    }
#else
    
    if ((rc = frmlopen(0, 0, S_IFBLK, NULL)) != 0) {
	fprintf(stderr, "frmlopen failed, rc: %d\n", rc);
	exit(1);
    }
#endif    

    scp = frml_dev_to_sp(0);
    
    printf("num_free_sectors_counted: %d\n", num_free_sectors_counted);

    memset(buf_buf, '#', sizeof(buf_buf));
    if (wrote_string) {
	strcpy(buf_buf, data_str);
    }

    save_num_iters = num_iters;
    save_blk = blk;
    save_str_num = str_num;
    srand(seed);

    for (loop_cnt = 0; loop_cnt < num_iters; loop_cnt++) {
	memset(&iobuf, 0x00, sizeof(iobuf));
	memset(buf_buf, '#', sizeof(buf_buf));
	
	next_data(&blk, &data, scp);
	data_list[blk] = data;
	*((uint32*)buf_buf) = data;

	if (!just_read) {
	    iobuf.b_blkno = blk;
	    iobuf.b_un.b_addr = buf_buf;
	    iobuf.b_bcount = buf_len;
	    iobuf.b_flags = B_WRITE;
	    frmlstrategy(&iobuf);
	    rc = iobuf.b_error;
	    if (rc != 0) {
		fprintf(stderr, "frml_write failed, rc: %d\n", rc);
		exit(1);
	    }
	    printf("write data(%d): 0x%08lx, blk: %ld\n", loop_cnt,
		   *((uint32*)buf_buf), blk);
	}
    }
    
    num_iters = save_num_iters;
    blk = save_blk;
    str_num = save_str_num;
    srand(seed);
    strcpy(data_str2, data_str);

    for (loop_cnt = 0; loop_cnt < num_iters; loop_cnt++) {
	memset(buf_buf, 0x2a, sizeof(buf_buf));
	next_data(&blk, &data, scp);
	iobuf.b_blkno = blk;
	iobuf.b_un.b_addr = buf_buf;
	iobuf.b_bcount = buf_len;
	iobuf.b_flags = B_READ;
	frmlstrategy(&iobuf);
	rc = iobuf.b_error;
	if (rc != 0) 
	{
	
	    fprintf(stderr, "frml_read failed, rc: %d\n", rc);
	    exit(1);
	}

	if (verify) {
	    uint32  read_data =  *((uint32*)buf_buf);
	    
	    if (data_list[blk] != read_data) {
		fprintf(stderr, "data mismatch, blk: 0x%lx, read: 0x%lx, "
			"data_list: 0x%lx\n", blk,  read_data, data_list[blk]);
		num_mismatches++;
	    }
	}
	printf("read data: 0x%08lx, blk: %ld\n",  *((uint32*)buf_buf), blk);
    }

    if (num_mismatches) {
	fprintf(stderr, "num_mismatches: %ld\n", num_mismatches);
    }

    rc = frmlclose(0, 0, S_IFBLK, NULL);
    if (rc) {
	fprintf(stderr, "frmlclose failed, rc: %d\n", rc);
    }
    
    exit(num_mismatches != 0 || rc);
}
    
#endif
