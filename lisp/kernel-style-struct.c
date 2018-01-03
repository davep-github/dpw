/* -*- mode: C; c-file-style: "amd-c-style" -*-  */

struct mesion a[] = {
        { 1,2,3 },
        { blah },
        { yadda },
        { 1,2,3}
};
        
                
                
                

struct amdgpu_vm_manager {
	struct {
		struct fence	*active;
		atomic_long_t	owner;
	} ids[AMDGPU_NUM_VM];

	uint32_t				max_pfn;
	/* number of VMIDs */
	unsigned				nvm;
	/* vram base address for page table entry  */
	u64					vram_base_offset;
	/* is vm enabled? */
	bool					enabled;
	/* vm pte handling */
	const struct amdgpu_vm_pte_funcs        *vm_pte_funcs;
	struct amdgpu_ring                      *vm_pte_funcs_ring;
	/* Allow us to get the pid of the process which created this vm. */
	pid_t					vmid_pid_map[AMDGPU_NUM_VM];
};

struct amdgpu_vm_manager {
	struct {
		struct fence	*active;
		atomic_long_t	owner;
	} ids[AMDGPU_NUM_VM];

	uint32_t				max_pfn;
	/* number of VMIDs */
	unsigned				nvm;
	/* vram base address for page table entry  */
	u64					vram_base_offset;
	/* is vm enabled? */
	bool					enabled;
	/* vm pte handling */
	const struct amdgpu_vm_pte_funcs        *vm_pte_funcs;
	struct amdgpu_ring                      *vm_pte_funcs_ring;
	/* Allow us to get the pid of the process which created this vm. */
	pid_t					vmid_pid_map[AMDGPU_NUM_VM];
};

struct moo
{
	int					blah;
	/* Space before tab... eeveeel. */
	bool 		 			enabled;
	const struct amdgpu_vm_pte_funcs	*vm_pte_funcs;
        suzz_t                                  *sztp;
        auto                                    *autop;
        z_t					*bubba;
        FILE                                    *fp;
        int                                     *amani;
        int                                     *intintintp;
        struct suzz                             *sp;
        int                                     *ipp1;
        struct suzz                             *sz1;
        struct suzz                             *szp;
        int                                     *ip1;
        FILE                                    *f1;
        x_t                                     *xp;
        class bubba                             *bp;
	;
        volati	xx;
	x
	x	xxx;
        x_t                                     *bubba;
        int                                     *iiiiiiip;
	x	                                d;
};

int boo(
	int x,
	int y)
{
	int	x1;
	char    char0;
	long_type_name	blah;
	stm
