library(psych)
library(oro.nifti)
library(stringr)
library(dplyr) # for bind_rows, group_by, mutate
library(tidyr) # for spread
atlas <- 'vmpfc_str_vta_2mm.nii.gz'

# find all r2prime mni files in 7t and in pet
r2p_7t_all <-  Sys.glob('/Volumes/Hera/Projects/7TBrainMech/subjs/*/R2prime/mc_mni/r2prime_mni.nii.gz')
r2p_pet_all <-  Sys.glob('/Volumes/Phillips/mMR_PETDA/subjs/*/r2prime/r2primeMap_MNI152_T1_2009c_al_2mm.nii.gz')

# reduce sets to just shared ids
extract_id <- function(s) str_extract(s, '(?<=subjs/)\\d{5}')
shared_ids <- intersect(extract_id(r2p_7t_all), extract_id(r2p_pet_all))
idregex <- paste(shared_ids,collapse="|")
r2p_pet <- grep(idregex, r2p_pet_all, value=T)
r2p_7t <- grep(idregex, r2p_7t_all, value=T)

# read in mask
m <- readNIfTI(atlas)@.Data > 0

# read in r2prime as voxel per row from mask
# catpure id, vdate, and study from file name
read_r2p <- function(n, m) {
   id    <- as.numeric(str_extract(n,'(?<=subjs/)\\d{5}'))
   vdate <- as.numeric(str_extract(n,'(?<=\\d{5}_)\\d{8}'))
   study <- str_extract(n,'7TBrainMech|mMR_PETDA')
   val   <- readNIfTI(n)@.Data[m]
   # remove negatives
   val[val<0] <- 0
   data.frame(val, id, vdate, study, idx=1:length(val))
}

# run read_r2p for all of the nii.gz file we care about
# val    id    vdate     study idx
#   0 10195 20160317 mMR_PETDA   1
#   0 10195 20160317 mMR_PETDA   2
d <- lapply(c(r2p_pet, r2p_7t), read_r2p, m) %>% bind_rows

# get a unque id for each visit (like mMR_PETDA_1, mMR_PETDA_2, 7TBrainMech_1)
# study          id    vdate vid          
# mMR_PETDA   10195 20160317 mMR_PETDA_1  
# mMR_PETDA   10195 20170824 mMR_PETDA_2 
d_vid <- d %>% group_by(id,vdate,study) %>% tally %>%
   group_by(id, study) %>% 
   mutate(vno = rank(vdate),
          vid = paste(study,vno,sep="_")) %>%
   select(id,vdate,vid)

# make each visit it's own column
#    id idx 7TBrainMech_1 mMR_PETDA_1 mMR_PETDA_2
# 10195   1            57           0    51.10324
# 10195   2            0            0    40.32986
d_wide <-
   d %>%
   inner_join(d_vid, by=c("id", "vdate") ) %>%
   select(id,vid,idx,val) %>%
   spread(vid,val)

### cor/ICC values
kencor <- 
   d_wide %>% 
   filter(!is.na(mMR_PETDA_1+mMR_PETDA_2)) %>%
   select(`7TBrainMech_1`,mMR_PETDA_1, mMR_PETDA_2) %>%
   cor(method='kendall')

# only for columns 7TBrainMech_1 mMR_PETDA_1 mMR_PETDA_2
icc <- d_wide %>% select(-idx, -id) %>% ICC

## per subject 
# 7T and first pet
mmrvs7t <- d_wide %>%
   filter(!is.na(mMR_PETDA_1)) %>% 
   split(.,.$id) %>%
   lapply(function(x) x %>% select(`7TBrainMech_1`,mMR_PETDA_1) %>% ICC)

# within pet
mmr <- d_wide %>%
   filter(!is.na(mMR_PETDA_1), !is.na(mMR_PETDA_2)) %>% 
   split(.,.$id) %>%
   lapply(function(x) x %>% select(mMR_PETDA_1,mMR_PETDA_2) %>% ICC)

# show 
print(kencor)
print(icc$results$ICC)
print(lapply(mmr, function(x) x$results$ICC))
print(lapply(mmrvs7t, function(x) x$results$ICC))
