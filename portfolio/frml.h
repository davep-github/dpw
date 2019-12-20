#ifndef FRML_H_INCLUDED
#define FRML_H_INCLUDED

#ifdef _KERNEL
#define NFRML	(1)
/*
 * We need to reserve at least one block by not announcing it to the OS.
 * We need this in the case of a full FS.  If the FS is completely full and
 * the OS decides to overwrite some block, we will not be able to if we
 * do not have a block to write new data to first.  So we reserve at least
 * one block.
 */
#define FRML_RESERVED_BLOCKS	(1)

#define field_offset(f, t)	((char*)(&(((t*)0)->f)) - (char*)0)

#ifdef ENV_64_BIT
typedef unsigned int	uint32;
typedef int		int32;
typedef unsigned short	uint16;
typedef short		int16;
#else
typedef unsigned long	uint32;
typedef long		int32;
typedef unsigned short	uint16;
typedef short		int16;
#endif

/* "FRML" or "LMRF" endian dependant */
#define FRML_MAGIC_NUM	    (0x46524D4C)    
#define FRML_BSIZE_SHIFT    (9)
#define	FRML_BSIZE	    (1 << FRML_BSIZE_SHIFT)
#define	FRML_BSIZE_MASK	    (FRML_BSIZE - 1)
#define FRML_BSIZE_ROUND(n) (((n) + FRML_BSIZE - 1) & ~FRML_BSIZE_MASK)

/* 32 bit quantity, base writable flash unit */
typedef uint32		frml_word_t;
typedef uint32		frml_off_t; /* offset with our flash device */
typedef unsigned char	frml_byte_t;
typedef daddr_t		frml_block_t;

typedef time_t		frml_time_t;

typedef uint32		frml_remap_t;
#define	FRML_BLOCK_MASK	(0x00ffffff)
#define	FRML_FLAG_MASK	(0xff000000)

/*
 * for now (and this flash device) 1 is off and 0 is on
 */

#define	FRML_FLAG_ALLOCATED_BITNUM  (31)
#define	FRML_FLAG_WRITTEN_BITNUM    (30)
#define	FRML_FLAG_READY_BITNUM	    (29)
#define	FRML_FLAG_SUPERSEDED_BITNUM (28)

#define MAKE_FLAG(bitnum)	    (1 << (bitnum))

#define	FRML_FLAG_ALLOCATED	MAKE_FLAG(FRML_FLAG_ALLOCATED_BITNUM)
#define	FRML_FLAG_WRITTEN	MAKE_FLAG(FRML_FLAG_WRITTEN_BITNUM)
#define	FRML_FLAG_READY		MAKE_FLAG(FRML_FLAG_READY_BITNUM)
#define	FRML_FLAG_SUPERSEDED	MAKE_FLAG(FRML_FLAG_SUPERSEDED_BITNUM)

#ifdef POSITIVE_LOGIC
/* NB: positive logic is untested */
#define SET_FLAG(w, f)		    ((w) | (f))
#define TEST_FLAG(w, f)		    (((w) & (f)) == (f))
#define	REMAP_UNUSED		    ((frml_remap_t)0)
#define flash_word_unwritable(fw, dw) ((fw) & ~(dw))
#else
/* turn the bit off */
#define SET_FLAG(w, f)		    ((w) & ~(f))
/* non-zero still means set, even if set means 0! */
#define TEST_FLAG(w, f)		    ((~(w) & (f)) == (f))
#define	REMAP_UNUSED		    (~((frml_remap_t)0))
#define flash_word_unwritable(fw, dw) (~(fw) & (dw))
#endif

#define fr_hi_flags(r)	    ((r) & FRML_FLAG_MASK)
#define fr_get_flags(r)	    (fr_hi_flags(r) >> 24)
#define	fr_get_block(r)	    ((r) & FRML_BLOCK_MASK)
#define	fr_set_block(r, b)  (fr_hi_flags(r) | ((b) & FRML_BLOCK_MASK))
#define fr_set_flags(r, f)  (fr_get_block(r) | ((f) << 24))

#define REMAP_ALLOCATED(r)  TEST_FLAG(r, FRML_FLAG_ALLOCATED)
#define REMAP_FREE(r)	    !REMAP_ALLOCATED(r)
#define REMAP_WRITTEN(r)    TEST_FLAG(r, FRML_FLAG_WRITTEN)
#define REMAP_READY(r)	    TEST_FLAG(r, FRML_FLAG_READY)
#define REMAP_SUPERSEDED(r) TEST_FLAG(r, FRML_FLAG_SUPERSEDED)

#define REMAP_SET_REMAP(p, v, fb)   frml_write_ptr(p, v, fb)

#define REMAP_SET_WRITTEN(rp, fb)			\
    REMAP_SET_REMAP(rp,					\
		    SET_FLAG(*(rp), FRML_FLAG_WRITTEN),	\
		    fb)
    
#define REMAP_SET_SUPERSEDED(rp, fb)				\
    REMAP_SET_REMAP(rp,						\
		    SET_FLAG(*(rp), FRML_FLAG_SUPERSEDED),	\
		    fb)
    
#define REMAP_SET_READY(rp, fb)					\
    REMAP_SET_REMAP(rp,						\
		    SET_FLAG(*(rp),FRML_FLAG_READY), fb)
						 
					   
/*
************************************************************************
*
* frml_on_dev_sector_s
* On device sector header (lives in flash)
* Each sector is formatted with one of these.
* The purpose of this structure is to map physical blocks on dev to
* virtual blocks in the system.
* 
************************************************************************
*/
typedef struct frml_on_dev_sector_s
{
    /*
     * this is the on device image of a sector header
     */
    uint    magic_num;
    uint    num_blocks;	/* number of blocks there */
    
    /* actually num_blocks long */
    frml_remap_t    remaps[1];
}
frml_on_dev_sector_t;

#define fods_core_size() (sizeof(frml_on_dev_sector_t) - sizeof(frml_remap_t))
#define fods_len0(n)	((n) * sizeof(frml_remap_t) + fods_core_size())

#define fods_len(p)	(fods_len0((p)->num_blocks))
			
    
#define fods_len_in_blocks(p)	    ((fods_len(p) + FRML_BSIZE - 1) >>	\
				     FRML_BSIZE_SHIFT)

#define fods_len0_in_blocks(n)	    ((fods_len0(n) + FRML_BSIZE - 1) >>	\
				     FRML_BSIZE_SHIFT)
    
#define fods_len_round(p)	FRML_BSIZE_ROUND(fods_len(p))
#define fods_len0_round(n)	FRML_BSIZE_ROUND(fods_len0(n))

#define fods_mappable_blocks(nblk) ((((nblk) << FRML_BSIZE_SHIFT) -	  \
				  fods_core_size()) / sizeof(frml_remap_t))
    
/* forward ref */
struct frml_system_s;
struct frml_bank_s;

typedef enum frml_list_id_e
{
    frml_lid_free = 1,
    frml_lid_depleted,
    frml_lid_erasable
}
frml_list_id_t;

/*
************************************************************************
*
* sector header, lives in DRAM.  Has link fields for various lists
* and points to actual sector header in FLASH.
* 
* 
************************************************************************
*/
typedef struct frml_sector_s
{
    /*
     * list pointers
     * Can be on only one list at a time...
     */
    struct frml_sector_s*   flink;
    struct frml_sector_s*   blink;

    struct frml_bank_s*	    bank;
    
    frml_on_dev_sector_t*   od_sec; /* whence we came */

    /*
     * index into global sector table.  This allows us to find
     * a sector given a 16 bit index identifier.
     * The table is in the frml_system_t.
     */
    uint16	    my_idx;
    uint	    num_blocks;	/* total blocks in this sector */
    uint	    alloc_next;	/* next block to allocate */
    uint	    sec_len;	/* length of this sector */
    frml_list_id_t  lid;	/* id of list we are currently on */
    
}
frml_sector_t;

#define	frml_sector_to_bank(sp)	((sp)->bank)
#define sector_on_depleted_list(s)  ((s)->lid == frml_lid_depleted)
/*
************************************************************************
*
* bank - A bank can be multi-read, written or erased.
* we split into banks to maximize concurrent operations
* 
************************************************************************
*/
typedef struct frml_bank_s
{
    /*
     * links for list within parent frml_system
     */
    struct frml_bank_s*	flink;
    struct frml_bank_s*	blink;

    struct frml_system_s*   parent;

    /* vaddr of 0th byte in this bank */
    volatile char*  vbase;

    uint    sector_zero;	/* first sector we'll use */
    uint    num_sectors;
    
    /*
     * lock vars.
     * Locking is done on a bank basis since we can only
     * read (many) xor write (once) xor erase (once)
     * on a bank (chip)
     */
    uint    num_readers;
    uint    num_modders;	/* write, erase */
    uint    lock_sleepers;

    frml_sector_t*  free_head;
    frml_sector_t*  free_tail;

    frml_sector_t*  depleted_head;
    frml_sector_t*  depleted_tail;

    frml_sector_t*  erasable_head;
    frml_sector_t*  erasable_tail;

}
frml_bank_t;

#define	frml_bank_find_offset(bp, p)	(((char*)(p)) - ((char*)(bp)->vbase))

#define frml_sector_offset(sp)	(frml_bank_find_offset(	\
    frml_sector_to_bank(sp),				\
    (sp)->od_sec))
/*
************************************************************************
*
* 
* 
************************************************************************
*/
typedef struct frml_system_s
{
    uint    num_segments;
    uint    num_sectors;
    uint    num_blocks;
    uint    next_sector;

    frml_bank_t*    bank_head;
    frml_bank_t*    bank_tail;

    frml_bank_t*    alloc_bank;
    frml_sector_t*  alloc_sector;

    frml_sector_t** sector_table;
}
frml_system_t;

/*
***********************************************************************
*
* In core remap structures.
* The table is indexed by virtual block number.
* Each entry contains a pointer to where the block currently lives in
* flash.  This pointer can be used directly to access the block data.
* The source_remap pointer points to the remap entry in the on device
* sector that was used to fill this entry.  When we rewrite a vblock,
* we can use this pointer to quickly supersede the old remap entry.
* 
***********************************************************************
*/

typedef struct frml_remap_source_info_s
{
    uint16  sector_idx;
    uint16  block_idx;
}
frml_remap_source_info_t;

#define frsi_init(p, si, bi)	{(p)->sector_idx = si; (p)->block_idx = bi;}
#define frsi_to_sector(fsp, rsi) ((fsp)->sector_table[(rsi)->sector_idx])
#define frsi_to_remap(fsp, rsi) \
    (frsi_to_sector(fsp, rsi)->od_sec->remaps[(rsi)->block_idx])
#define frsi_to_remapp(fsp, rsi) &frsi_to_remap(fsp, rsi)
    
typedef struct frml_remap_entry_s
{
    void*			block_vaddr;
    frml_remap_source_info_t	source_info;
}
frml_remap_entry_t;

#define fre_to_frsi(rep)	(&(rep)->source_info)
#define fre_to_remap(fsp, rep)	frsi_to_remap(fsp, fre_to_frsi(rep))
#define fre_to_remapp(fsp, rsi)	&fre_to_remap(fsp, rsi)
#define fre_to_sector(fsp, rep)	frsi_to_sector(fsp, fre_to_frsi(rep))
#define fre_to_bank(fsp, rep)	frml_sector_to_bank(fre_to_sector(fsp, rep))

typedef frml_remap_entry_t* frml_remap_table_t;

typedef enum block_flag_e
{
    FRML_NO_BLOCK = 1,
    FRML_BLOCK = 2
}
block_flag_t;

extern int
frmlopen(
    dev_t   dev,
    int     flag,
    int	    mode,
    struct proc *proc);

extern int
frmlclose(
    dev_t dev,
    int flags,
    int	mode,
    struct proc *p);

extern int
frmlsize(
    dev_t   dev);

extern int
frmldump(
    dev_t dev,
    daddr_t blkno,
    caddr_t va,
    size_t size);

extern int
frmlioctl(
    dev_t   dev,
    u_long  cmd,
    caddr_t addr,
    int	    flag,
    struct  proc *p);

extern
int frmlread(
    dev_t dev,
    struct uio *uio,
    int ioflag);

extern
int
frmlwrite(
    dev_t dev,
    struct uio *uio,
    int ioflag);

extern void
frmlstrategy(
    struct buf*	bp);

#endif /* _KERNEL */

/*
 * ioctl support
 */
typedef struct frml_clean_request_s
{
    caddr_t buf;		/* cleaning buffer. */
    size_t  buf_len;		/* len of cleaner buffer. 0-> driver mallocs */
    int	    rc;			/* number of blocks freed */
}
frml_clean_request_t;

typedef struct frml_init_request_s
{
    uint    sector_zero;
    uint    num_sectors;
    int	    rc;
}
frml_init_request_t;

typedef struct frml_trace_request_s
{
    uint    trace_val;
    int	    rc;
}
frml_trace_request_t;

#define	FRML_IO_CLEAN		_IOWR('F', 70, frml_clean_request_t)
#define FRML_IO_WRITE_SVC	_IOR('F', 71, int)
#define FRML_IO_WRITE_SVC_STOP  _IO('F', 72)
#define FRML_IO_INIT		_IOWR('F', 73, frml_init_request_t)
#define FRML_IO_SET_TRACE	_IOWR('F', 74, frml_trace_request_t)

#endif
